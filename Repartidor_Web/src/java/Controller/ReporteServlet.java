/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

import Interfaces.IGestionPedidosRemoto;
import entidades.Pedidos;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet(name = "ReporteServlet", urlPatterns = {"/ReporteServlet"})
public class ReporteServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/vnd.ms-excel");
        response.setHeader("Content-Disposition", "attachment; filename=Reporte_Pedidos.xls");
        PrintWriter out = response.getWriter();
        
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
            List<Pedidos> lista = pedidoRMI.listarTodosPedidos();
            
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            out.println("<html><head><meta charset='UTF-8'></head><body>");
            out.println("<h2>Reporte General de Pedidos</h2><table border='1'>");
            out.println("<tr><th>ID</th><th>Cliente</th><th>Estado</th><th>Monto</th><th>Fecha</th></tr>");
            
            for (Pedidos p : lista) {
                out.println("<tr><td>" + p.getIdPedido() + "</td><td>" + p.getIdCliente().getNombreCompleto() + "</td><td>" + p.getEstado() + "</td><td>" + p.getMontoTotal() + "</td><td>" + sdf.format(p.getFechaRecepcion()) + "</td></tr>");
            }
            out.println("</table></body></html>");
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    }
}
