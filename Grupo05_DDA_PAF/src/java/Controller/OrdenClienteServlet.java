package Controller;

import Interfaces.IGestionPedidosRemoto;
import Interfaces.IGestionProductosRemoto;
import Interfaces.IGestionServiciosRemoto;
import entidades.Citas;
import entidades.Clientes;
import entidades.DetallePedido;
import entidades.Pagos;
import entidades.Pedidos;
import entidades.Productos;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@WebServlet(name = "OrdenClienteServlet", urlPatterns = {"/OrdenClienteServlet"})
public class OrdenClienteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();
        Clientes clienteSession = (Clientes) session.getAttribute("cliente");

        if (clienteSession == null) {
            out.print("error: session_expired");
            return;
        }

        String accion = request.getParameter("accion");

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
            IGestionServiciosRemoto servicioCitaRMI = (IGestionServiciosRemoto) registry.lookup("servicioCitaServicio");

            if ("cancelar".equals(accion)) {
                int idPedido = Integer.parseInt(request.getParameter("idPedido"));
                boolean exito = pedidoRMI.cancelarPedido(idPedido);
                out.print(exito ? "success" : "error: no se pudo cancelar");
                return;
            }

            if ("carrito".equals(accion)) {
                int itemCount = Integer.parseInt(request.getParameter("itemCount"));
                String metodoPago = request.getParameter("metodoPago");
                String modalidad = request.getParameter("modalidad");
                String direccion = request.getParameter("direccion");
                String fecha = request.getParameter("fecha");
                
                if (metodoPago == null) metodoPago = "Efectivo";

                IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
                boolean allOk = true;
                StringBuilder errorMessages = new StringBuilder();

                for (int i = 0; i < itemCount; i++) {
                    int itemId = Integer.parseInt(request.getParameter("itemId_" + i));
                    int itemQty = Integer.parseInt(request.getParameter("itemQty_" + i));
                    String itemType = request.getParameter("itemType_" + i);

                    try {
                        Pedidos p = new Pedidos();
                        p.setIdCliente(new Clientes(clienteSession.getIdCliente()));
                        p.setFechaRecepcion(new Date());
                        
                        String estadoInicial;
                        if ("Recojo en Tienda".equals(modalidad)) {
                            estadoInicial = "Recibido";
                        } else {
                            estadoInicial = "Recibido";
                        }
                        
                        if ("servicio".equals(itemType)) {
                            if (itemId == 101) {
                                p.setNotasAdicionales("Servicio: Lavado Simple (" + modalidad + ")");
                            } else if (itemId == 102) {
                                p.setNotasAdicionales("Servicio: Lavado Premium (" + modalidad + ")");
                            } else {
                                p.setNotasAdicionales("Servicio: Restauración (" + modalidad + ")");
                            }
                            estadoInicial = "Recibido";
                        } else {
                            p.setNotasAdicionales("Compra Web (" + modalidad + ")");
                        }

                        p.setEstado(estadoInicial);

                        BigDecimal precioUnitario;
                        String nombreItem;

                        if ("servicio".equals(itemType)) {
                            precioUnitario = BigDecimal.valueOf(15);
                            nombreItem = "Lavado Simple";
                            if (itemId == 102) { precioUnitario = BigDecimal.valueOf(25); nombreItem = "Lavado Premium"; }
                            if (itemId == 103) { precioUnitario = BigDecimal.valueOf(40); nombreItem = "Restauración"; }
                        } else {
                            Productos prod = productoRMI.buscarProductoPorId(itemId);
                            if (prod == null) {
                                errorMessages.append("Producto ID ").append(itemId).append(" no encontrado. ");
                                allOk = false;
                                continue;
                            }
                            precioUnitario = prod.getPrecio();
                            nombreItem = prod.getNombre();
                        }

                        BigDecimal total = precioUnitario.multiply(new BigDecimal(itemQty));
                        p.setMontoTotal(total);
                        p.setMontoPagado("contraentrega".equals(metodoPago) ? BigDecimal.ZERO : total);
                        p.setEstadoPago("contraentrega".equals(metodoPago) ? "Pendiente" : "Pagado");

                        List<DetallePedido> detalles = new ArrayList<>();
                        DetallePedido dp = new DetallePedido();
                        dp.setIdPedido(p);
                        if (!"servicio".equals(itemType)) {
                            dp.setIdProducto(productoRMI.buscarProductoPorId(itemId));
                        }
                        dp.setCantidad(itemQty);
                        dp.setSubtotal(total);
                        dp.setProductoEntregado(false);
                        detalles.add(dp);
                        p.setDetallePedidoList(detalles);

                        List<Pagos> pagos = new ArrayList<>();
                        Pagos pago = new Pagos();
                        pago.setIdPedido(p);
                        pago.setIdCliente(clienteSession.getIdCliente());
                        pago.setMonto(total);
                        pago.setMetodoPago(mapPaymentMethod(metodoPago));
                        pago.setFechaPago(new Date());
                        pagos.add(pago);
                        p.setPagosList(pagos);

                        boolean pedidoOk = pedidoRMI.registrarPedidoWeb(p);

                        if (pedidoOk && "servicio".equals(itemType)) {
                            Citas cita = new Citas();
                            cita.setIdCliente(new Clientes(clienteSession.getIdCliente()));
                            cita.setFechaSolicitud(new Date());
                            cita.setFechaHoraProgramada(new Date());
                            cita.setModalidad(modalidad);
                            cita.setDireccionRecojo(direccion);
                            cita.setEstado("Pendiente");
                            servicioCitaRMI.agendarCita(cita);
                        }

                        if (!pedidoOk) {
                            allOk = false;
                            errorMessages.append("Error al registrar pedido: ").append(nombreItem).append(". ");
                        }
                    } catch (Exception itemEx) {
                        allOk = false;
                        errorMessages.append("Error item ").append(i).append(": ").append(itemEx.getMessage()).append(" ");
                    }
                }

                if (allOk) {
                    out.print("success");
                } else {
                    out.print("error: " + errorMessages.toString());
                }
                return;
            }

            // Legacy single product order
            int idProd = Integer.parseInt(request.getParameter("idProducto"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));
            String direccion = request.getParameter("direccion");
            String modalidad = request.getParameter("modalidad");

            IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
            Productos prod = productoRMI.buscarProductoPorId(idProd);
            BigDecimal total = prod.getPrecio().multiply(new BigDecimal(cantidad));

            Pedidos p = new Pedidos();
            p.setIdCliente(new Clientes(clienteSession.getIdCliente()));
            p.setFechaRecepcion(new Date());
            p.setEstado("Recibido");
            p.setMontoTotal(total);
            p.setMontoPagado(total);
            p.setEstadoPago("Pagado");
            p.setNotasAdicionales("Compra Web (" + modalidad + ")");

            DetallePedido dp = new DetallePedido();
            dp.setIdPedido(p);
            dp.setIdProducto(prod);
            dp.setCantidad(cantidad);
            dp.setSubtotal(total);
            dp.setProductoEntregado(false);

            Pagos pago = new Pagos();
            pago.setIdPedido(p);
            pago.setIdCliente(clienteSession.getIdCliente());
            pago.setMonto(total);
            pago.setMetodoPago("Tarjeta Web");
            pago.setFechaPago(new Date());

            p.setDetallePedidoList(Arrays.asList(dp));
            p.setPagosList(Arrays.asList(pago));

            boolean pedidoOk = pedidoRMI.registrarPedidoWeb(p);

            Citas cita = new Citas();
            cita.setIdCliente(new Clientes(clienteSession.getIdCliente()));
            cita.setFechaSolicitud(new Date());
            cita.setFechaHoraProgramada(new Date());
            cita.setModalidad(modalidad);
            cita.setDireccionRecojo(direccion);
            cita.setEstado("Pendiente");
            
            boolean citaOk = servicioCitaRMI.agendarCita(cita);

            if (pedidoOk && citaOk) {
                out.print("success");
            } else {
                out.print("error: al procesar la compra");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        }
    }

    private String mapPaymentMethod(String metodo) {
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
