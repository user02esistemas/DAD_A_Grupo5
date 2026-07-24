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
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@WebServlet(name = "ServicioClienteServlet", urlPatterns = {"/ServicioClienteServlet"})
public class ServicioClienteServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();
        Clientes clienteSession = (Clientes) session.getAttribute("cliente");

        if (clienteSession == null) {
            out.print("error: session");
            return;
        }

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
            IGestionServiciosRemoto servicioCitaRMI = (IGestionServiciosRemoto) registry.lookup("servicioCitaServicio");

            int idServicio = Integer.parseInt(request.getParameter("idServicio"));
            String modalidad = request.getParameter("modalidad");
            String fechaStr = request.getParameter("fecha");
            String horaStr = request.getParameter("hora");
            String direccion = request.getParameter("direccion");
            String metodoPago = request.getParameter("metodoPago");

            String fechaCompletaStr = fechaStr + " " + horaStr;
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Date fechaProgramada = sdf.parse(fechaCompletaStr);

            // Obtener el precio buscando el servicio en la lista remota
            List<Servicios> servicios = servicioCitaRMI.listarServiciosDisponibles();
            Servicios servicio = servicios.stream().filter(s -> s.getIdServicio() == idServicio).findFirst().orElse(new Servicios(idServicio));
            BigDecimal total = servicio.getPrecio() != null ? servicio.getPrecio() : BigDecimal.ZERO;

            Pedidos p = new Pedidos();
            p.setIdCliente(new Clientes(clienteSession.getIdCliente()));
            p.setFechaRecepcion(new Date());
            
            if ("Delivery Recojo".equals(modalidad)) {
                p.setEstado("Pendiente de Recojo");
                p.setNotasAdicionales("Solicitud Web: Recoger en domicilio el " + fechaCompletaStr);
                p.setMontoPagado(total);
                p.setEstadoPago("Pagado");
            } else {
                p.setEstado("Cita Programada");
                p.setNotasAdicionales("Cita Web: Cliente vendrá el " + fechaCompletaStr);
                p.setMontoPagado(BigDecimal.ZERO);
                p.setEstadoPago("Pendiente");
            }
            p.setMontoTotal(total);

            DetallePedido dp = new DetallePedido();
            dp.setIdPedido(p);
            dp.setIdServicio(servicio);
            dp.setCantidad(1);
            dp.setSubtotal(total);
            dp.setProductoEntregado(false);
            p.setDetallePedidoList(Arrays.asList(dp));

            if (!"Pendiente".equals(metodoPago)) {
                Pagos pago = new Pagos();
                pago.setIdPedido(p);
                pago.setIdCliente(clienteSession.getIdCliente());
                pago.setMonto(total);
                pago.setMetodoPago("Tarjeta Web");
                pago.setFechaPago(new Date());
                p.setPagosList(Arrays.asList(pago));
            }

            boolean pedidoOk = pedidoRMI.registrarPedidoWeb(p);

            Citas cita = new Citas();
            cita.setIdCliente(new Clientes(clienteSession.getIdCliente()));
            cita.setFechaSolicitud(new Date());
            cita.setFechaHoraProgramada(fechaProgramada);
            cita.setModalidad(modalidad);
            cita.setDireccionRecojo("En Local".equals(modalidad) ? "Tienda Principal" : direccion);
            cita.setEstado("Confirmada");

            boolean citaOk = servicioCitaRMI.agendarCita(cita);

            if (pedidoOk && citaOk) {
                out.print("success");
            } else {
                out.print("error: en la red RMI");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        }
    }
}
