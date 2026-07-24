<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionPedidosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Pedidos, entidades.DetallePedido" %>
<%@ page import="java.util.List, java.util.ArrayList, java.text.SimpleDateFormat" %>

<%
    List<Pedidos> pedidosActivos = new ArrayList<>();
    List<Pedidos> pedidosTerminados = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
        List<Pedidos> todos = pedidoRMI.listarTodosPedidos();
        for (Pedidos p : todos) {
            String st = p.getEstado();
            if (st == null) continue;
            if (st.equals("Entregado") || st.equals("Cancelado")) {
                pedidosTerminados.add(p);
            } else {
                pedidosActivos.add(p);
            }
        }
    } catch(Exception e) {}
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM HH:mm");
%>

<style>
    .cola-layout { display: grid; grid-template-columns: 1fr 340px; gap: 24px; align-items: start; }
    .cola-kanban { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
    .cola-column {
        background: var(--gray-50);
        border-radius: var(--radius-lg);
        padding: 16px;
        min-height: 200px;
    }
    .cola-column-header {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 14px;
        padding-bottom: 10px;
        border-bottom: 2px solid var(--gray-200);
    }
    .cola-column-header .dot {
        width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0;
    }
    .cola-column-header h4 { margin: 0; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }
    .cola-column-header .count {
        background: var(--gray-200); border-radius: var(--radius-full);
        padding: 2px 8px; font-size: 11px; font-weight: 700; color: var(--gray-600);
    }

    .cola-card {
        background: var(--white);
        border-radius: var(--radius-md);
        padding: 14px;
        margin-bottom: 10px;
        box-shadow: var(--shadow-xs);
        border: 1px solid var(--gray-200);
        cursor: pointer;
        transition: all 0.2s;
    }
    .cola-card:hover { box-shadow: var(--shadow-sm); transform: translateY(-1px); }
    .cola-card-id { font-weight: 800; color: #2563eb; font-size: 13px; }
    .cola-card-client { font-weight: 600; font-size: 13px; margin: 4px 0 2px; }
    .cola-card-service { color: var(--gray-500); font-size: 12px; }
    .cola-card-meta {
        display: flex; justify-content: space-between; align-items: center;
        margin-top: 8px; padding-top: 8px; border-top: 1px solid var(--gray-100);
    }
    .cola-card-date { font-size: 11px; color: var(--gray-400); }
    .cola-card-badge {
        padding: 3px 8px; border-radius: var(--radius-full); font-size: 10px;
        font-weight: 700; text-transform: uppercase;
    }
    .badge-received { background: #dbeafe; color: #1d4ed8; }
    .badge-washing { background: #fef3c7; color: #b45309; }
    .badge-ready { background: #d1fae5; color: #065f46; }

    .cola-stats-card {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
        border: 1px solid rgba(0,0,0,0.04);
    }
    .cola-stat-item {
        display: flex; align-items: center; gap: 14px;
        padding: 14px 20px;
        border-bottom: 1px solid var(--gray-100);
    }
    .cola-stat-item:last-child { border-bottom: none; }
    .cola-stat-icon {
        width: 40px; height: 40px; border-radius: var(--radius-md);
        display: flex; align-items: center; justify-content: center; font-size: 16px;
    }
    .cola-stat-info { flex: 1; }
    .cola-stat-val { font-size: 20px; font-weight: 800; color: var(--dark); }
    .cola-stat-lbl { font-size: 12px; color: var(--gray-500); }

    .cola-modal-overlay {
        display: none; position: fixed; inset: 0;
        background: rgba(0,0,0,0.5); backdrop-filter: blur(4px);
        z-index: 2000; justify-content: center; align-items: center;
    }
    .cola-modal { width: 500px; max-width: 92%; max-height: 90vh; overflow-y: auto; }
</style>

<div class="cola-layout">
    <div>
        <div class="cola-kanban">
            <!-- RECIBIDOS -->
            <div class="cola-column">
                <div class="cola-column-header">
                    <div class="dot" style="background: #3b82f6;"></div>
                    <h4>Recibidos</h4>
                    <span class="count" id="countRecibidos">0</span>
                </div>
                <div id="colRecibidos">
                    <% int cR = 0; for (Pedidos p : pedidosActivos) { 
                        String st = p.getEstado();
                        if ("Recibido".equals(st) || "Cita Programada".equals(st)) {
                            cR++;
                            String svcName = "Servicio";
                            if (!p.getDetallePedidoList().isEmpty()) {
                                DetallePedido dp = p.getDetallePedidoList().get(0);
                                if (dp.getIdServicio() != null) svcName = dp.getIdServicio().getNombre();
                                else if (dp.getIdProducto() != null) svcName = dp.getIdProducto().getNombre();
                            }
                    %>
                    <div class="cola-card" onclick="colaOpenModal(<%= p.getIdPedido() %>, 'recibido')">
                        <div class="cola-card-id">#<%= p.getIdPedido() %></div>
                        <div class="cola-card-client"><%= p.getIdCliente().getNombreCompleto() %></div>
                        <div class="cola-card-service"><%= svcName %></div>
                        <div class="cola-card-meta">
                            <span class="cola-card-date"><%= sdf.format(p.getFechaRecepcion()) %></span>
                            <span class="cola-card-badge badge-received"><%= st %></span>
                        </div>
                    </div>
                    <% } } %>
                </div>
            </div>

            <!-- EN PROCESO -->
            <div class="cola-column">
                <div class="cola-column-header">
                    <div class="dot" style="background: #f59e0b;"></div>
                    <h4>En Proceso</h4>
                    <span class="count" id="countProceso">0</span>
                </div>
                <div id="colProceso">
                    <% int cP = 0; for (Pedidos p : pedidosActivos) { 
                        String st = p.getEstado();
                        if ("En Lavado".equals(st) || "En Camino".equals(st) || "Preparando Envío".equals(st) || "Preparando para Recojo".equals(st)) {
                            cP++;
                            String svcName = "Servicio";
                            if (!p.getDetallePedidoList().isEmpty()) {
                                DetallePedido dp = p.getDetallePedidoList().get(0);
                                if (dp.getIdServicio() != null) svcName = dp.getIdServicio().getNombre();
                                else if (dp.getIdProducto() != null) svcName = dp.getIdProducto().getNombre();
                            }
                    %>
                    <div class="cola-card" onclick="colaOpenModal(<%= p.getIdPedido() %>, 'proceso')">
                        <div class="cola-card-id">#<%= p.getIdPedido() %></div>
                        <div class="cola-card-client"><%= p.getIdCliente().getNombreCompleto() %></div>
                        <div class="cola-card-service"><%= svcName %></div>
                        <div class="cola-card-meta">
                            <span class="cola-card-date"><%= sdf.format(p.getFechaRecepcion()) %></span>
                            <span class="cola-card-badge badge-washing"><%= st %></span>
                        </div>
                    </div>
                    <% } } %>
                </div>
            </div>

            <!-- LISTOS -->
            <div class="cola-column">
                <div class="cola-column-header">
                    <div class="dot" style="background: #22c55e;"></div>
                    <h4>Listos</h4>
                    <span class="count" id="countListos">0</span>
                </div>
                <div id="colListos">
                    <% int cL = 0; for (Pedidos p : pedidosActivos) { 
                        String st = p.getEstado();
                        if ("Terminado".equals(st) || "Listo para Recoger".equals(st)) {
                            cL++;
                            String svcName = "Servicio";
                            if (!p.getDetallePedidoList().isEmpty()) {
                                DetallePedido dp = p.getDetallePedidoList().get(0);
                                if (dp.getIdServicio() != null) svcName = dp.getIdServicio().getNombre();
                                else if (dp.getIdProducto() != null) svcName = dp.getIdProducto().getNombre();
                            }
                    %>
                    <div class="cola-card" onclick="colaOpenModal(<%= p.getIdPedido() %>, 'listo')">
                        <div class="cola-card-id">#<%= p.getIdPedido() %></div>
                        <div class="cola-card-client"><%= p.getIdCliente().getNombreCompleto() %></div>
                        <div class="cola-card-service"><%= svcName %></div>
                        <div class="cola-card-meta">
                            <span class="cola-card-date"><%= sdf.format(p.getFechaRecepcion()) %></span>
                            <span class="cola-card-badge badge-ready"><%= st %></span>
                        </div>
                    </div>
                    <% } } %>
                </div>
            </div>
        </div>
    </div>

    <!-- Panel lateral: Estadísticas -->
    <div>
        <div class="cola-stats-card" style="margin-bottom: 20px;">
            <div style="padding: 20px; border-bottom: 1px solid var(--gray-100);">
                <h3 style="margin: 0; font-size: 15px;"><i class="fas fa-chart-bar" style="color: #2563eb;"></i> Resumen de Cola</h3>
            </div>
            <div class="cola-stat-item">
                <div class="cola-stat-icon" style="background: #dbeafe; color: #2563eb;"><i class="fas fa-inbox"></i></div>
                <div class="cola-stat-info">
                    <div class="cola-stat-val" id="statRecibidos">0</div>
                    <div class="cola-stat-lbl">Recibidos</div>
                </div>
            </div>
            <div class="cola-stat-item">
                <div class="cola-stat-icon" style="background: #fef3c7; color: #b45309;"><i class="fas fa-spinner"></i></div>
                <div class="cola-stat-info">
                    <div class="cola-stat-val" id="statProceso">0</div>
                    <div class="cola-stat-lbl">En Proceso</div>
                </div>
            </div>
            <div class="cola-stat-item">
                <div class="cola-stat-icon" style="background: #d1fae5; color: #065f46;"><i class="fas fa-check-circle"></i></div>
                <div class="cola-stat-info">
                    <div class="cola-stat-val" id="statListos">0</div>
                    <div class="cola-stat-lbl">Listos para Entrega</div>
                </div>
            </div>
        </div>

        <div class="cola-stats-card">
            <div style="padding: 20px; border-bottom: 1px solid var(--gray-100);">
                <h3 style="margin: 0; font-size: 15px;"><i class="fas fa-clock" style="color: #2563eb;"></i> Ultimos Terminados</h3>
            </div>
            <div style="padding: 12px 20px; max-height: 300px; overflow-y: auto;">
                <% if (pedidosTerminados.isEmpty()) { %>
                <div style="text-align: center; color: var(--gray-400); padding: 20px; font-size: 13px;">Sin pedidos terminados</div>
                <% } else { 
                    int shown = 0;
                    for (Pedidos p : pedidosTerminados) {
                        if (shown >= 10) break;
                        shown++;
                        String svcName = "Servicio";
                        if (!p.getDetallePedidoList().isEmpty()) {
                            DetallePedido dp = p.getDetallePedidoList().get(0);
                            if (dp.getIdServicio() != null) svcName = dp.getIdServicio().getNombre();
                            else if (dp.getIdProducto() != null) svcName = dp.getIdProducto().getNombre();
                        }
                %>
                <div style="display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--gray-100);">
                    <div style="width: 8px; height: 8px; border-radius: 50%; background: <%= "Entregado".equals(p.getEstado()) ? "#22c55e" : "#ef4444" %>;"></div>
                    <div style="flex: 1;">
                        <div style="font-weight: 600; font-size: 13px;">#<%= p.getIdPedido() %> - <%= p.getIdCliente().getNombreCompleto() %></div>
                        <div style="font-size: 11px; color: var(--gray-500);"><%= svcName %> &middot; <%= p.getEstado() %></div>
                    </div>
                    <div style="font-size: 11px; color: var(--gray-400);"><%= sdf.format(p.getFechaRecepcion()) %></div>
                </div>
                <% } } %>
            </div>
        </div>
    </div>
</div>

<!-- Modal para gestionar pedido -->
<div class="cola-modal-overlay" id="colaModal">
    <div class="card cola-modal">
        <div class="card-header">
            <h3>Pedido #<span id="colaModalId"></span></h3>
            <button class="modal-close" onclick="colaCloseModal()">&times;</button>
        </div>
        <div style="padding: 24px;">
            <div class="form-group">
                <label class="form-label">Cliente</label>
                <input type="text" id="colaModalClient" class="form-input" readonly style="background: var(--gray-50);">
            </div>
            <div class="form-group">
                <label class="form-label">Servicio / Producto</label>
                <input type="text" id="colaModalService" class="form-input" readonly style="background: var(--gray-50);">
            </div>
            <div class="form-group">
                <label class="form-label">Estado Actual</label>
                <input type="text" id="colaModalCurrentState" class="form-input" readonly style="background: var(--gray-50); font-weight: 600;">
            </div>
            <div class="form-group">
                <label class="form-label">Cambiar Estado</label>
                <select id="colaModalNewState" class="form-input"></select>
            </div>
            <div class="form-group">
                <label class="form-label">Notas</label>
                <textarea id="colaModalNotes" class="form-input" rows="2" placeholder="Observaciones..."></textarea>
            </div>
            <input type="hidden" id="colaModalNotesOld">
            <button class="btn btn-primary btn-block" onclick="colaUpdateStatus()">
                <i class="fas fa-check"></i> Actualizar Estado
            </button>
        </div>
    </div>
</div>

<script>
    (function() {
        document.getElementById('countRecibidos').innerText = '<%= cR %>';
        document.getElementById('countProceso').innerText = '<%= cP %>';
        document.getElementById('countListos').innerText = '<%= cL %>';
        document.getElementById('statRecibidos').innerText = '<%= cR %>';
        document.getElementById('statProceso').innerText = '<%= cP %>';
        document.getElementById('statListos').innerText = '<%= cL %>';
    })();

    function colaOpenModal(id, section) {
        document.getElementById('colaModal').style.display = 'flex';
        document.getElementById('colaModalId').innerText = id;
        document.getElementById('colaModalClient').value = 'Cargando...';
        document.getElementById('colaModalService').value = '';
        document.getElementById('colaModalCurrentState').value = '';
        document.getElementById('colaModalNotesOld').value = '';

        var select = document.getElementById('colaModalNewState');
        select.innerHTML = '';

        fetch('TrackingServlet?id=' + id)
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (d.id) {
                    document.getElementById('colaModalClient').value = d.cliente;
                    document.getElementById('colaModalService').value = d.servicio;
                    document.getElementById('colaModalCurrentState').value = d.estado;
                    document.getElementById('colaModalNotesOld').value = d.notas || '';

                    var currentState = d.estado;
                    var ops = [];
                    if (currentState === 'Recibido' || currentState === 'Cita Programada') {
                        ops = ['En Lavado'];
                    } else if (currentState === 'En Lavado') {
                        ops = ['Terminado', 'Recibido'];
                    } else if (currentState === 'Terminado') {
                        ops = ['Entregado'];
                    } else if (currentState === 'Preparando Envío') {
                        ops = ['En Camino'];
                    } else if (currentState === 'En Camino') {
                        ops = ['Entregado'];
                    } else if (currentState === 'Preparando para Recojo') {
                        ops = ['Listo para Recoger'];
                    } else if (currentState === 'Listo para Recoger') {
                        ops = ['Entregado'];
                    }
                    if (ops.length === 0) ops = [currentState];
                    ops.forEach(function(op) { select.add(new Option(op, op)); });
                    select.value = ops[0];
                }
            });
    }

    function colaCloseModal() {
        document.getElementById('colaModal').style.display = 'none';
    }

    function colaUpdateStatus() {
        var id = document.getElementById('colaModalId').innerText;
        var nuevoEstado = document.getElementById('colaModalNewState').value;
        var notasNuevas = document.getElementById('colaModalNotes').value;
        var notasAnt = document.getElementById('colaModalNotesOld').value;

        var fd = new URLSearchParams();
        fd.append('idPedido', id);
        fd.append('nuevoEstado', nuevoEstado);
        fd.append('nuevaNota', notasNuevas);
        fd.append('notasAnteriores', notasAnt);

        fetch('TrackingServlet', { method: 'POST', body: fd })
            .then(function(r) { return r.text(); })
            .then(function(d) {
                if (d.trim() === 'success') {
                    empNotify('Estado actualizado', 'success');
                    setTimeout(function() { window.location.href = 'empleado.jsp?view=colas'; }, 1000);
                } else {
                    empNotify('Error al actualizar', 'error');
                }
            });
    }
</script>
