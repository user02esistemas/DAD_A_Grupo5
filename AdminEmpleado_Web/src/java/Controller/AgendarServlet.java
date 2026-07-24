/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package Controller;

import Interfaces.IGestionPedidosRemoto;
import Interfaces.IGestionServiciosRemoto;
import entidades.Citas;
import entidades.Clientes;
import entidades.DetallePedido;
import entidades.Empleados;
import entidades.Pagos;
import entidades.Pedidos;
import entidades.Servicios;
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
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@WebServlet(name = "AgendarServlet", urlPatterns = {"/AgendarServlet"})
public class AgendarServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
            IGestionServiciosRemoto servicioCitaRMI = (IGestionServiciosRemoto) registry.lookup("servicioCitaServicio");

            String clientType = request.getParameter("clientType");
            String deliveryMode = request.getParameter("deliveryMode");
            String fechaStr = request.getParameter("datetime");
            double total = Double.parseDouble(request.getParameter("total"));
            int idServicio = Integer.parseInt(request.getParameter("serviceType"));
            int cantidad = Integer.parseInt(request.getParameter("quantity"));
            String paymentMethod = request.getParameter("paymentMethod");
            String address = request.getParameter("pickupAddress");

            // Construcción del Pedido (Objeto Limpio)
            Pedidos pedido = new Pedidos();
            if ("registered".equals(clientType)) {
                pedido.setIdCliente(new Clientes(Integer.parseInt(request.getParameter("registeredClientId"))));
            } else {
                Clientes guest = new Clientes();
                guest.setNombreCompleto(request.getParameter("guestName"));
                guest.setTelefono(request.getParameter("guestPhone"));
                pedido.setIdCliente(guest);
            }
            
            pedido.setMontoTotal(BigDecimal.valueOf(total));
            pedido.setFechaRecepcion(new Date());
            pedido.setEstado("delivery".equals(deliveryMode) ? "Pendiente de Recojo" : ("reservation".equals(deliveryMode) ? "Cita Programada" : "Recibido"));
            pedido.setNotasAdicionales("Generado por " + deliveryMode);

            DetallePedido detalle = new DetallePedido();
            detalle.setIdPedido(pedido);
            Servicios servicio = new Servicios(idServicio);
            detalle.setIdServicio(servicio);
            detalle.setCantidad(cantidad);
            detalle.setSubtotal(BigDecimal.valueOf(total));
            pedido.setDetallePedidoList(Arrays.asList(detalle));

            boolean pedidoOk = pedidoRMI.registrarPedidoWeb(pedido);

            if (!"store".equals(deliveryMode)) {
                Citas cita = new Citas();
                cita.setIdCliente(pedido.getIdCliente());
                cita.setFechaHoraProgramada(Timestamp.valueOf(fechaStr));
                cita.setModalidad(deliveryMode);
                cita.setDireccionRecojo(address != null ? address : "En Local");
                cita.setEstado("Pendiente");
                servicioCitaRMI.agendarCita(cita);
            }

            out.print("success");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        }
    }
}