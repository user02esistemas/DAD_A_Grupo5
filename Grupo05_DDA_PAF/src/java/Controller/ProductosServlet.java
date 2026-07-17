package Controller;

import Interfaces.IGestionProductosRemoto;
import entidades.Productos;
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

@WebServlet(name = "ProductosServlet", urlPatterns = {"/ProductosServlet"})
public class ProductosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionProductosRemoto prodRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
            
            // To be consistent, if the previous code just did SELECT p FROM Productos p WHERE p.estado=true
            // We can just get all products. Since it's RMI, we probably have a method like listarProductos().
            // Wait, we can fetch from the bean method. 
            List<Productos> lista = prodRMI.listarProductosActivos();
            
            StringBuilder json = new StringBuilder();
            json.append("[");
            for (int i = 0; i < lista.size(); i++) {
                Productos p = lista.get(i);
                
                // Solo productos activos
                if (p.getEstado() != null && !p.getEstado()) {
                    continue;
                }
                
                String nombre = p.getNombre().replace("\"", "\\\"");
                String desc = p.getDescripcion() != null ? p.getDescripcion().replace("\"", "\\\"").replace("\n", " ") : "";
                String img = p.getImagenUrl() != null ? p.getImagenUrl() : "";
                
                json.append("{");
                json.append("\"id\":").append(p.getIdProducto()).append(",");
                json.append("\"nombre\":\"").append(nombre).append("\",");
                json.append("\"descripcion\":\"").append(desc).append("\",");
                json.append("\"precio\":").append(p.getPrecio()).append(",");
                json.append("\"imagen\":\"").append(img).append("\"");
                json.append("}");
                
                if (i < lista.size() - 1) json.append(",");
            }
            
            // Fix trailing comma if any
            String jsonStr = json.toString();
            if (jsonStr.endsWith(",")) {
                jsonStr = jsonStr.substring(0, jsonStr.length() - 1);
            }
            jsonStr += "]";
            
            out.print(jsonStr);
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"Error de conexion\"}");
        }
    }
}
