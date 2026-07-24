<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionServiciosRemoto" %>
<%@ page import="Interfaces.IGestionClientesRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Servicios, entidades.Clientes" %>
<%@ page import="java.util.List, java.util.ArrayList" %>

<%
    List<Servicios> servicios = new ArrayList<>();
    List<Clientes> clientes = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionServiciosRemoto servRMI = (IGestionServiciosRemoto) registry.lookup("servicioCitaServicio");
        servicios = servRMI.listarServiciosDisponibles();
        IGestionClientesRemoto cliRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
        clientes = cliRMI.listarClientes();
    } catch(Exception e) {}
%>

<style>
    .rec-layout { display: grid; grid-template-columns: 1fr 420px; gap: 24px; align-items: start; }
    .rec-form-card {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
        border: 1px solid rgba(0,0,0,0.04);
    }
    .rec-form-header {
        padding: 20px 24px;
        border-bottom: 1px solid var(--gray-200);
        background: var(--gray-50);
        border-radius: var(--radius-lg) var(--radius-lg) 0 0;
    }
    .rec-form-header h3 { margin: 0; font-size: 16px; display: flex; align-items: center; gap: 8px; }
    .rec-form-body { padding: 24px; }
    .rec-service-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
        gap: 10px;
    }
    .rec-service-option {
        border: 2px solid var(--gray-200);
        border-radius: var(--radius-md);
        padding: 16px;
        text-align: center;
        cursor: pointer;
        transition: all 0.2s;
        background: var(--white);
    }
    .rec-service-option:hover { border-color: #2563eb; background: #eff6ff; }
    .rec-service-option.selected { border-color: #2563eb; background: #eff6ff; box-shadow: 0 0 0 3px rgba(37,99,235,0.1); }
    .rec-service-option i { font-size: 24px; color: #93c5fd; display: block; margin-bottom: 6px; }
    .rec-service-option .svc-name { font-weight: 600; font-size: 13px; color: var(--dark); }
    .rec-service-option .svc-price { color: #2563eb; font-weight: 800; font-size: 16px; margin-top: 4px; }
    .rec-service-option .svc-desc { color: var(--gray-500); font-size: 11px; margin-top: 2px; }

    .rec-summary {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
        border: 1px solid rgba(0,0,0,0.04);
    }
    .rec-summary-header {
        padding: 20px 24px;
        border-bottom: 1px solid var(--gray-200);
        background: linear-gradient(135deg, #1e3a5f 0%, #2563eb 100%);
        color: white;
        border-radius: var(--radius-lg) var(--radius-lg) 0 0;
    }
    .rec-summary-header h3 { margin: 0; font-size: 16px; }
    .rec-summary-body { padding: 24px; }
    .rec-summary-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 0;
        border-bottom: 1px solid var(--gray-100);
        font-size: 14px;
    }
    .rec-summary-row:last-child { border-bottom: none; }
    .rec-summary-label { color: var(--gray-600); }
    .rec-summary-value { font-weight: 600; color: var(--dark); }
    .rec-total-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 16px 0 0;
        margin-top: 8px;
        border-top: 2px solid var(--gray-200);
    }
    .rec-total-label { font-size: 14px; color: var(--gray-600); font-weight: 600; }
    .rec-total-value { font-size: 28px; font-weight: 800; color: #2563eb; }

    .rec-recent-orders {
        margin-top: 24px;
    }
    .rec-recent-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        background: var(--gray-50);
        border-radius: var(--radius-sm);
        margin-bottom: 8px;
        border-left: 4px solid #2563eb;
    }
    .rec-recent-item .ri-id { font-weight: 800; color: #2563eb; font-size: 14px; min-width: 40px; }
    .rec-recent-item .ri-info { flex: 1; }
    .rec-recent-item .ri-client { font-weight: 600; font-size: 13px; }
    .rec-recent-item .ri-svc { color: var(--gray-500); font-size: 12px; }
    .rec-recent-item .ri-total { font-weight: 700; color: var(--dark); font-size: 14px; }
</style>

<div class="rec-layout">
    <!-- Formulario de Recepción -->
    <div>
        <div class="rec-form-card" style="margin-bottom: 20px;">
            <div class="rec-form-header">
                <h3><i class="fas fa-user-plus" style="color: #2563eb;"></i> Datos del Cliente</h3>
            </div>
            <div class="rec-form-body">
                <div class="form-group">
                    <label class="form-label">Seleccionar Cliente Registrado</label>
                    <select id="recClientId" class="form-input" onchange="recToggleGuest()">
                        <option value="">-- Cliente de mostrador (no registrado) --</option>
                        <% for (Clientes c : clientes) { %>
                        <option value="<%= c.getIdCliente() %>" data-name="<%= c.getNombreCompleto() %>" data-phone="<%= c.getTelefono() %>">
                            <%= c.getNombreCompleto() %> - <%= c.getTelefono() %>
                        </option>
                        <% } %>
                    </select>
                </div>
                <div id="recGuestFields" style="display: none;">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Nombre del Cliente</label>
                            <input type="text" id="recGuestName" class="form-input" placeholder="Nombre completo">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Tel&eacute;fono</label>
                            <input type="tel" id="recGuestPhone" class="form-input" placeholder="999 999 999">
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Notas del Pedido</label>
                    <textarea id="recNotes" class="form-input" rows="2" placeholder="Ej: Manchas difíciles, tela delicada, etc."></textarea>
                </div>
            </div>
        </div>

        <div class="rec-form-card">
            <div class="rec-form-header">
                <h3><i class="fas fa-concierge-bell" style="color: #2563eb;"></i> Seleccionar Servicio</h3>
            </div>
            <div class="rec-form-body">
                <div class="rec-service-grid" id="recServiceGrid">
                    <% for (Servicios s : servicios) { 
                        String icon = "fa-shirt";
                        String tipo = s.getTipo() != null ? s.getTipo().toLowerCase() : "";
                        if (tipo.contains("premium")) icon = "fa-star";
                        else if (tipo.contains("restaur")) icon = "fa-magic";
                        else if (tipo.contains("planch")) icon = "fa-iron";
                    %>
                    <div class="rec-service-option" onclick="recSelectService(<%= s.getIdServicio() %>, '<%= s.getNombre().replace("'", "\\'") %>', <%= s.getPrecio() %>)" data-svc-id="<%= s.getIdServicio() %>">
                        <i class="fas <%= icon %>"></i>
                        <div class="svc-name"><%= s.getNombre() %></div>
                        <div class="svc-price">S/ <%= String.format("%.2f", s.getPrecio()) %></div>
                        <div class="svc-desc"><%= s.getTipo() != null ? s.getTipo() : "Servicio" %></div>
                    </div>
                    <% } %>
                </div>
                <div style="margin-top: 16px;">
                    <div class="form-group">
                        <label class="form-label">Cantidad de Prendas</label>
                        <input type="number" id="recQuantity" class="form-input" value="1" min="1" max="50" onchange="recUpdateSummary()" oninput="recUpdateSummary()">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Resumen y Confirmación -->
    <div>
        <div class="rec-summary">
            <div class="rec-summary-header">
                <h3><i class="fas fa-receipt"></i> Resumen del Pedido</h3>
            </div>
            <div class="rec-summary-body">
                <div class="rec-summary-row">
                    <span class="rec-summary-label">Cliente:</span>
                    <span class="rec-summary-value" id="recSummaryClient">De mostrador</span>
                </div>
                <div class="rec-summary-row">
                    <span class="rec-summary-label">Servicio:</span>
                    <span class="rec-summary-value" id="recSummaryService">Sin seleccionar</span>
                </div>
                <div class="rec-summary-row">
                    <span class="rec-summary-label">Cantidad:</span>
                    <span class="rec-summary-value" id="recSummaryQty">1 prenda(s)</span>
                </div>
                <div class="rec-summary-row">
                    <span class="rec-summary-label">Precio Unit.:</span>
                    <span class="rec-summary-value" id="recSummaryPrice">S/ 0.00</span>
                </div>
                <div class="rec-total-row">
                    <span class="rec-total-label">Total:</span>
                    <span class="rec-total-value" id="recSummaryTotal">S/ 0.00</span>
                </div>
            </div>
            <div style="padding: 0 24px 24px;">
                <div class="form-group">
                    <label class="form-label">Entrega Estimada</label>
                    <input type="date" id="recDeliveryDate" class="form-input">
                </div>
                <button class="btn btn-primary btn-block btn-lg" onclick="recConfirmOrder()" id="recConfirmBtn" style="background: #2563eb;">
                    <i class="fas fa-check-circle"></i> Registrar Pedido
                </button>
            </div>
        </div>

        <!-- Pedidos recién creados -->
        <div class="rec-recent-orders" id="recRecentOrders">
            <div style="font-size: 13px; font-weight: 600; color: var(--gray-600); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px; padding-left: 4px;">
                <i class="fas fa-clock"></i> Pedidos Registrados Hoy
            </div>
            <div id="recRecentList" style="color: var(--gray-400); text-align: center; padding: 20px; font-size: 13px;">
                Cargando...
            </div>
        </div>
    </div>
</div>

<script>
    var recSelectedService = null;
    var recSelectedServiceName = '';
    var recSelectedServicePrice = 0;

    function recToggleGuest() {
        var clientId = document.getElementById('recClientId').value;
        var guestFields = document.getElementById('recGuestFields');
        if (clientId) {
            var opt = document.getElementById('recClientId').selectedOptions[0];
            document.getElementById('recSummaryClient').innerText = opt.getAttribute('data-name') || 'Registrado';
            guestFields.style.display = 'none';
        } else {
            document.getElementById('recSummaryClient').innerText = 'De mostrador';
            guestFields.style.display = 'block';
        }
    }

    function recSelectService(id, name, price) {
        recSelectedService = id;
        recSelectedServiceName = name;
        recSelectedServicePrice = price;
        document.querySelectorAll('.rec-service-option').forEach(function(el) { el.classList.remove('selected'); });
        document.querySelector('[data-svc-id="'+id+'"]').classList.add('selected');
        recUpdateSummary();
    }

    function recUpdateSummary() {
        var qty = parseInt(document.getElementById('recQuantity').value) || 1;
        document.getElementById('recSummaryService').innerText = recSelectedServiceName || 'Sin seleccionar';
        document.getElementById('recSummaryQty').innerText = qty + ' prenda(s)';
        document.getElementById('recSummaryPrice').innerText = 'S/ ' + recSelectedServicePrice.toFixed(2);
        document.getElementById('recSummaryTotal').innerText = 'S/ ' + (recSelectedServicePrice * qty).toFixed(2);
    }

    function recConfirmOrder() {
        var clientId = document.getElementById('recClientId').value;
        var guestName = document.getElementById('recGuestName') ? document.getElementById('recGuestName').value : '';
        var guestPhone = document.getElementById('recGuestPhone') ? document.getElementById('recGuestPhone').value : '';
        var notes = document.getElementById('recNotes').value;
        var qty = parseInt(document.getElementById('recQuantity').value) || 1;
        var deliveryDate = document.getElementById('recDeliveryDate').value;

        if (!recSelectedService) {
            alert('Selecciona un servicio');
            return;
        }
        if (!clientId && !guestName) {
            alert('Selecciona un cliente o ingresa el nombre del mostrador');
            return;
        }
        if (!deliveryDate) {
            alert('Selecciona fecha de entrega estimada');
            return;
        }

        var fd = new URLSearchParams();
        fd.append('accion', 'nuevo_pedido_walkin');
        fd.append('clientId', clientId || '');
        fd.append('guestName', guestName);
        fd.append('guestPhone', guestPhone);
        fd.append('serviceId', recSelectedService);
        fd.append('quantity', qty);
        fd.append('total', (recSelectedServicePrice * qty).toFixed(2));
        fd.append('notes', notes);
        fd.append('deliveryDate', deliveryDate);

        var btn = document.getElementById('recConfirmBtn');
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Registrando...';

        fetch('RecepcionServlet', { method: 'POST', body: fd })
            .then(function(r) { return r.text(); })
            .then(function(d) {
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-check-circle"></i> Registrar Pedido';
                if (d.trim() === 'success') {
                    empNotify('Pedido registrado correctamente', 'success');
                    setTimeout(function() { window.location.href = 'empleado.jsp?view=recepcion'; }, 1200);
                } else {
                    empNotify('Error: ' + d, 'error');
                }
            })
            .catch(function(e) {
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-check-circle"></i> Registrar Pedido';
                empNotify('Error de conexion', 'error');
            });
    }

    (function() {
        var today = new Date();
        today.setDate(today.getDate() + 1);
        var y = today.getFullYear();
        var m = String(today.getMonth() + 1).padStart(2, '0');
        var d = String(today.getDate()).padStart(2, '0');
        document.getElementById('recDeliveryDate').value = y + '-' + m + '-' + d;
    })();
</script>
