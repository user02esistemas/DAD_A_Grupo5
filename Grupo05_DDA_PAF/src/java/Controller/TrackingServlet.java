/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package Controller;

import Interfaces.IGestionPedidosRemoto;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
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

            int id = Integer.parseInt(request.getParameter("id"));
            Pedidos p = pedidoRMI.buscarPedidoPorId(id);
            
            if (p != null) {
                String notas = p.getNotasAdicionales() != null ? p.getNotasAdicionales().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "";
                
                String cliente = p.getIdCliente().getNombreCompleto();
                String servicio = "Servicio General";
                if (!p.getDetallePedidoList().isEmpty()) {
                    if(p.getDetallePedidoList().get(0).getIdServicio() != null)
                        servicio = p.getDetallePedidoList().get(0).getIdServicio().getNombre();
                }

                String json = String.format(Locale.US,
                    "{\"id\":%d, \"cliente\":\"%s\", \"servicio\":\"%s\", \"estado\":\"%s\", \"monto\":%.2f, \"notas\":\"%s\"}",
                    p.getIdPedido(), cliente, servicio, p.getEstado(), p.getMontoTotal(), notas
                );
                out.print(json);
            } else {
                out.print("{}");
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
                    String msj = "Tu pedido #" + id + " ha cambiado a estado: " + nuevoEstado;
                    NotificacionWebSocket.notificarCliente(idClienteStr, msj);
                }

                if (metodoPago != null && !metodoPago.isEmpty()) {
                    double monto = 0;
                    try { monto = Double.parseDouble(montoStr); } catch(Exception ex) {}
                    
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
}