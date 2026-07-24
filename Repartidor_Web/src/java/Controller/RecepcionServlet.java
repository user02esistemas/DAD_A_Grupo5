package Controller;

import Interfaces.IGestionPedidosRemoto;
import Interfaces.IGestionClientesRemoto;
import entidades.Clientes;
import entidades.DetallePedido;
import entidades.Empleados;
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
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;

@WebServlet(name = "RecepcionServlet", urlPatterns = {"/RecepcionServlet"})
public class RecepcionServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
            IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");

            String clientIdStr = request.getParameter("clientId");
            String guestName = request.getParameter("guestName");
            String guestPhone = request.getParameter("guestPhone");
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            double total = Double.parseDouble(request.getParameter("total"));
            String notes = request.getParameter("notes");
            String deliveryDateStr = request.getParameter("deliveryDate");

            Pedidos pedido = new Pedidos();

            if (clientIdStr != null && !clientIdStr.isEmpty()) {
                int clientId = Integer.parseInt(clientIdStr);
                pedido.setIdCliente(new Clientes(clientId));
            } else {
                Clientes guest = new Clientes();
                guest.setNombreCompleto(guestName);
                guest.setTelefono(guestPhone);
                pedido.setIdCliente(guest);
            }

            HttpSession session = request.getSession();
            Empleados empleadoLogueado = (Empleados) session.getAttribute("usuario");
            String receptor = (empleadoLogueado != null) ? empleadoLogueado.getNombreCompleto() : "Empleado";
            pedido.setEmpleadoReceptor(receptor);

            pedido.setMontoTotal(BigDecimal.valueOf(total));
            pedido.setMontoPagado(BigDecimal.ZERO);
            pedido.setEstadoPago("Pendiente");
            pedido.setFechaRecepcion(new Date());
            pedido.setEstado("Recibido");

            if (deliveryDateStr != null && !deliveryDateStr.isEmpty()) {
                try {
                    SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy-MM-dd");
                    pedido.setFechaEntregaEstimada(dateFmt.parse(deliveryDateStr));
                } catch (Exception ex) {}
            }

            if (notes != null && !notes.trim().isEmpty()) {
                pedido.setNotasAdicionales("[Recepcion] " + notes);
            }

            DetallePedido detalle = new DetallePedido();
            detalle.setIdPedido(pedido);
            Servicios servicio = new Servicios(serviceId);
            detalle.setIdServicio(servicio);
            detalle.setCantidad(quantity);
            detalle.setSubtotal(BigDecimal.valueOf(total));
            pedido.setDetallePedidoList(Arrays.asList(detalle));

            boolean exito = pedidoRMI.registrarPedidoWeb(pedido);

            if (exito) {
                out.print("success");
            } else {
                out.print("No se pudo registrar el pedido");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("Error: " + e.getMessage());
        }
    }
}
