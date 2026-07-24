<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div style="display: flex; gap: 8px; margin-bottom: 24px;">
    <button class="btn btn-primary" id="tabBtnRegistrar" onclick="switchClienteTab('registrar')">
        <i class="fas fa-user-plus"></i> Registrar Cliente
    </button>
    <button class="btn btn-outline" id="tabBtnBonos" onclick="switchClienteTab('bonos')">
        <i class="fas fa-gift"></i> Bonos de Fidelidad
    </button>
</div>

<!-- ========== TAB: REGISTRAR CLIENTE ========== -->
<div id="emp-tab-registrar" class="emp-cliente-tab">
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="card">
            <div class="card-header">
                <h3><i class="fas fa-user-plus" style="color: var(--aqua-dark);"></i> Registro R&aacute;pido</h3>
            </div>
            <form id="formRegistrarClienteEmp" onsubmit="return false;">
                <div class="form-group">
                    <label class="form-label">Nombre Completo *</label>
                    <input type="text" name="nombre" class="form-input" placeholder="Ej: Juan Perez" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Tel&eacute;fono</label>
                    <input type="text" name="telefono" class="form-input" placeholder="Ej: 999 888 777">
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-input" placeholder="Ej: juan@email.com">
                </div>
                <div class="form-group">
                    <label class="form-label">Direcci&oacute;n</label>
                    <input type="text" name="direccion" class="form-input" placeholder="Ej: Av. Principal 123">
                </div>
                <div style="background: var(--gray-50); border-radius: var(--radius-sm); padding: 10px 14px; margin-bottom: 16px; font-size: 12px; color: var(--gray-500);">
                    <i class="fas fa-info-circle"></i> Contrasena por defecto: <strong>newone123</strong>
                </div>
                <button type="submit" class="btn btn-primary btn-block" onclick="registrarClienteEmp()">
                    <i class="fas fa-check"></i> Registrar Cliente
                </button>
            </form>
        </div>

        <div class="card">
            <div class="card-header">
                <h3><i class="fas fa-search" style="color: #f59e0b;"></i> Buscar Cliente Existente</h3>
            </div>
            <div class="form-group">
                <input type="text" id="empSearchCliente" class="form-input" onkeyup="buscarClienteEmp()" placeholder="Buscar por nombre, telefono o email...">
            </div>
            <div id="empResultadosCliente" style="max-height: 300px; overflow-y: auto;">
                <div style="text-align:center; padding:20px; color:var(--gray-400);">
                    <i class="fas fa-search" style="font-size:24px;"></i>
                    <p style="margin-top:8px;">Escribe para buscar un cliente</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ========== TAB: BONOS FIDELIDAD ========== -->
<div id="emp-tab-bonos" class="emp-cliente-tab" style="display: none;">
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <!-- PANEL IZQUIERDO: OTORGAR BONO -->
        <div class="card">
            <div class="card-header">
                <h3><i class="fas fa-gift" style="color: #8b5cf6;"></i> Otorgar Bono</h3>
            </div>

            <div class="form-group">
                <label class="form-label">1. Buscar Cliente</label>
                <input type="text" id="empBonoSearch" class="form-input" onkeyup="buscarClienteBono()" placeholder="Nombre o telefono...">
            </div>
            <div id="empBonoResultados" style="max-height: 150px; overflow-y: auto; margin-bottom: 16px;">
                <div style="text-align:center; padding:15px; color:var(--gray-400); font-size:13px;">
                    <i class="fas fa-search"></i> Escribe nombre o telefono
                </div>
            </div>

            <div id="empBonoForm" style="display: none;">
                <div style="background: var(--gray-50); border-radius: var(--radius-sm); padding: 10px 14px; margin-bottom: 16px;">
                    <div style="font-weight: 600; color: var(--dark);" id="empBonoClienteNombre">-</div>
                    <div style="font-size: 12px; color: var(--gray-500);">Puntos actuales: <strong id="empBonoClientePuntos">0</strong></div>
                </div>

                <div class="form-group">
                    <label class="form-label">2. Tipo de Bono</label>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                        <button type="button" class="bono-tipo-btn bono-tipo-active" data-tipo="puntos" onclick="seleccionarTipoBono(this, 'puntos')" style="display:flex; align-items:center; gap:8px; padding:12px; background:var(--gray-50); border:2px solid var(--aqua-dark); border-radius:var(--radius-sm); cursor:pointer; transition:all 0.2s; font-size:13px; font-weight:600; color:var(--dark);">
                            <i class="fas fa-star" style="color:#f59e0b;"></i> Puntos
                        </button>
                        <button type="button" class="bono-tipo-btn" data-tipo="descuento" onclick="seleccionarTipoBono(this, 'descuento')" style="display:flex; align-items:center; gap:8px; padding:12px; background:var(--gray-50); border:2px solid var(--gray-200); border-radius:var(--radius-sm); cursor:pointer; transition:all 0.2s; font-size:13px; font-weight:600; color:var(--dark);">
                            <i class="fas fa-percent" style="color:#2563eb;"></i> Descuento
                        </button>
                        <button type="button" class="bono-tipo-btn" data-tipo="lavado_gratis" onclick="seleccionarTipoBono(this, 'lavado_gratis')" style="display:flex; align-items:center; gap:8px; padding:12px; background:var(--gray-50); border:2px solid var(--gray-200); border-radius:var(--radius-sm); cursor:pointer; transition:all 0.2s; font-size:13px; font-weight:600; color:var(--dark);">
                            <i class="fas fa-shirt" style="color:#22c55e;"></i> Lavado Gratis
                        </button>
                        <button type="button" class="bono-tipo-btn" data-tipo="upgrade_gratis" onclick="seleccionarTipoBono(this, 'upgrade_gratis')" style="display:flex; align-items:center; gap:8px; padding:12px; background:var(--gray-50); border:2px solid var(--gray-200); border-radius:var(--radius-sm); cursor:pointer; transition:all 0.2s; font-size:13px; font-weight:600; color:var(--dark);">
                            <i class="fas fa-arrow-up" style="color:#8b5cf6;"></i> Upgrade Gratis
                        </button>
                    </div>
                    <input type="hidden" id="bonoTipoHidden" value="puntos">
                </div>

                <div class="form-group">
                    <label class="form-label" id="bonoCantidadLabel">Puntos a otorgar</label>
                    <input type="number" id="empBonoPuntos" class="form-input" min="1" max="1000" value="10">
                    <div id="bonoQuickBtns" style="display:flex; gap:6px; margin-top:8px; flex-wrap:wrap;">
                        <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('empBonoPuntos').value=5">5 pts</button>
                        <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('empBonoPuntos').value=10">10 pts</button>
                        <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('empBonoPuntos').value=25">25 pts</button>
                        <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('empBonoPuntos').value=50">50 pts</button>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">3. Nota (opcional)</label>
                    <input type="text" id="empBonoMotivoCustom" class="form-input" placeholder="Ej: Por compra de S/150">
                </div>

                <button class="btn btn-primary btn-block" onclick="asignarBono()" style="margin-top: 8px;">
                    <i class="fas fa-gift"></i> Otorgar Bono
                </button>
            </div>
        </div>

        <!-- PANEL DERECHO: RESUMEN FIDELIDAD -->
        <div class="card">
            <div class="card-header">
                <h3><i class="fas fa-trophy" style="color: #f59e0b;"></i> Resumen de Fidelidad</h3>
            </div>
            <div class="form-group">
                <input type="text" id="empResumenSearch" class="form-input" onkeyup="buscarClienteResumen()" placeholder="Buscar cliente para ver historial...">
            </div>
            <div id="resumenInfo" style="display: none;">
                <div style="display: flex; gap: 16px; margin-bottom: 16px;">
                    <div style="flex:1; text-align:center; background: var(--gray-50); border-radius: var(--radius-sm); padding: 16px;">
                        <div style="font-size: 28px; font-weight: 800; color: var(--aqua-dark);" id="resumenPuntos">0</div>
                        <div style="font-size: 11px; color: var(--gray-500); text-transform: uppercase;">Puntos Totales</div>
                    </div>
                    <div style="flex:1; text-align:center; background: var(--gray-50); border-radius: var(--radius-sm); padding: 16px;">
                        <div style="font-size: 20px; font-weight: 800;" id="resumenNivel">Bronce</div>
                        <div style="font-size: 11px; color: var(--gray-500); text-transform: uppercase;">Nivel</div>
                    </div>
                </div>
                <div style="margin-bottom: 12px;">
                    <div style="display: flex; justify-content: space-between; font-size: 12px; color: var(--gray-500); margin-bottom: 4px;">
                        <span>Progreso al siguiente nivel</span>
                        <span id="resumenProgreso">0/50 pts</span>
                    </div>
                    <div style="background: var(--gray-200); border-radius: 10px; height: 8px;">
                        <div id="resumenBarra" style="background: linear-gradient(90deg, #38bdf8, #22c55e); height: 8px; border-radius: 10px; width: 0%; transition: width 0.5s;"></div>
                    </div>
                </div>
                <div style="margin: 16px 0 8px; font-weight: 600; font-size: 13px; color: var(--dark);">
                    <i class="fas fa-history"></i> Historial de Bonos
                </div>
                <div id="resumenHistorial" style="max-height: 200px; overflow-y: auto;">
                    <div style="text-align:center; padding:10px; color:var(--gray-400); font-size:12px;">Sin historial</div>
                </div>
            </div>
            <div id="resumenPlaceholder" style="text-align:center; padding:30px; color:var(--gray-400);">
                <i class="fas fa-trophy" style="font-size:32px;"></i>
                <p style="margin-top:8px;">Busca un cliente para ver su progreso</p>
            </div>
        </div>
    </div>
</div>

<style>
    .emp-cliente-bono-item {
        display: flex; justify-content: space-between; align-items: center;
        padding: 8px 12px; border-bottom: 1px solid var(--gray-100); font-size: 13px;
    }
    .emp-cliente-bono-item:last-child { border-bottom: none; }
    .emp-cliente-search-item {
        display: flex; justify-content: space-between; align-items: center;
        padding: 10px 14px; border-bottom: 1px solid var(--gray-100);
        cursor: pointer; transition: background 0.15s;
    }
    .emp-cliente-search-item:hover { background: var(--gray-50); }
    .emp-cliente-search-item:last-child { border-bottom: none; }
    .nivel-badge {
        display: inline-block; padding: 2px 8px; border-radius: 10px;
        font-size: 10px; font-weight: 700; text-transform: uppercase;
    }
    .nivel-bronce { background: #fed7aa; color: #9a3412; }
    .nivel-plata { background: #e5e7eb; color: #374151; }
    .nivel-oro { background: #fef08a; color: #854d0e; }
    .nivel-platino { background: #ddd6fe; color: #5b21b6; }
    .bono-tipo-btn.bono-tipo-active { border-color: var(--aqua-dark) !important; background: rgba(64, 224, 208, 0.08) !important; }
</style>
