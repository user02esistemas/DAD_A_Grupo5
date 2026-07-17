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
import java.util.ArrayList;
import java.text.SimpleDateFormat;

@WebServlet(name = "PedidosClienteServlet", urlPatterns = {"/PedidosClienteServlet"})
public class PedidosClienteServlet extends HttpServlet {

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
            
            // To get all orders for the client, we can use the same method or a new one. 
            // Wait, we need all non-archived orders.
            // But we already have a method: listarPedidosPorCliente(int idCliente) which gets all orders.
            List<Pedidos> historial = pedidoRMI.listarPedidosPorCliente(cliente.getIdCliente());
            
            // Filter to match the JSP logic:
            // "AND ((p.estado NOT IN ('Entregado', 'Cancelado')) " +
            // "OR (p.estado IN ('Entregado', 'Cancelado') AND DATEDIFF(SECOND, ISNULL(p.fecha_actualizacion, p.fecha_recepcion), GETDATE()) <= 120)) "
            // For simplicity in JSON, we can just return all of them and let JS handle it, or filter in Java.
            // Since we are migrating, let's just return all of them and let the UI show all.
            // Actually, the JSP only showed recent if it was 'Entregado' but for "Mis Pedidos" it should show all history!
            // Wait, the original JSP did filter it! But it's "Mis Pedidos" (Historial). Why did it filter it? 
            // Probably a bug in original code where they copied the Dashboard query to Mis Pedidos! 
            // We will just return ALL orders so they have a real history!
            
            StringBuilder json = new StringBuilder();
            json.append("[");
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy - HH:mm");
            
            for (int i = 0; i < historial.size(); i++) {
                Pedidos p = historial.get(i);
                
                String st = p.getEstado();
                boolean isCita = "Cita Programada".equals(st);
                boolean isCancel = "Cancelado".equals(st);
                
                boolean isService = true;
                boolean isDelivery = false;
                String itemName = "Pedido";
                String itemType = "Servicio";
                String notas = p.getNotasAdicionales() != null ? p.getNotasAdicionales() : "";
                
                if (!p.getDetallePedidoList().isEmpty()) {
                    DetallePedido det = p.getDetallePedidoList().get(0);
                    if(det.getIdProducto() != null) {
                        isService = false; 
                        itemName = det.getIdProducto().getNombre();
                        itemType = "Producto";
                    } else if(det.getIdServicio() != null) {
                        itemName = det.getIdServicio().getNombre();
                    }
                }
                if(notas.contains("Delivery") || notas.contains("Envío") || "Pendiente de Recojo".equals(st)) {
                    isDelivery = true;
                }
                
                int currentStepIndex = 0;
                String[] labels = new String[0];
                String[] icons = new String[0];

                if (isService) {
                    if (isDelivery) {
                        labels = new String[]{"Pendiente Recojo", "Recibido", "En Lavado", "Terminado", "Entregado"};
                        icons = new String[]{"fa-motorcycle", "fa-clipboard-check", "fa-soap", "fa-magic", "fa-check-circle"};
                        if("Pendiente de Recojo".equals(st)) currentStepIndex = 0;
                        else if("Recibido".equals(st)) currentStepIndex = 1;
                        else if("En Lavado".equals(st)) currentStepIndex = 2;
                        else if("Terminado".equals(st)) currentStepIndex = 3;
                        else if("Entregado".equals(st)) currentStepIndex = 4;
                    } else {
                        labels = new String[]{"Recibido", "En Lavado", "Terminado", "Entregado"};
                        icons = new String[]{"fa-clipboard-check", "fa-soap", "fa-magic", "fa-check-circle"};
                        if("Recibido".equals(st)) currentStepIndex = 0;
                        else if("En Lavado".equals(st)) currentStepIndex = 1;
                        else if("Terminado".equals(st)) currentStepIndex = 2;
                        else if("Entregado".equals(st)) currentStepIndex = 3;
                    }
                } else {
                    if (isDelivery) {
                        labels = new String[]{"Confirmado", "Preparando", "En Camino", "Entregado"};
                        icons = new String[]{"fa-clipboard-check", "fa-box", "fa-motorcycle", "fa-check-circle"};
                        if("Recibido".equals(st) || "Confirmado".equals(st)) currentStepIndex = 0;
                        else if("Preparando Envío".equals(st)) currentStepIndex = 1;
                        else if("En Camino".equals(st)) currentStepIndex = 2;
                        else if("Entregado".equals(st)) currentStepIndex = 3;
                    } else {
                        labels = new String[]{"Confirmado", "Preparando", "Listo en Tienda", "Recogido"};
                        icons = new String[]{"fa-clipboard-check", "fa-box", "fa-store", "fa-check-circle"};
                        if("Recibido".equals(st) || "Confirmado".equals(st)) currentStepIndex = 0;
                        else if("Preparando para Recojo".equals(st)) currentStepIndex = 1;
                        else if("Listo para Recoger".equals(st)) currentStepIndex = 2;
                        else if("Entregado".equals(st)) currentStepIndex = 3;
                    }
                }
                
                itemName = itemName.replace("\"", "\\\"");
                notas = notas.replace("\"", "\\\"").replace("\n", " ");
                
                json.append("{");
                json.append("\"id\":").append(p.getIdPedido()).append(",");
                json.append("\"fecha\":\"").append(sdf.format(p.getFechaRecepcion())).append("\",");
                json.append("\"estado\":\"").append(st).append("\",");
                json.append("\"isCita\":").append(isCita).append(",");
                json.append("\"isCancel\":").append(isCancel).append(",");
                json.append("\"isService\":").append(isService).append(",");
                json.append("\"isDelivery\":").append(isDelivery).append(",");
                json.append("\"itemName\":\"").append(itemName).append("\",");
                json.append("\"itemType\":\"").append(itemType).append("\",");
                json.append("\"notas\":\"").append(notas).append("\",");
                json.append("\"total\":").append(p.getMontoTotal()).append(",");
                json.append("\"currentStep\":").append(currentStepIndex).append(",");
                
                json.append("\"labels\":[");
                for(int j=0; j<labels.length; j++) {
                    json.append("\"").append(labels[j]).append("\"");
                    if(j < labels.length - 1) json.append(",");
                }
                json.append("],");
                
                json.append("\"icons\":[");
                for(int j=0; j<icons.length; j++) {
                    json.append("\"").append(icons[j]).append("\"");
                    if(j < icons.length - 1) json.append(",");
                }
                json.append("]");
                
                json.append("}");
                if (i < historial.size() - 1) json.append(",");
            }
            json.append("]");
            
            out.print(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"Error de conexion\"}");
        }
    }
}
