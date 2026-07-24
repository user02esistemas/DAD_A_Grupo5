<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div id="emp-tracking-section">
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <button class="btn btn-primary" id="tabBtnServ" onclick="switchTrackingTab('servicios')">
                <i class="fas fa-shirt"></i> Servicios (<span id="countServ">0</span>)
            </button>
            <button class="btn btn-outline" id="tabBtnDel" onclick="switchTrackingTab('delivery')">
                <i class="fas fa-motorcycle"></i> Delivery (<span id="countDel">0</span>)
            </button>
            <button class="btn btn-outline" id="tabBtnRec" onclick="switchTrackingTab('recojo')">
                <i class="fas fa-store"></i> Recojo (<span id="countRec">0</span>)
            </button>
            <div style="flex: 1;"></div>
            <input type="text" id="trackingSearchInput" class="form-input" onkeyup="filtrarPedidosTracking()" placeholder="Buscar por ID o cliente..." style="width: 260px;">
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <h3 id="trackingTitle"><i class="fas fa-shirt"></i> Cola de Servicios</h3>
        </div>
        <div style="overflow-x: auto;">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Cliente</th>
                        <th>Detalle</th>
                        <th>Estado</th>
                        <th>Fecha</th>
                        <th>Monto</th>
                        <th>Acci&oacute;n</th>
                    </tr>
                </thead>
                <tbody id="trackingTableBody">
                    <tr>
                        <td colspan="7" style="text-align:center; padding:30px; color:var(--gray-400);">
                            <i class="fas fa-spinner fa-spin"></i> Cargando pedidos...
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div id="trackingModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); backdrop-filter:blur(4px); z-index:2000; justify-content:center; align-items:center;">
    <div class="card" style="width: 520px; max-width: 92%; max-height: 90vh; overflow-y: auto;">
        <div class="card-header">
            <h3>Pedido #<span id="modalId"></span></h3>
            <button class="modal-close" onclick="cerrarModalSeguimiento()">&times;</button>
        </div>
        <form onsubmit="return false;">
            <input type="hidden" id="modalIdHidden">
            <input type="hidden" id="modalMonto">
            <input type="hidden" id="modalEstadoOriginal">

            <div class="form-group">
                <label class="form-label">Cliente</label>
                <input type="text" id="modalCliente" class="form-input" readonly style="background: var(--gray-50);">
            </div>

            <div class="form-group">
                <label class="form-label">Servicio / Producto</label>
                <input type="text" id="modalServicio" class="form-input" readonly style="background: var(--gray-50);">
            </div>

            <div class="form-group">
                <label class="form-label">Nuevo Estado</label>
                <select id="modalEstado" class="form-input" style="font-weight: 600;"></select>
            </div>

            <div class="form-group">
                <label class="form-label" style="color: var(--aqua-dark);"><i class="fas fa-comment-dots"></i> Enviar Mensaje</label>
                <textarea id="modalNotaNueva" class="form-input" rows="2" placeholder="Escribe aqu&iacute;..."></textarea>
            </div>

            <div class="form-group">
                <label class="form-label">Historial</label>
                <textarea id="modalHistorial" class="form-input" rows="3" readonly style="background: var(--gray-50); font-size: 12px;"></textarea>
            </div>

            <button class="btn btn-primary btn-block" onclick="procesarSeguimiento()" style="margin-top: 8px;">
                <i class="fas fa-check"></i> Guardar
            </button>
        </form>
    </div>
</div>
