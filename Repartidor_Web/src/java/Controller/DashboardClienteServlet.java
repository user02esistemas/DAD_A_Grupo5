package Controller;

import Interfaces.IGestionPedidosRemoto;
import entidades.Clientes;
import entidades.Pedidos;
import entidades.DetallePedido;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.List;
import java.text.SimpleDateFormat;

@WebServlet(name = "DashboardClienteServlet", urlPatterns = {"/DashboardClienteServlet"})
public class DashboardClienteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("cliente") == null) {
            out.print("{\"error\":\"No autenticado\"}");
            return;
        }
        Clientes cliente = (Clientes) session.getAttribute("cliente");
        
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
            
            long activos = pedidoRMI.contarActivosCliente(cliente.getIdCliente());
            long completados = pedidoRMI.contarCompletadosCliente(cliente.getIdCliente());
            java.math.BigDecimal gastado = pedidoRMI.sumarTotalGastadoCliente(cliente.getIdCliente());
            List<Pedidos> recientes = pedidoRMI.listarRecientesCliente(cliente.getIdCliente());
            
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"activos\":").append(activos).append(",");
            json.append("\"completados\":").append(completados).append(",");
            json.append("\"gastado\":").append(gastado).append(",");
            
            json.append("\"recientes\":[");
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            for (int i = 0; i < recientes.size(); i++) {
                Pedidos p = recientes.get(i);
                
                String item = "General";
                if (!p.getDetallePedidoList().isEmpty()) {
                    DetallePedido d = p.getDetallePedidoList().get(0);
                    if (d.getIdProducto() != null) item = d.getIdProducto().getNombre();
                    else if (d.getIdServicio() != null) item = d.getIdServicio().getNombre();
                }
                item = item.replace("\"", "\\\"");
                String estado = p.getEstado().replace("\"", "\\\"");
                
                json.append("{");
                json.append("\"id\":").append(p.getIdPedido()).append(",");
                json.append("\"item\":\"").append(item).append("\",");
                json.append("\"fecha\":\"").append(sdf.format(p.getFechaRecepcion())).append("\",");
                json.append("\"total\":").append(p.getMontoTotal()).append(",");
                json.append("\"estado\":\"").append(estado).append("\"");
                json.append("}");
                if (i < recientes.size() - 1) json.append(",");
            }
            json.append("]");
            json.append("}");
            
            out.print(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"Error de conexion\"}");
        }
    }
}
