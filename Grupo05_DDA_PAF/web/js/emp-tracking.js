/*
 * Tracking Module - Empleado Operativo
 * Gestión de pedidos: Servicios, Delivery, Recojo
 */

var trackingData = { servicios: [], delivery: [], recojo: [] };
var currentTrackingTab = 'servicios';

// ==========================================
// 1. CARGA DE DATOS
// ==========================================
function cargarPedidosTracking() {
    fetch('TrackingServlet?accion=listar_pedidos')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            trackingData.servicios = data.servicios || [];
            trackingData.delivery = data.delivery || [];
            trackingData.recojo = data.recojo || [];

            document.getElementById('countServ').textContent = trackingData.servicios.length;
            document.getElementById('countDel').textContent = trackingData.delivery.length;
            document.getElementById('countRec').textContent = trackingData.recojo.length;

            renderTrackingTable(currentTrackingTab);
        })
        .catch(function(err) {
            console.error('Error cargando pedidos:', err);
            document.getElementById('trackingTableBody').innerHTML =
                '<tr><td colspan="7" style="text-align:center; padding:30px; color:#dc3545;">' +
                '<i class="fas fa-exclamation-triangle"></i> Error al cargar pedidos</td></tr>';
        });
}

// ==========================================
// 2. NAVEGACIÓN DE TABS
// ==========================================
function switchTrackingTab(tab) {
    currentTrackingTab = tab;

    document.getElementById('tabBtnServ').className = tab === 'servicios' ? 'btn btn-primary' : 'btn btn-outline';
    document.getElementById('tabBtnDel').className = tab === 'delivery' ? 'btn btn-primary' : 'btn btn-outline';
    document.getElementById('tabBtnRec').className = tab === 'recojo' ? 'btn btn-primary' : 'btn btn-outline';

    var titles = {
        servicios: '<i class="fas fa-shirt"></i> Cola de Servicios',
        delivery: '<i class="fas fa-motorcycle"></i> Pedidos Delivery',
        recojo: '<i class="fas fa-store"></i> Pedidos Recojo en Tienda'
    };
    document.getElementById('trackingTitle').innerHTML = titles[tab] || titles.servicios;

    renderTrackingTable(tab);
}

// ==========================================
// 3. RENDERIZADO DE TABLA
// ==========================================
function renderTrackingTable(tab) {
    var data = trackingData[tab] || [];
    var tbody = document.getElementById('trackingTableBody');
    var search = document.getElementById('trackingSearchInput').value.toLowerCase();

    if (data.length === 0) {
        tbody.innerHTML =
            '<tr><td colspan="7" style="text-align:center; padding:30px; color:var(--gray-400);">' +
            '<i class="fas fa-inbox" style="font-size:32px; display:block; margin-bottom:10px;"></i>' +
            'No hay pedidos en esta cola</td></tr>';
        return;
    }

    var icons = {
        servicios: 'fa-shirt',
        delivery: 'fa-motorcycle',
        recojo: 'fa-store'
    };
    var icon = icons[tab] || 'fa-box';
    var iconColors = {
        servicios: 'var(--aqua-dark)',
        delivery: 'var(--purple)',
        recojo: 'var(--warning)'
    };
    var iconColor = iconColors[tab] || 'var(--aqua-dark)';

    var html = '';
    for (var i = 0; i < data.length; i++) {
        var p = data[i];

        if (search && p.id.toString().indexOf(search) === -1 &&
            p.cliente.toLowerCase().indexOf(search) === -1) {
            continue;
        }

        var detalle = tab === 'servicios' ? p.servicio : p.producto;
        if (!detalle) detalle = tab === 'servicios' ? 'Servicio' : 'Producto';

        html += '<tr>';
        html += '<td><strong>#' + p.id + '</strong></td>';
        html += '<td>' + escapeHtml(p.cliente) + '</td>';
        html += '<td><small style="color:' + iconColor + ';"><i class="fas ' + icon + '"></i> ' + escapeHtml(detalle) + '</small></td>';
        html += '<td><span class="badge ' + p.estadoBadge + '">' + escapeHtml(p.estado) + '</span></td>';
        html += '<td style="color: var(--gray-600);">' + p.fecha + '</td>';
        html += '<td style="font-weight:600;">S/ ' + parseFloat(p.monto).toFixed(2) + '</td>';
        html += '<td><button class="btn btn-primary btn-sm" onclick="abrirModalSeguimiento(' + p.id + ')"><i class="fas fa-cog"></i> Gestionar</button></td>';
        html += '</tr>';
    }

    if (html === '') {
        tbody.innerHTML =
            '<tr><td colspan="7" style="text-align:center; padding:30px; color:var(--gray-400);">' +
            '<i class="fas fa-search" style="font-size:32px; display:block; margin-bottom:10px;"></i>' +
            'No se encontraron resultados</td></tr>';
    } else {
        tbody.innerHTML = html;
    }
}

// ==========================================
// 4. FILTRADO
// ==========================================
function filtrarPedidosTracking() {
    renderTrackingTable(currentTrackingTab);
}

// ==========================================
// 5. MODAL DE SEGUIMIENTO
// ==========================================
function abrirModalSeguimiento(id) {
    fetch('TrackingServlet?id=' + id)
        .then(function(r) { return r.json(); })
        .then(function(p) {
            if (!p || !p.id) {
                empNotify('Pedido no encontrado', 'error');
                return;
            }

            document.getElementById('modalIdHidden').value = p.id;
            document.getElementById('modalId').textContent = p.id;
            document.getElementById('modalCliente').value = p.cliente;
            document.getElementById('modalServicio').value = p.servicio;
            document.getElementById('modalMonto').value = p.monto;
            document.getElementById('modalEstadoOriginal').value = p.estado;
            document.getElementById('modalNotaNueva').value = '';
            document.getElementById('modalHistorial').value = p.notas || 'Sin notas registradas';

            var select = document.getElementById('modalEstado');
            select.innerHTML = '';
            var opciones = getOpcionesEstado(p.estado);
            for (var i = 0; i < opciones.length; i++) {
                var opt = document.createElement('option');
                opt.value = opciones[i];
                opt.textContent = opciones[i];
                if (opciones[i] === p.estado) opt.selected = true;
                select.appendChild(opt);
            }

            document.getElementById('trackingModal').style.display = 'flex';
        })
        .catch(function(err) {
            console.error('Error:', err);
            empNotify('Error al cargar pedido', 'error');
        });
}

function cerrarModalSeguimiento() {
    document.getElementById('trackingModal').style.display = 'none';
}

// ==========================================
// 6. PROCESAR SEGUIMIENTO
// ==========================================
function procesarSeguimiento() {
    var id = document.getElementById('modalIdHidden').value;
    var nuevoEstado = document.getElementById('modalEstado').value;
    var estadoOriginal = document.getElementById('modalEstadoOriginal').value;
    var nota = document.getElementById('modalNotaNueva').value.trim();

    if (nuevoEstado === estadoOriginal && !nota) {
        empNotify('No hay cambios para guardar', 'error');
        return;
    }

    var params = new URLSearchParams();
    params.append('idPedido', id);
    params.append('nuevoEstado', nuevoEstado);
    params.append('nuevaNota', nota);

    fetch('TrackingServlet', {
        method: 'POST',
        body: params
    })
    .then(function(r) { return r.text(); })
    .then(function(res) {
        if (res.trim() === 'success') {
            empNotify('Pedido #' + id + ' actualizado a: ' + nuevoEstado, 'success');
            cerrarModalSeguimiento();
            cargarPedidosTracking();
        } else {
            empNotify('Error al actualizar: ' + res, 'error');
        }
    })
    .catch(function(err) {
        console.error('Error:', err);
        empNotify('Error de conexión', 'error');
    });
}

// ==========================================
// 7. OPCIONES DE ESTADO POR TIPO
// ==========================================
function getOpcionesEstado(estadoActual) {
    var estadosServicio = ['Recibido', 'En Lavado', 'Terminado', 'Entregado'];
    var estadosDelivery = ['Recibido', 'Preparando Envío', 'En Camino', 'Entregado'];
    var estadosRecojo = ['Recibido', 'Preparando para Recojo', 'Listo para Recoger', 'Entregado'];

    var lista;
    if (currentTrackingTab === 'servicios') {
        lista = estadosServicio;
    } else if (currentTrackingTab === 'delivery') {
        lista = estadosDelivery;
    } else {
        lista = estadosRecojo;
    }

    var idx = lista.indexOf(estadoActual);
    if (idx === -1) {
        return lista;
    }

    var opciones = [];
    for (var i = idx; i < lista.length; i++) {
        opciones.push(lista[i]);
    }
    return opciones;
}

// ==========================================
// 8. UTILIDADES
// ==========================================
function escapeHtml(text) {
    if (!text) return '';
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(text));
    return div.innerHTML;
}
