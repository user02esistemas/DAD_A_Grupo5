package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.ConcurrentHashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ComunicacionServlet", urlPatterns = {"/ComunicacionServlet"})
public class ComunicacionServlet extends HttpServlet {

    private static final ConcurrentHashMap<String, List<Map<String, String>>> mensajesGlobales = new ConcurrentHashMap<>();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        String usuario = "";
        
        if (rol == null) rol = "admin";
        
        Object u = session.getAttribute("usuario");
        if (u != null) {
            try {
                java.lang.reflect.Method m = u.getClass().getMethod("getNombreCompleto");
                usuario = (String) m.invoke(u);
                java.lang.reflect.Method mc = u.getClass().getMethod("getCodigoEmpleado");
                usuario = (String) mc.invoke(u);
            } catch (Exception e) {
                usuario = "admin";
            }
        }
        
        List<Map<String, String>> todosMensajes = new ArrayList<>();
        for (List<Map<String, String>> msgs : mensajesGlobales.values()) {
            todosMensajes.addAll(msgs);
        }
        
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        for (Map<String, String> msg : todosMensajes) {
            if (!first) json.append(",");
            first = false;
            json.append("{\"remitente\":\"").append(escapar(msg.getOrDefault("remitente", "")))
                .append("\",\"rol\":\"").append(escapar(msg.getOrDefault("rol", "")))
                .append("\",\"mensaje\":\"").append(escapar(msg.getOrDefault("mensaje", "")))
                .append("\",\"fecha\":\"").append(escapar(msg.getOrDefault("fecha", "")))
                .append("\",\"destino\":\"").append(escapar(msg.getOrDefault("destino", "todos")))
                .append("\"}");
        }
        json.append("]");
        out.print(json.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        String usuario = "";
        
        if (rol == null) rol = "admin";
        
        Object u = session.getAttribute("usuario");
        if (u != null) {
            try {
                java.lang.reflect.Method mc = u.getClass().getMethod("getCodigoEmpleado");
                usuario = (String) mc.invoke(u);
            } catch (Exception e) {
                usuario = "admin";
            }
        }
        
        String mensaje = request.getParameter("mensaje");
        String destino = request.getParameter("destino");
        if (destino == null || destino.isEmpty()) destino = "todos";
        
        if (mensaje != null && !mensaje.trim().isEmpty()) {
            Map<String, String> msg = new java.util.HashMap<>();
            msg.put("remitente", usuario);
            msg.put("rol", rol);
            msg.put("mensaje", mensaje);
            msg.put("destino", destino);
            
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM HH:mm");
            msg.put("fecha", sdf.format(new java.util.Date()));
            
            List<Map<String, String>> lista = mensajesGlobales.computeIfAbsent("global", k -> new ArrayList<>());
            synchronized (lista) {
                lista.add(msg);
                if (lista.size() > 100) {
                    lista.remove(0);
                }
            }
            
            NotificacionWebSocket.notificarChat("admin", usuario, "[" + rol + "] " + usuario + ": " + mensaje);
            NotificacionWebSocket.notificarChat("empleado", usuario, "[" + rol + "] " + usuario + ": " + mensaje);
            NotificacionWebSocket.notificarChat("repartidor", usuario, "[" + rol + "] " + usuario + ": " + mensaje);
            
            out.print("success");
        } else {
            out.print("error");
        }
    }
    
    private String escapar(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
