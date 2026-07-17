/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
import java.util.Arrays;
import java.util.Date;

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
                if (exito) {
                    out.print("success");
                } else {
                    out.print("error: no se pudo cancelar");
                }
            } else {
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
                p.setEstado("Delivery".equals(modalidad) ? "Preparando Envío" : "Preparando para Recojo");
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
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        }
    }
}