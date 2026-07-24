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

@WebServlet(name = "RepartidorLoginServlet", urlPatterns = {"/RepartidorLoginServlet"})
public class RepartidorLoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        String codigo = request.getParameter("repCode");
        String pass = request.getParameter("password");
        
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IAuthRemoto authRMI = (IAuthRemoto) registry.lookup("authServicio");
            Empleados empleado = authRMI.loginAdmin(codigo, pass);

            if (empleado != null) {
                HttpSession session = request.getSession();
                session.setAttribute("usuario", empleado);
                session.setAttribute("rol", "repartidor");
                response.sendRedirect("repartidor.jsp");
            } else {
                response.sendRedirect("auth.jsp?view=repartidor&error=invalid");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("auth.jsp?view=repartidor&error=invalid");
        }
    }
}
