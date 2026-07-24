/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Controller;

import Interfaces.IGestionClientesRemoto;
import Interfaces.IGestionEmpleadosRemoto;
import Interfaces.IGestionProductosRemoto;
import entidades.Clientes;
import entidades.Empleados;
import entidades.Productos;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.Date;

@WebServlet(name = "GestionServlet", urlPatterns = {"/GestionServlet"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class GestionServlet extends HttpServlet {

    // Método auxiliar para obtener el registro RMI fácilmente
    private Registry getRMIRegistry() throws Exception {
        return LocateRegistry.getRegistry("127.0.0.1", 3239);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            Registry registry = getRMIRegistry();

            if ("get_empleado".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                IGestionEmpleadosRemoto empleadoRMI = (IGestionEmpleadosRemoto) registry.lookup("empleadoServicio");
                Empleados e = empleadoRMI.buscarEmpleadoPorId(id);
                
                if (e != null) {
                    String empRol = e.getRol() != null ? e.getRol() : "admin";
                    out.print(String.format("{\"id\":%d, \"nombre\":\"%s\", \"codigo\":\"%s\", \"pass\":\"%s\", \"rol\":\"%s\"}",
                            e.getIdUsuario(), e.getNombreCompleto(), e.getCodigoEmpleado(), e.getPassword(), empRol));
                }
                
            } else if ("get_cliente".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
                Clientes c = clienteRMI.buscarClientePorId(id);
                
                if (c != null) {
                    String dir = c.getDireccion() != null ? c.getDireccion() : "";
                    String nac = c.getFechaNacimiento() != null ? c.getFechaNacimiento() : "";
                    String ref = c.getReferidoPor() != null ? c.getReferidoPor() : "";
                    String pass = c.getPassword() != null ? c.getPassword() : "";
                    boolean promo = c.getAptoPromociones() != null && c.getAptoPromociones();
                    String json = String.format(
                        "{\"id\":%d, \"nombre\":\"%s\", \"email\":\"%s\", \"pass\":\"%s\", \"tel\":\"%s\", \"dir\":\"%s\", \"nac\":\"%s\", \"ref\":\"%s\", \"promo\":%b}",
                        c.getIdCliente(), c.getNombreCompleto(), c.getEmail(), pass, c.getTelefono(), dir, nac, ref, promo
                    );
                    out.print(json);
                }
                
            } else if ("get_producto".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
                Productos p = productoRMI.buscarProductoPorId(id);
                
                if (p != null) {
                    String json = String.format("{\"id\":%d, \"nombre\":\"%s\", \"desc\":\"%s\", \"precio\":%.2f, \"stock\":%d, \"imagen\":\"%s\"}",
                            p.getIdProducto(), p.getNombre(), p.getDescripcion(), p.getPrecio(), p.getStock(), p.getImagenUrl());
                    out.print(json);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        boolean exito = false;

        try {
            Registry registry = getRMIRegistry();

            // ==========================================
            // GESTIÓN DE EMPLEADOS
            // ==========================================
            if ("crear_empleado".equals(accion) || "actualizar_empleado".equals(accion)) {
                IGestionEmpleadosRemoto empleadoRMI = (IGestionEmpleadosRemoto) registry.lookup("empleadoServicio");
                Empleados e = new Empleados();
                
                e.setNombreCompleto(request.getParameter("nombre"));
                e.setCodigoEmpleado(request.getParameter("codigo"));
                e.setPassword(request.getParameter("password"));
                
                String rolParam = request.getParameter("rol");
                if (rolParam == null || rolParam.isEmpty()) rolParam = "admin";
                
                if ("crear_empleado".equals(accion)) {
                    e.setRol(rolParam);
                    e.setEstado(true);
                    e.setFechaCreacion(new Date());
                    exito = empleadoRMI.registrarEmpleado(e);
                } else {
                    int id = Integer.parseInt(request.getParameter("idUsuario"));
                    e.setIdUsuario(id);
                    // Para evitar nulos en la actualización de RMI, recuperamos los datos que no cambian
                    Empleados original = empleadoRMI.buscarEmpleadoPorId(id);
                    e.setRol(rolParam);
                    e.setEstado(original.getEstado());
                    e.setFechaCreacion(original.getFechaCreacion());
                    
                    exito = empleadoRMI.actualizarEmpleado(e);
                }
                
                if(exito) {
                    response.getWriter().write("success");
                } else {
                    response.getWriter().write("error");
                }

            } else if ("eliminar_empleado".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                IGestionEmpleadosRemoto empleadoRMI = (IGestionEmpleadosRemoto) registry.lookup("empleadoServicio");
                if (empleadoRMI.eliminarEmpleado(id)) response.getWriter().write("success");

            // ==========================================
            // GESTIÓN DE CLIENTES
            // ==========================================
            } else if ("crear_cliente".equals(accion) || "actualizar_cliente".equals(accion)) {
                IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
                Clientes c = new Clientes();
                
                c.setNombreCompleto(request.getParameter("nombre"));
                c.setEmail(request.getParameter("email"));
                c.setPassword(request.getParameter("password"));
                c.setTelefono(request.getParameter("telefono"));
                c.setDireccion(request.getParameter("direccion"));
                c.setFechaNacimiento(request.getParameter("fecha"));
                c.setAptoPromociones(request.getParameter("promo") != null);
                
                if ("crear_cliente".equals(accion)) {
                    String ref = request.getParameter("referido");
                    c.setReferidoPor((ref != null && !ref.trim().isEmpty()) ? ref : "Ninguno");
                    c.setCodigoReferido("N/A");
                    c.setFechaRegistro(new Date());
                    exito = clienteRMI.registrarCliente(c);
                } else {
                    int id = Integer.parseInt(request.getParameter("idCliente"));
                    c.setIdCliente(id);
                    c.setReferidoPor(request.getParameter("referido"));
                    
                    Clientes original = clienteRMI.buscarClientePorId(id);
                    c.setCodigoReferido(original.getCodigoReferido());
                    c.setFechaRegistro(original.getFechaRegistro());
                    
                    exito = clienteRMI.actualizarCliente(c);
                }
                
                if(exito) {
                    response.getWriter().write("success");
                } else {
                    response.getWriter().write("error");
                }

            } else if ("eliminar_cliente".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
                if (clienteRMI.eliminarCliente(id)) response.getWriter().write("success");

            // ==========================================
            // GESTIÓN DE PRODUCTOS
            // ==========================================
            } else if ("nuevo_producto".equals(accion) || "actualizar_producto".equals(accion)) {
                IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
                Productos p = new Productos();
                
                p.setNombre(request.getParameter("nombre"));
                p.setDescripcion(request.getParameter("desc"));
                p.setPrecio(BigDecimal.valueOf(Math.max(0.0, Double.parseDouble(request.getParameter("precio")))));
                p.setStock(Math.max(0, Integer.parseInt(request.getParameter("stock"))));
                p.setEstado(true);

                // Lógica original de Diego para guardar la imagen en el servidor Web
                Part filePart = request.getPart("imagenFile");
                String fileName = filePart.getSubmittedFileName();
                if (fileName != null && !fileName.isEmpty()) {
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdir();
                    filePart.write(uploadPath + File.separator + fileName);
                    p.setImagenUrl("uploads/" + fileName);
                } else if ("nuevo_producto".equals(accion)) {
                    p.setImagenUrl("https://via.placeholder.com/150");
                } else {
                    // Si se actualiza y no hay imagen nueva, conservamos la que ya tenía
                    int id = Integer.parseInt(request.getParameter("idProducto"));
                    p.setImagenUrl(productoRMI.buscarProductoPorId(id).getImagenUrl());
                }

                if ("nuevo_producto".equals(accion)) {
                    exito = productoRMI.registrarProducto(p);
                } else {
                    p.setIdProducto(Integer.parseInt(request.getParameter("idProducto")));
                    exito = productoRMI.actualizarProducto(p);
                }
                
                if(exito) response.sendRedirect("admin.jsp?view=products");

            } else if ("eliminar_producto".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("id"));
                IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
                // Ahora esto hace una eliminación FÍSICA gracias al DAO de Producto que creamos
                if (productoRMI.eliminarProducto(id)) response.getWriter().write("success");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("error: " + e.getMessage());
        }
    }
}