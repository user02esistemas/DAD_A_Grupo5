<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionClientesRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Clientes" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<% 
    List<Clientes> listaClientes = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
        List<Clientes> todos = clienteRMI.listarClientes();
        for(Clientes c : todos) {
            if(c.getEmail() != null && !c.getEmail().equals("Sin Email")) {
                listaClientes.add(c);
            }
        }
    } catch(Exception e) { 
        System.out.println("Error en clientes: " + e.getMessage());
    }
%>

<section id="clients" class="section">
    <div class="container">
        <div class="page-header">
            <div>
                <h1>Gesti&oacute;n de Clientes</h1>
                <p>Administra la informaci&oacute;n y contacto de tus clientes.</p>
            </div>
            <button class="btn btn-primary" onclick="abrirModalNuevoCliente()">
                <i class="fas fa-user-plus"></i> Nuevo Cliente
            </button>
        </div>

        <div class="card">
            <div class="card-header">
                <h3>Cartera de Clientes</h3>
                <input type="text" id="searchClient" class="form-input" onkeyup="filtrarClientes()" placeholder="Buscar por nombre o email..." style="width: 280px;">
            </div>
            
            <div style="overflow-x: auto;">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Nombre</th>
                            <th>Contacto</th>
                            <th>Direcci&oacute;n</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="tablaClientesBody">
                        <% for(Clientes c : listaClientes) { %>
                        <tr>
                            <td>
                                <strong><%= c.getNombreCompleto() %></strong>
                                <% if(c.getAptoPromociones() != null && c.getAptoPromociones()) { %>
                                    <span class="badge badge-aqua" style="margin-left: 6px;">Promo</span>
                                <% } %>
                            </td>
                            <td>
                                <div style="font-weight: 500;"><%= c.getEmail() %></div>
                                <div style="font-size: 12px; color: var(--gray-600);"><i class="fas fa-phone-alt"></i> <%= c.getTelefono() %></div>
                            </td>
                            <td style="font-size: 13px; color: var(--gray-600);">
                                <%= (c.getDireccion() != null && !c.getDireccion().isEmpty()) ? c.getDireccion() : "--" %>
                            </td>
                            <td>
                                <div style="display: flex; gap: 6px;">
                                    <button class="btn btn-outline btn-sm" onclick="editarCliente(<%= c.getIdCliente() %>)" title="Editar">
                                        <i class="fas fa-pen"></i>
                                    </button>
                                    <button class="btn btn-danger btn-sm" onclick="eliminarCliente(<%= c.getIdCliente() %>, '<%= c.getNombreCompleto() %>')" title="Eliminar">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="modalNuevoCliente" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Registrar Cliente</h3>
                <button class="modal-close" onclick="document.getElementById('modalNuevoCliente').style.display='none'">&times;</button>
            </div>
            <div class="modal-body">
                <form id="formNuevoCliente" onsubmit="return false;">
                    <input type="hidden" name="accion" value="crear_cliente">
                    <div class="form-group">
                        <label class="form-label">Nombre Completo</label>
                        <input type="text" name="nombre" class="form-input" required placeholder="Ej: Maria Perez">
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Contrase&ntilde;a</label>
                            <input type="password" name="password" class="form-input" required>
                        </div>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Tel&eacute;fono</label>
                            <input type="tel" name="telefono" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">F. Nacimiento</label>
                            <input type="date" name="fecha" class="form-input">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Referido Por (Opcional)</label>
                        <input type="text" name="referido" class="form-input" placeholder="Nombre de quien lo invit&oacute;">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Direcci&oacute;n</label>
                        <textarea name="direccion" class="form-input" rows="2" placeholder="Direcci&oacute;n de entrega..."></textarea>
                    </div>
                    <div class="form-group">
                        <label style="cursor: pointer; display: flex; align-items: center; gap: 10px; padding: 12px; background: var(--gray-50); border-radius: var(--radius-sm); border: 1.5px solid var(--gray-200);">
                            <input type="checkbox" name="promo" checked> 
                            <span style="font-weight: 500; font-size: 14px;">Apto para recibir promociones</span>
                        </label>
                    </div>
                    <button class="btn btn-primary btn-block" onclick="guardarNuevoCliente()">
                        <i class="fas fa-check"></i> Guardar Cliente
                    </button>
                </form>
            </div>
        </div>
    </div>

    <div id="modalEditarCliente" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Editar Cliente</h3>
                <button class="modal-close" onclick="document.getElementById('modalEditarCliente').style.display='none'">&times;</button>
            </div>
            <div class="modal-body">
                <form id="formEditarCliente" onsubmit="return false;">
                    <input type="hidden" name="accion" value="actualizar_cliente">
                    <input type="hidden" id="editId" name="idCliente">
                    <div class="form-group">
                        <label class="form-label">Nombre Completo</label>
                        <input type="text" id="editNombre" name="nombre" class="form-input" required>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" id="editEmail" name="email" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Contrase&ntilde;a</label>
                            <div style="position: relative;">
                                <input type="password" id="editPass" name="password" class="form-input" required style="padding-right: 40px;">
                                <button type="button" onclick="togglePassVis('editPass', this)" style="position: absolute; right: 8px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: var(--gray-500); padding: 4px;"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Tel&eacute;fono</label>
                            <input type="tel" id="editTel" name="telefono" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">F. Nacimiento</label>
                            <input type="date" id="editNac" name="fecha" class="form-input">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Referido Por</label>
                        <input type="text" id="editRef" name="referido" class="form-input">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Direcci&oacute;n</label>
                        <textarea id="editDir" name="direccion" class="form-input" rows="2"></textarea>
                    </div>
                    <div class="form-group">
                        <label style="cursor: pointer; display: flex; align-items: center; gap: 10px; padding: 12px; background: var(--gray-50); border-radius: var(--radius-sm); border: 1.5px solid var(--gray-200);">
                            <input type="checkbox" id="editPromo" name="promo"> 
                            <span style="font-weight: 500; font-size: 14px;">Apto para recibir promociones</span>
                        </label>
                    </div>
                    <button class="btn btn-primary btn-block" onclick="guardarEdicionCliente()">
                        <i class="fas fa-save"></i> Actualizar Datos
                    </button>
                </form>
            </div>
        </div>
    </div>
</section>