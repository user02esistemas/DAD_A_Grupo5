package Controller;

import Interfaces.IGestionClientesRemoto;
import Interfaces.IGestionPedidosRemoto;
import entidades.Clientes;
import entidades.Pedidos;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@WebServlet(name = "EmpClienteServlet", urlPatterns = {"/EmpClienteServlet"})
public class EmpClienteServlet extends HttpServlet {

    private static final ConcurrentHashMap<Integer, List<BonoRecord>> bonosMap = new ConcurrentHashMap<>();
    private static final AtomicInteger bonoIdGen = new AtomicInteger(1);

    public static class BonoRecord {
        public int id;
        public int idCliente;
        public String clienteNombre;
        public int puntos;
        public String tipo;
        public String motivo;
        public String descripcion;
        public String empleadoNombre;
        public Date fecha;

        public BonoRecord(int id, int idCliente, String clienteNombre, int puntos, String tipo, String motivo, String descripcion, String empleadoNombre, Date fecha) {
            this.id = id;
            this.idCliente = idCliente;
            this.clienteNombre = clienteNombre;
            this.puntos = puntos;
            this.tipo = tipo;
            this.motivo = motivo;
            this.descripcion = descripcion;
            this.empleadoNombre = empleadoNombre;
            this.fecha = fecha;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
            String accion = request.getParameter("accion");

            if ("buscar_cliente".equals(accion)) {
                String query = request.getParameter("q").trim().toLowerCase();
                List<Clientes> todos = clienteRMI.listarClientes();
                StringBuilder json = new StringBuilder("[");

                boolean first = true;
                for (Clientes c : todos) {
                    String nombre = c.getNombreCompleto() != null ? c.getNombreCompleto().toLowerCase() : "";
                    String tel = c.getTelefono() != null ? c.getTelefono() : "";
                    String email = c.getEmail() != null ? c.getEmail().toLowerCase() : "";

                    if (nombre.contains(query) || tel.contains(query) || email.contains(query)) {
                        if (!first) json.append(",");
                        first = false;

                        int totalBonos = getTotalBonos(c.getIdCliente());
                        json.append("{");
                        json.append("\"id\":").append(c.getIdCliente());
                        json.append(",\"nombre\":\"").append(escapeJson(c.getNombreCompleto()));
                        json.append("\",\"telefono\":\"").append(escapeJson(tel));
                        json.append("\",\"email\":\"").append(escapeJson(email));
                        json.append("\",\"puntos\":").append(totalBonos);
                        json.append("}");
                    }
                }
                json.append("]");
                out.print(json.toString());

            } else if ("listar_bonos".equals(accion)) {
                int idCliente = Integer.parseInt(request.getParameter("idCliente"));
                List<BonoRecord> bonos = bonosMap.getOrDefault(idCliente, new ArrayList<>());

                StringBuilder json = new StringBuilder("[");
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                boolean first = true;

                for (BonoRecord b : bonos) {
                    if (!first) json.append(",");
                    first = false;
                    json.append("{");
                    json.append("\"id\":").append(b.id);
                    json.append(",\"puntos\":").append(b.puntos);
                    json.append(",\"tipo\":\"").append(escapeJson(b.tipo));
                    json.append("\",\"motivo\":\"").append(escapeJson(b.motivo));
                    json.append("\",\"descripcion\":\"").append(escapeJson(b.descripcion));
                    json.append("\",\"empleado\":\"").append(escapeJson(b.empleadoNombre));
                    json.append("\",\"fecha\":\"").append(sdf.format(b.fecha));
                    json.append("}");
                }
                json.append("]");
                out.print(json.toString());

            } else if ("resumen_bonos".equals(accion)) {
                int idCliente = Integer.parseInt(request.getParameter("idCliente"));
                int total = getTotalBonos(idCliente);
                String nivel = "Bronce";
                if (total >= 500) nivel = "Platino";
                else if (total >= 200) nivel = "Oro";
                else if (total >= 50) nivel = "Plata";

                out.print("{\"puntos\":" + total + ",\"nivel\":\"" + nivel + "\"}");

            } else if ("listar_todos_clientes".equals(accion)) {
                List<Clientes> todos = clienteRMI.listarClientes();
                StringBuilder json = new StringBuilder("[");
                boolean first = true;
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

                for (Clientes c : todos) {
                    if (!first) json.append(",");
                    first = false;

                    int totalBonos = getTotalBonos(c.getIdCliente());
                    json.append("{");
                    json.append("\"id\":").append(c.getIdCliente());
                    json.append(",\"nombre\":\"").append(escapeJson(c.getNombreCompleto()));
                    json.append("\",\"telefono\":\"").append(escapeJson(c.getTelefono() != null ? c.getTelefono() : ""));
                    json.append("\",\"email\":\"").append(escapeJson(c.getEmail() != null ? c.getEmail() : ""));
                    json.append(",\"puntos\":").append(totalBonos);
                    json.append("}");
                }
                json.append("]");
                out.print(json.toString());
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();
        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");

            if ("registrar_cliente_rapido".equals(accion)) {
                String nombre = request.getParameter("nombre");
                String telefono = request.getParameter("telefono");
                String email = request.getParameter("email");
                String direccion = request.getParameter("direccion");

                if (nombre == null || nombre.trim().isEmpty()) {
                    out.print("error: nombre requerido");
                    return;
                }

                Clientes c = new Clientes();
                c.setNombreCompleto(nombre.trim());
                c.setTelefono(telefono != null && !telefono.trim().isEmpty() ? telefono.trim() : "Sin Teléfono");
                c.setEmail((email != null && !email.trim().isEmpty()) ? email.trim().toLowerCase() : nombre.trim().toLowerCase().replace(" ", ".") + "@newone.local");
                c.setPassword("newone123");
                c.setDireccion(direccion != null && !direccion.trim().isEmpty() ? direccion.trim() : "Sin Dirección");
                c.setReferidoPor("Registro en Tienda");
                c.setCodigoReferido("N/A");
                c.setFechaRegistro(new Date());
                c.setAptoPromociones(true);

                boolean exito = clienteRMI.registrarCliente(c);
                out.print(exito ? "success" : "error: no se pudo registrar");

            } else if ("asignar_bono".equals(accion)) {
                int idCliente = Integer.parseInt(request.getParameter("idCliente"));
                int puntos = Integer.parseInt(request.getParameter("puntos"));
                String motivo = request.getParameter("motivo");
                String tipo = request.getParameter("tipo");
                if (tipo == null || tipo.isEmpty()) tipo = "puntos";

                if (puntos <= 0) {
                    out.print("error: puntos deben ser mayores a 0");
                    return;
                }

                Clientes cliente = clienteRMI.buscarClientePorId(idCliente);
                if (cliente == null) {
                    out.print("error: cliente no encontrado");
                    return;
                }

                HttpSession session = request.getSession();
                entidades.Empleados emp = (entidades.Empleados) session.getAttribute("usuario");
                String empNombre = emp != null ? emp.getNombreCompleto() : "Empleado";

                String descripcion = "";
                if ("descuento".equals(tipo)) {
                    descripcion = puntos + "% de descuento";
                } else if ("lavado_gratis".equals(tipo)) {
                    descripcion = "Lavado Simple gratis (S/15)";
                    puntos = 15;
                } else if ("upgrade_gratis".equals(tipo)) {
                    descripcion = "Upgrade a Premium gratis (S/10)";
                    puntos = 10;
                } else {
                    descripcion = puntos + " puntos de fidelidad";
                }

                if (motivo == null || motivo.trim().isEmpty()) {
                    if ("descuento".equals(tipo)) motivo = "Descuento por consumo";
                    else if ("lavado_gratis".equals(tipo)) motivo = "Lavado Simple gratis";
                    else if ("upgrade_gratis".equals(tipo)) motivo = "Upgrade a Premium gratis";
                    else motivo = "Bono por consumo";
                }

                BonoRecord bono = new BonoRecord(
                    bonoIdGen.getAndIncrement(),
                    idCliente,
                    cliente.getNombreCompleto(),
                    puntos,
                    tipo,
                    motivo,
                    descripcion,
                    empNombre,
                    new Date()
                );

                bonosMap.computeIfAbsent(idCliente, k -> new ArrayList<>()).add(bono);

                out.print("success");

            } else if ("eliminar_bono".equals(accion)) {
                int idCliente = Integer.parseInt(request.getParameter("idCliente"));
                int idBono = Integer.parseInt(request.getParameter("idBono"));

                List<BonoRecord> bonos = bonosMap.get(idCliente);
                if (bonos != null) {
                    bonos.removeIf(b -> b.id == idBono);
                }
                out.print("success");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        }
    }

    private int getTotalBonos(int idCliente) {
        List<BonoRecord> bonos = bonosMap.get(idCliente);
        if (bonos == null) return 0;
        int total = 0;
        for (BonoRecord b : bonos) {
            total += b.puntos;
        }
        return total;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}