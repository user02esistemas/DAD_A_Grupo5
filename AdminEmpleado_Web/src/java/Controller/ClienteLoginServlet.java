/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

import Interfaces.IAuthRemoto;
import entidades.Clientes;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

@WebServlet(name = "ClienteLoginServlet", urlPatterns = {"/ClienteLoginServlet"})
public class ClienteLoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        String email = request.getParameter("email");
        String pass = request.getParameter("password");
        
        if (email != null) email = email.trim().toLowerCase();
        if (pass != null) pass = pass.trim();
        
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IAuthRemoto authRMI = (IAuthRemoto) registry.lookup("authServicio");
            Clientes cliente = authRMI.loginCliente(email, pass);

            if (cliente != null) {
                HttpSession session = request.getSession();
                session.setAttribute("cliente", cliente);
                response.sendRedirect("client.jsp");
            } else {
                response.sendRedirect("auth.jsp?view=login&error=invalid_client");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("auth.jsp?view=login&error=server");
        }
    }
}
