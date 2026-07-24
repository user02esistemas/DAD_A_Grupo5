package Controller;

import Interfaces.IGestionPedidosRemoto;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import entidades.Clientes;
import entidades.DetallePedido;
import entidades.Empleados;
import entidades.Pagos;
import entidades.Pedidos;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "TrackingServlet", urlPatterns = {"/TrackingServlet"})
public class TrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");

            String accion = request.getParameter("accion");

            if ("listar_pedidos".equals(accion)) {
                List<Pedidos> todos = pedidoRMI.listarTodosPedidos();
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

                StringBuilder json = new StringBuilder();
                json.append("{");

                StringBuilder serviciosArr = new StringBuilder("[");
                StringBuilder deliveryArr = new StringBuilder("[");
                StringBuilder recojoArr = new StringBuilder("[");

                int countServ = 0, countDel = 0, countRec = 0;

                for (Pedidos p : todos) {
                    String estado = p.getEstado();
                    if ("Cancelado".equals(estado)) continue;

                    String cliente = "";
                    if (p.getIdCliente() != null) {
                        cliente = p.getIdCliente().getNombreCompleto();
                    }

                    String servicio = "";
                    String producto = "";
                    boolean hasServicio = false;
                    boolean hasProducto = false;
                    boolean isDelivery = false;

                    if (p.getDetallePedidoList() != null && !p.getDetallePedidoList().isEmpty()) {
                        DetallePedido det = p.getDetallePedidoList().get(0);
                        if (det.getIdServicio() != null) {
                            hasServicio = true;
                            servicio = det.getIdServicio().getNombre();
                        }
                        if (det.getIdProducto() != null) {
                            hasProducto = true;
                            producto = det.getIdProducto().getNombre();
                        }
                    }

                    String notas = p.getNotasAdicionales() != null ? p.getNotasAdicionales() : "";
                    if (notas.contains("Delivery") || notas.contains("delivery") || notas.contains("Envío")) {
                        isDelivery = true;
                    }

                    String badgeClass = getBadgeClass(estado);

                    StringBuilder item = new StringBuilder();
                    item.append("{\"id\":").append(p.getIdPedido());
                    item.append(",\"cliente\":\"").append(escapeJson(cliente));
                    item.append("\",\"servicio\":\"").append(escapeJson(servicio));
                    item.append("\",\"producto\":\"").append(escapeJson(producto));
                    item.append("\",\"estado\":\"").append(escapeJson(estado));
                    item.append("\",\"estadoBadge\":\"").append(badgeClass);
                    item.append("\",\"fecha\":\"").append(sdf.format(p.getFechaRecepcion()));
                    item.append("\",\"monto\":").append(p.getMontoTotal());
                    item.append("}");

                    if (hasServicio) {
                        if (countServ > 0) serviciosArr.append(",");
                        serviciosArr.append(item);
                        countServ++;
                    } else if (hasProducto) {
                        if (isDelivery) {
                            if (countDel > 0) deliveryArr.append(",");
                            deliveryArr.append(item);
                            countDel++;
                        } else {
                            if (countRec > 0) recojoArr.append(",");
                            recojoArr.append(item);
                            countRec++;
                        }
                    }
                }

                serviciosArr.append("]");
                deliveryArr.append("]");
                recojoArr.append("]");

                json.append("\"servicios\":").append(serviciosArr).append(",");
                json.append("\"delivery\":").append(deliveryArr).append(",");
                json.append("\"recojo\":").append(recojoArr);
                json.append("}");

                out.print(json.toString());

            } else {
                int id = Integer.parseInt(request.getParameter("id"));
                Pedidos p = pedidoRMI.buscarPedidoPorId(id);

                if (p != null) {
                    String notas = p.getNotasAdicionales() != null ? p.getNotasAdicionales().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "";
                    String cliente = p.getIdCliente() != null ? p.getIdCliente().getNombreCompleto() : "";
                    String servicio = "Servicio General";
                    if (!p.getDetallePedidoList().isEmpty()) {
                        if (p.getDetallePedidoList().get(0).getIdServicio() != null)
                            servicio = p.getDetallePedidoList().get(0).getIdServicio().getNombre();
                        else if (p.getDetallePedidoList().get(0).getIdProducto() != null)
                            servicio = p.getDetallePedidoList().get(0).getIdProducto().getNombre();
                    }

                    String json = String.format(Locale.US,
                        "{\"id\":%d, \"cliente\":\"%s\", \"servicio\":\"%s\", \"estado\":\"%s\", \"monto\":%.2f, \"notas\":\"%s\"}",
                        p.getIdPedido(), cliente, servicio, p.getEstado(), p.getMontoTotal(), notas
                    );
                    out.print(json);
                } else {
                    out.print("{}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");

            String idStr = request.getParameter("idPedido");
            String nuevoEstado = request.getParameter("nuevoEstado");
            String notaAgregada = request.getParameter("nuevaNota");
            String metodoPago = request.getParameter("paymentMethod");
            String montoStr = request.getParameter("montoPago");

            int id = Integer.parseInt(idStr);
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM HH:mm");

            String notaParaRMI = "";
            if (notaAgregada != null && !notaAgregada.trim().isEmpty()) {
                notaParaRMI = "[" + sdf.format(new Date()) + "]: " + notaAgregada;
            }

            boolean exitoPedido = pedidoRMI.actualizarEstadoPedido(id, nuevoEstado, notaParaRMI);

            if (exitoPedido) {
                Pedidos p = pedidoRMI.buscarPedidoPorId(id);
                if (p != null && p.getIdCliente() != null) {
                    String idClienteStr = String.valueOf(p.getIdCliente().getIdCliente());
                    String tipoNotif;
                    String msj;

                    if ("Entregado".equals(nuevoEstado)) {
                        tipoNotif = "pedido_entregado";
                        msj = "Tu pedido #" + id + " ha sido entregado correctamente.";
                    } else if ("Cancelado".equals(nuevoEstado)) {
                        tipoNotif = "pedido_cancelado";
                        msj = "Tu pedido #" + id + " ha sido cancelado.";
                    } else {
                        tipoNotif = "pedido_estado";
                        msj = "Tu pedido #" + id + " ha cambiado a estado: " + nuevoEstado;
                    }

                    NotificacionWebSocket.notificarCliente(idClienteStr, tipoNotif, msj, id);
                }

                if (metodoPago != null && !metodoPago.isEmpty()) {
                    double monto = 0;
                    try { monto = Double.parseDouble(montoStr); } catch (Exception ex) {}

                    HttpSession session = request.getSession();
                    Empleados empleadoLogueado = (Empleados) session.getAttribute("usuario");
                    int idEmpleado = (empleadoLogueado != null) ? empleadoLogueado.getIdUsuario() : 1;

                    Pagos pago = new Pagos();
                    pago.setIdPedido(p);
                    pago.setIdCliente(p.getIdCliente().getIdCliente());
                    pago.setIdEmpleado(idEmpleado);
                    pago.setMonto(BigDecimal.valueOf(monto));
                    pago.setMetodoPago(metodoPago);
                    pago.setFechaPago(new Date());

                    pedidoRMI.registrarPago(pago);
                }

                out.print("success");
            } else {
                out.print("error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        }
    }

    private String getBadgeClass(String estado) {
        if (estado == null) return "badge-dark";
        switch (estado) {
            case "Recibido": return "badge-info";
            case "En Lavado": return "badge-warning";
            case "Terminado": return "badge-success";
            case "Cita Programada": return "badge-purple";
            case "Pendiente de Recojo": return "badge-purple";
            case "En Camino": return "badge-warning";
            case "Preparando Envío": return "badge-info";
            case "Preparando para Recojo": return "badge-info";
            case "Listo para Recoger": return "badge-success";
            case "Entregado": return "badge-dark";
            case "Cancelado": return "badge-danger";
            default: return "badge-dark";
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}