package Controller;

import Interfaces.IGestionPedidosRemoto;
import Interfaces.IGestionProductosRemoto;
import entidades.Clientes;
import entidades.DetallePedido;
import entidades.Empleados;
import entidades.Pagos;
import entidades.Pedidos;
import entidades.Productos;
import entidades.Servicios;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@WebServlet(name = "POSServlet", urlPatterns = {"/POSServlet"})
public class POSServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        Empleados empleado = (Empleados) session.getAttribute("usuario");
        if (empleado == null) {
            out.print("{\"success\":false,\"error\":\"Sesion no valida\"}");
            return;
        }

        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String json = sb.toString();

            String metodoPago = extractJsonString(json, "metodoPago");
            String codigoOperacion = extractJsonString(json, "codigoOperacion");
            double montoRecibido = extractJsonDouble(json, "montoRecibido");

            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
            IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");

            List<PedidoItem> items = parseItems(json);
            if (items.isEmpty()) {
                out.print("{\"success\":false,\"error\":\"Carrito vacio\"}");
                return;
            }

            double totalGeneral = 0;
            for (PedidoItem item : items) {
                totalGeneral += item.price * item.qty;
            }

            Pedidos pedido = new Pedidos();
            pedido.setIdCliente(new Clientes(1));
            pedido.setFechaRecepcion(new Date());
            pedido.setEstado("Completado");
            pedido.setMontoTotal(BigDecimal.valueOf(totalGeneral));
            pedido.setEstadoPago("Pagado");
            pedido.setEmpleadoReceptor(empleado.getNombreCompleto());

            String notas = "Venta POS | Metodo: " + metodoPago;
            if (codigoOperacion != null && !codigoOperacion.isEmpty()) {
                notas += " | Op: " + codigoOperacion;
            }
            pedido.setNotasAdicionales(notas);

            List<DetallePedido> detalles = new ArrayList<>();

            for (PedidoItem item : items) {
                DetallePedido dp = new DetallePedido();
                dp.setIdPedido(pedido);
                dp.setCantidad(item.qty);
                dp.setSubtotal(BigDecimal.valueOf(item.price * item.qty));
                dp.setProductoEntregado(true);

                if ("servicio".equals(item.type)) {
                    int servicioId;
                    if (item.id == 101) servicioId = 1;
                    else if (item.id == 102) servicioId = 2;
                    else servicioId = 3;
                    dp.setIdServicio(new Servicios(servicioId));
                } else {
                    Productos prod = productoRMI.buscarProductoPorId(item.id);
                    if (prod == null) {
                        out.print("{\"success\":false,\"error\":\"Producto no encontrado: " + item.name.replace("\"", "'") + "\"}");
                        return;
                    }
                    dp.setIdProducto(prod);

                    int nuevoStock = prod.getStock() - item.qty;
                    if (nuevoStock < 0) {
                        out.print("{\"success\":false,\"error\":\"Stock insuficiente para " + item.name.replace("\"", "'") + "\"}");
                        return;
                    }
                    prod.setStock(nuevoStock);
                    boolean stockOk = productoRMI.actualizarProducto(prod);
                    if (!stockOk) {
                        out.print("{\"success\":false,\"error\":\"Error al actualizar stock\"}");
                        return;
                    }
                }
                detalles.add(dp);
            }

            pedido.setDetallePedidoList(detalles);

            List<Pagos> pagos = new ArrayList<>();
            Pagos pago = new Pagos();
            pago.setIdPedido(pedido);
            pago.setIdCliente(1);
            pago.setMonto(BigDecimal.valueOf(totalGeneral));
            pago.setMetodoPago(mapMethod(metodoPago));
            pago.setFechaPago(new Date());
            pagos.add(pago);
            pedido.setPagosList(pagos);

            boolean exito = pedidoRMI.registrarPedidoWeb(pedido);

            if (exito) {
                out.print("{\"success\":true,\"total\":" + totalGeneral
                        + ",\"metodo\":\"" + metodoPago + "\""
                        + ",\"items\":" + items.size() + "}");
            } else {
                out.print("{\"success\":false,\"error\":\"No se pudo registrar la venta\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    private static class PedidoItem {
        int id;
        String name;
        double price;
        int qty;
        String type;
    }

    private List<PedidoItem> parseItems(String json) {
        List<PedidoItem> items = new ArrayList<>();
        int itemsStart = json.indexOf("\"items\"");
        if (itemsStart == -1) return items;
        int arrStart = json.indexOf("[", itemsStart);
        int arrEnd = json.indexOf("]", arrStart);
        if (arrStart == -1 || arrEnd == -1) return items;
        String arr = json.substring(arrStart + 1, arrEnd);

        int i = 0;
        while (i < arr.length()) {
            int objStart = arr.indexOf("{", i);
            if (objStart == -1) break;
            int objEnd = arr.indexOf("}", objStart);
            if (objEnd == -1) break;
            String obj = arr.substring(objStart + 1, objEnd);

            PedidoItem item = new PedidoItem();
            item.id = (int) extractJsonDouble(obj, "id");
            item.name = extractJsonString(obj, "name");
            item.price = extractJsonDouble(obj, "price");
            item.qty = (int) extractJsonDouble(obj, "qty");
            item.type = extractJsonString(obj, "type");
            if (item.type == null || item.type.isEmpty()) item.type = "producto";
            items.add(item);

            i = objEnd + 1;
        }
        return items;
    }

    private String extractJsonString(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx == -1) return "";
        int colonIdx = json.indexOf(":", idx + search.length());
        int firstQuote = json.indexOf("\"", colonIdx + 1);
        int secondQuote = json.indexOf("\"", firstQuote + 1);
        if (firstQuote == -1 || secondQuote == -1) return "";
        return json.substring(firstQuote + 1, secondQuote);
    }

    private double extractJsonDouble(String json, String key) {
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx == -1) return 0;
        int colonIdx = json.indexOf(":", idx + search.length());
        int end = colonIdx + 1;
        while (end < json.length() && (Character.isDigit(json.charAt(end)) || json.charAt(end) == '.' || json.charAt(end) == '-')) {
            end++;
        }
        try {
            return Double.parseDouble(json.substring(colonIdx + 1, end).trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private String mapMethod(String metodo) {
        if (metodo == null) return "Efectivo";
        switch (metodo.toLowerCase()) {
            case "yape": return "Yape";
            case "transferencia": return "Transferencia Bancaria";
            case "contraentrega": return "Contra Entrega";
            case "efectivo": return "Efectivo";
            default: return metodo;
        }
    }
}
