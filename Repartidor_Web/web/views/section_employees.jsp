<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionEmpleadosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Empleados" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    List<Empleados> listaEmp = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionEmpleadosRemoto empleadoRMI = (IGestionEmpleadosRemoto) registry.lookup("empleadoServicio");
        listaEmp = empleadoRMI.listarEmpleados();
    } catch(Exception e) {
        System.out.println("Error en empleados: " + e.getMessage());
    }
%>

<section id="employees" class="section">
    <div class="container">
        <div class="page-header">
            <div>
                <h1>Gesti&oacute;n de Empleados</h1>
                <p>Administra el acceso y roles del personal.</p>
            </div>
            <button class="btn btn-primary" onclick="abrirModalNuevoEmpleado()">
                <i class="fas fa-user-plus"></i> Nuevo Empleado
            </button>
        </div>

        <div class="card">
            <div class="card-header">
                <h3>Personal Registrado</h3>
                <input type="text" id="searchEmployee" class="form-input" onkeyup="filtrarEmpleados()" placeholder="Buscar empleado..." style="width: 280px;">
            </div>
            
            <div style="overflow-x: auto;">
                <table class="table">
                    <thead>
                        <tr>
                            <th>C&oacute;digo</th>
                            <th>Nombre Completo</th>
                            <th>Rol / Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="tablaEmpleadosBody">
                        <% for(Empleados e : listaEmp) { 
                           boolean esSuperAdmin = "diegobarturen".equals(e.getCodigoEmpleado());
                        %>
                        <tr>
                            <td>
                                <span style="font-family: 'SF Mono', 'Fira Code', monospace; background: var(--gray-100); padding: 4px 10px; border-radius: 6px; font-size: 13px; font-weight: 500;">
                                    <%= e.getCodigoEmpleado() %>
                                </span>
                            </td>
                            <td><strong><%= e.getNombreCompleto() %></strong></td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <% 
                                        String rolEmp = e.getRol() != null ? e.getRol() : "admin";
                                        String rolBadge = "badge-dark";
                                        if ("empleado".equals(rolEmp)) rolBadge = "badge-info";
                                        if ("repartidor".equals(rolEmp)) rolBadge = "badge-success";
                                    %>
                                    <span class="badge <%= rolBadge %>"><%= rolEmp.toUpperCase() %></span>
                                    <% if(e.getEstado() != null && e.getEstado()) { %>
                                        <span class="badge badge-success"><i class="fas fa-circle" style="font-size: 6px;"></i> Activo</span>
                                    <% } else { %>
                                        <span class="badge badge-danger"><i class="fas fa-circle" style="font-size: 6px;"></i> Inactivo</span>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <% if (esSuperAdmin) { %>
                                    <span class="badge badge-dark"><i class="fas fa-lock"></i> Protegido</span>
                                <% } else { %>
                                    <div style="display: flex; gap: 6px;">
                                        <button class="btn btn-outline btn-sm" onclick="editarEmpleado(<%= e.getIdUsuario() %>)">
                                            <i class="fas fa-pen"></i>
                                        </button>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarEmpleado(<%= e.getIdUsuario() %>, '<%= e.getNombreCompleto() %>')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <div id="modalNuevoEmpleado" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Registrar Personal</h3>
                <button class="modal-close" onclick="document.getElementById('modalNuevoEmpleado').style.display='none'">&times;</button>
            </div>
            <div class="modal-body">
                <form id="formNuevoEmpleado" onsubmit="return false;">
                    <input type="hidden" name="accion" value="crear_empleado">
                    <div class="form-group">
                        <label class="form-label">Nombre Completo</label>
                        <input type="text" name="nombre" class="form-input" required placeholder="Ej: Juan Perez">
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">C&oacute;digo Acceso</label>
                            <input type="text" name="codigo" class="form-input" required placeholder="jperez">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Contrase&ntilde;a</label>
                            <input type="password" name="password" class="form-input" required placeholder="******">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Rol del Personal</label>
                        <select name="rol" class="form-input">
                            <option value="empleado">Empleado</option>
                            <option value="repartidor">Repartidor</option>
                        </select>
                    </div>
                    <button type="button" class="btn btn-primary btn-block" onclick="guardarNuevoEmpleado()" style="margin-top: 8px;">
                        <i class="fas fa-check"></i> Guardar Empleado
                    </button>
                </form>
            </div>
        </div>
    </div>
    
    <div id="modalEmpleado" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Editar Empleado</h3>
                <button class="modal-close" onclick="document.getElementById('modalEmpleado').style.display='none'">&times;</button>
            </div>
            <div class="modal-body">
                <form id="formEmpleado" onsubmit="return false;">
                    <input type="hidden" name="accion" value="actualizar_empleado">
                    <input type="hidden" name="idUsuario" id="empId">
                    <div class="form-group">
                        <label class="form-label">Nombre Completo</label>
                        <input type="text" name="nombre" id="empNombre" class="form-input" required>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">C&oacute;digo Acceso</label>
                            <input type="text" name="codigo" id="empCodigo" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Contrase&ntilde;a</label>
                            <div style="position: relative;">
                                <input type="password" name="password" id="empPass" class="form-input" required style="padding-right: 40px;">
                                <button type="button" onclick="togglePassVis('empPass', this)" style="position: absolute; right: 8px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: var(--gray-500); padding: 4px;"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Rol</label>
                        <select name="rol" id="empRol" class="form-input">
                            <option value="admin">Administrador</option>
                            <option value="empleado">Empleado</option>
                            <option value="repartidor">Repartidor</option>
                        </select>
                    </div>
                    <button type="button" class="btn btn-primary btn-block" onclick="guardarEdicionEmpleado()" style="margin-top: 8px;">
                        <i class="fas fa-save"></i> Actualizar Datos
                    </button>
                </form>
            </div>
        </div>
    </div>
</section>