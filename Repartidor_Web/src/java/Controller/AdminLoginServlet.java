package Controller;

import Interfaces.IAuthRemoto;
import entidades.Empleados;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

@WebServlet(name = "AdminLoginServlet", urlPatterns = {"/AdminLoginServlet"})
public class AdminLoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        String codigo = request.getParameter("adminCode");
        String pass = request.getParameter("password");
        
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IAuthRemoto authRMI = (IAuthRemoto) registry.lookup("authServicio");
            Empleados empleado = authRMI.loginAdmin(codigo, pass);

            if (empleado != null) {
                HttpSession session = request.getSession();
                session.setAttribute("usuario", empleado);
                session.setAttribute("rol", empleado.getRol());
                
                String rol = empleado.getRol();
                if (rol == null) rol = "admin";
                
                switch (rol.toLowerCase()) {
                    case "repartidor":
                        response.sendRedirect("repartidor.jsp");
                        break;
                    case "empleado":
                        response.sendRedirect("empleado.jsp");
                        break;
                    default:
                        response.sendRedirect("admin.jsp?view=dashboard");
                        break;
                }
            } else {
                response.sendRedirect("auth.jsp?view=admin&error=invalid");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("auth.jsp?view=admin&error=invalid");
        }
    }
}
