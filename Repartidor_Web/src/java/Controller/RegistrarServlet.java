/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

import Interfaces.IGestionClientesRemoto;
import entidades.Clientes;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.Date;

@WebServlet(name = "RegistrarServlet", urlPatterns = {"/RegistrarServlet"})
public class RegistrarServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        request.setCharacterEncoding("UTF-8");
        
        String nombre = request.getParameter("nombre");
        if (nombre == null) nombre = request.getParameter("fullname");
        String email = request.getParameter("email");
        String pass = request.getParameter("password");
        String telefono = request.getParameter("telefono");
        if (telefono == null) telefono = request.getParameter("phone");
        String fechaNac = request.getParameter("fechaNacimiento");
        if (fechaNac == null) fechaNac = request.getParameter("dob");
        String direccion = request.getParameter("direccion");
        if (direccion == null) direccion = request.getParameter("address");
        String referido = request.getParameter("referido");
        if (referido == null) referido = request.getParameter("referred");
        String lat = request.getParameter("lat");
        String lng = request.getParameter("lng");

        if (nombre == null || email == null || pass == null) {
            response.sendRedirect("auth.jsp?view=register&error=empty_fields");
            return;
        }

        email = email.trim().toLowerCase();
        pass = pass.trim();

        if (telefono != null) {
            telefono = telefono.replaceAll("[^0-9]", "");
            if (telefono.length() != 9) {
                response.sendRedirect("auth.jsp?view=register&error=invalid_phone");
                return;
            }
        }

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");

            Clientes c = new Clientes();
            c.setNombreCompleto(nombre);
            c.setEmail(email);
            c.setPassword(pass);
            c.setTelefono(telefono != null ? telefono : "Sin Teléfono");
            
            String direccionFinal = (direccion != null && !direccion.trim().isEmpty()) ? direccion : "Sin Dirección";
            if (lat != null && !lat.trim().isEmpty() && lng != null && !lng.trim().isEmpty()) {
                direccionFinal = direccionFinal + "||" + lat.trim() + "," + lng.trim();
            }
            c.setDireccion(direccionFinal);
            c.setFechaNacimiento(fechaNac);
            c.setReferidoPor((referido != null && !referido.trim().isEmpty()) ? referido : "Ninguno");
            c.setFechaRegistro(new Date());
            c.setCodigoReferido("N/A");
            c.setAptoPromociones(true);

            boolean exito = clienteRMI.registrarCliente(c);

            if (exito) {
                response.sendRedirect("auth.jsp?view=login&status=registered");
            } else {
                response.sendRedirect("auth.jsp?view=register&error=server");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("auth.jsp?view=register&error=server");
        }
    }
}
