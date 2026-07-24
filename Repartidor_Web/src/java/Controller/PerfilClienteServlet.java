/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

import Interfaces.IGestionClientesRemoto;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import entidades.Clientes;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "PerfilClienteServlet", urlPatterns = {"/PerfilClienteServlet"})
public class PerfilClienteServlet extends HttpServlet {

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

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
            
            Clientes c = clienteRMI.buscarClientePorId(clienteSession.getIdCliente());
            
            if (c != null) {
                String nombre = request.getParameter("nombre");
                String telefono = request.getParameter("telefono");
                String fechaNac = request.getParameter("fechaNacimiento");
                String pass = request.getParameter("password");
                
                if (telefono != null) {
                    telefono = telefono.replaceAll("[^0-9]", "");
                    if (telefono.length() != 9) {
                        out.print("error: telefono debe tener 9 digitos");
                        return;
                    }
                }
                
                c.setNombreCompleto(nombre);
                c.setTelefono(telefono);
                c.setFechaNacimiento(fechaNac);
                
                if (pass != null && !pass.trim().isEmpty()) {
                    c.setPassword(pass);
                }
                
                boolean exito = clienteRMI.actualizarCliente(c);
                if (exito) {
                    session.setAttribute("cliente", c);
                    out.print("success");
                } else {
                    out.print("error: fallo al actualizar");
                }
            } else {
                out.print("error: cliente no encontrado");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        }
    }
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
        
        Clientes cli = (Clientes) session.getAttribute("cliente");
        
        String nombre = cli.getNombreCompleto() != null ? cli.getNombreCompleto().replace("\"", "\\\"") : "";
        String email = cli.getEmail() != null ? cli.getEmail().replace("\"", "\\\"") : "";
        String telefono = cli.getTelefono() != null ? cli.getTelefono().replace("\"", "\\\"") : "";
        String direccion = cli.getDireccion() != null ? cli.getDireccion() : "";
        String fechaNac = cli.getFechaNacimiento() != null ? cli.getFechaNacimiento() : "";
        
        String direccionVisible = direccion;
        String lat = "";
        String lng = "";
        if (direccion.contains("||")) {
            direccionVisible = direccion.substring(0, direccion.indexOf("||"));
            String coords = direccion.substring(direccion.indexOf("||") + 2);
            String[] parts = coords.split(",");
            if (parts.length == 2) {
                lat = parts[0].trim();
                lng = parts[1].trim();
            }
        }
        direccionVisible = direccionVisible.replace("\"", "\\\"");
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"nombre\":\"").append(nombre).append("\",");
        json.append("\"email\":\"").append(email).append("\",");
        json.append("\"telefono\":\"").append(telefono).append("\",");
        json.append("\"direccion\":\"").append(direccionVisible).append("\",");
        json.append("\"lat\":\"").append(lat).append("\",");
        json.append("\"lng\":\"").append(lng).append("\",");
        json.append("\"fechaNacimiento\":\"").append(fechaNac).append("\"");
        json.append("}");
        
        out.print(json.toString());
    }
}
