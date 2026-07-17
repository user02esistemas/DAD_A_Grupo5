package Controller;

import Interfaces.IGestionServiciosRemoto;
import entidades.Servicios;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.List;

@WebServlet(name = "ServiciosServlet", urlPatterns = {"/ServiciosServlet"})
public class ServiciosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionServiciosRemoto servRMI = (IGestionServiciosRemoto) registry.lookup("servicioCitaServicio");
            
            List<Servicios> lista = servRMI.listarServiciosDisponibles();
            
            StringBuilder json = new StringBuilder();
            json.append("[");
            for (int i = 0; i < lista.size(); i++) {
                Servicios s = lista.get(i);
                
                String nombre = s.getNombre().replace("\"", "\\\"");
                
                json.append("{");
                json.append("\"id\":").append(s.getIdServicio()).append(",");
                json.append("\"nombre\":\"").append(nombre).append("\",");
                json.append("\"precio\":").append(s.getPrecio());
                json.append("}");
                
                if (i < lista.size() - 1) json.append(",");
            }
            json.append("]");
            
            out.print(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"Error de conexion\"}");
        }
    }
}
