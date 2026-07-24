
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<style>
    .auth-wrapper {
        min-height: 75vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 40px 20px;
    }
    .auth-card-container {
        width: 100%;
        max-width: 540px;
    }
    .auth-tabs {
        display: flex;
        gap: 4px;
        background: var(--gray-100);
        padding: 4px;
        border-radius: var(--radius-md);
        margin-bottom: 24px;
    }
    .auth-tabs button {
        flex: 1;
        padding: 12px 8px;
        border: none;
        background: transparent;
        border-radius: var(--radius-sm);
        font-family: var(--font-body);
        font-size: 12px;
        font-weight: 600;
        color: var(--gray-600);
        cursor: pointer;
        transition: all var(--transition-base);
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
    }
    .auth-tabs button.active {
        background: var(--white);
        color: var(--dark);
        box-shadow: var(--shadow-sm);
    }
    .auth-panel {
        background: var(--white);
        border-radius: var(--radius-xl);
        box-shadow: var(--shadow-lg);
        border: 1px solid rgba(0,0,0,0.04);
        overflow: hidden;
    }
    .auth-panel-header {
        padding: 28px 32px 20px;
        text-align: center;
        border-bottom: 1px solid var(--gray-200);
    }
    .auth-panel-header .icon-circle {
        width: 56px; height: 56px;
        background: var(--aqua-glow);
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 16px;
        font-size: 22px;
        color: var(--aqua-dark);
    }
    .auth-panel-header h3 { margin: 0 0 4px; font-size: 22px; }
    .auth-panel-header p { margin: 0; color: var(--gray-600); font-size: 14px; }
    .auth-panel-body { padding: 28px 32px 32px; }
    .icon-admin { background: var(--gray-200); color: var(--gray-700); }
    .icon-empleado { background: #dbeafe; color: #2563eb; }
    .icon-repartidor { background: #ccfbf1; color: #0f766e; }
</style>

<div class="auth-wrapper">
    <div class="auth-card-container">

        <% if("invalid_client".equals(request.getParameter("error"))) { %>
            <div class="badge badge-danger" style="width: 100%; padding: 12px; margin-bottom: 16px; justify-content: center; font-size: 13px;">
                <i class="fas fa-times-circle"></i> Correo o contrase&ntilde;a incorrectos.
            </div>
        <% } else if("registered".equals(request.getParameter("status"))) { %>
            <div class="badge badge-success" style="width: 100%; padding: 12px; margin-bottom: 16px; justify-content: center; font-size: 13px;">
                <i class="fas fa-check-circle"></i> &iexcl;Cuenta creada! Inicia sesi&oacute;n.
            </div>
        <% } else if("invalid".equals(request.getParameter("error"))) { %>
            <div class="badge badge-danger" style="width: 100%; padding: 12px; margin-bottom: 16px; justify-content: center; font-size: 13px;">
                <i class="fas fa-exclamation-triangle"></i> C&oacute;digo o contrase&ntilde;a incorrectos.
            </div>
        <% } else if("server".equals(request.getParameter("error"))) { %>
            <div class="badge badge-danger" style="width: 100%; padding: 12px; margin-bottom: 16px; justify-content: center; font-size: 13px;">
                Error del sistema. Intenta nuevamente.
            </div>
        <% } else if("invalid_phone".equals(request.getParameter("error"))) { %>
            <div class="badge badge-danger" style="width: 100%; padding: 12px; margin-bottom: 16px; justify-content: center; font-size: 13px;">
                <i class="fas fa-phone"></i> El tel&eacute;fono debe tener exactamente 9 d&iacute;gitos.
            </div>
        <% } %>

        <div class="auth-tabs" id="authTabs">
            <button class="active" onclick="switchAuthTab('login', event)">
                <i class="fas fa-user"></i> Cliente
            </button>
            <button onclick="switchAuthTab('register', event)">
                <i class="fas fa-user-plus"></i> Registro
            </button>
        </div>

        <!-- ===================== LOGIN CLIENTE ===================== -->
        <div class="auth-panel" id="panel-login">
            <div class="auth-panel-header">
                <div class="icon-circle"><i class="fas fa-right-to-bracket"></i></div>
                <h3>Iniciar Sesi&oacute;n</h3>
                <p>Accede a tu cuenta de cliente</p>
            </div>
            <div class="auth-panel-body">
                <form action="ClienteLoginServlet" method="post">
                    <div class="form-group">
                        <label class="form-label">Correo electr&oacute;nico</label>
                        <input type="email" name="email" class="form-input" placeholder="cliente@ejemplo.com" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Contrase&ntilde;a</label>
                        <input type="password" name="password" class="form-input" placeholder="Ingresa tu contrase&ntilde;a" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: 8px;">
                        <i class="fas fa-right-to-bracket"></i> Ingresar
                    </button>
                </form>
            </div>
        </div>

        <!-- ===================== REGISTRO CLIENTE ===================== -->
        <div class="auth-panel" id="panel-register" style="display: none;">
            <div class="auth-panel-header">
                <div class="icon-circle"><i class="fas fa-user-plus"></i></div>
                <h3>Crear Cuenta</h3>
                <p>Reg&iacute;strate para acceder a nuestros servicios</p>
            </div>
            <div class="auth-panel-body">
                <form action="RegistrarServlet" method="post">
                    <div class="form-group">
                        <label class="form-label">Nombre completo</label>
                        <input type="text" name="nombre" class="form-input" placeholder="Ej: Juan P&eacute;rez" required>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Correo electr&oacute;nico</label>
                            <input type="email" name="email" class="form-input" placeholder="juan@email.com" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Tel&eacute;fono (9 d&iacute;gitos)</label>
                            <input type="tel" name="telefono" id="regTelefono" class="form-input" placeholder="999999999" maxlength="9" pattern="[0-9]{9}" oninput="this.value=this.value.replace(/[^0-9]/g,'').substring(0,9)" required>
                            <small id="regTelError" style="color: var(--danger); display: none;">Debe tener exactamente 9 d&iacute;gitos.</small>
                        </div>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Contrase&ntilde;a</label>
                            <input type="password" name="password" class="form-input" placeholder="M&iacute;nimo 6 caracteres" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Fecha de Nacimiento</label>
                            <input type="date" name="fechaNacimiento" class="form-input" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Direcci&oacute;n</label>
                        <textarea name="direccion" id="regDireccion" class="form-input" rows="2" placeholder="Calle, N&uacute;mero, Distrito..." required></textarea>
                    </div>
                    <div class="form-group">
                        <label class="form-label"><i class="fas fa-map-marker-alt" style="color: var(--danger);"></i> Ubicaci&oacute;n en el mapa</label>
                        <div style="border-radius: var(--radius-md); overflow: hidden; border: 1.5px solid var(--gray-300);">
                            <div id="regMap" style="height: 220px; width: 100%;"></div>
                        </div>
                        <div style="display: flex; align-items: center; gap: 8px; margin-top: 8px;">
                            <i class="fas fa-info-circle" style="color: var(--gray-400); font-size: 12px;"></i>
                            <small style="color: var(--gray-500);">Se marca autom&aacute;ticamente al escribir la direcci&oacute;n. Tambi&eacute;n puedes clickear en el mapa para ajustar.</small>
                        </div>
                        <small id="regCoords" style="color: var(--aqua-dark); display: none;"></small>
                        <input type="hidden" name="lat" id="regLat">
                        <input type="hidden" name="lng" id="regLng">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Referido por (Opcional)</label>
                        <input type="text" name="referido" class="form-input" placeholder="C&oacute;digo o nombre">
                    </div>
                    <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: 8px;">
                        <i class="fas fa-user-plus"></i> Crear Cuenta
                    </button>
                </form>
            </div>
        </div>



    </div>
</div>

<script>
    var tabMap = { 'login': 0, 'register': 1 };

    function switchAuthTab(tab, evt) {
        var tabs = document.querySelectorAll('#authTabs button');
        var panels = document.querySelectorAll('.auth-panel');

        tabs.forEach(function(b) { b.classList.remove('active'); });
        panels.forEach(function(p) { p.style.display = 'none'; });

        if (evt && evt.currentTarget) {
            evt.currentTarget.classList.add('active');
        } else if (tabMap[tab] !== undefined && tabs[tabMap[tab]]) {
            tabs[tabMap[tab]].classList.add('active');
        }

        var panel = document.getElementById('panel-' + tab);
        if (panel) panel.style.display = 'block';
    }

    document.addEventListener("DOMContentLoaded", function () {
        var urlParams = new URLSearchParams(window.location.search);
        var view = urlParams.get('view');
        if (view && tabMap[view] !== undefined) {
            switchAuthTab(view);
        }
    });

    var regMap = null;
    var regMarker = null;
    var geocodeTimer = null;

    function initRegMap() {
        if (regMap) return;
        regMap = L.map('regMap').setView([-6.7714, -79.8409], 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; OpenStreetMap'
        }).addTo(regMap);

        regMap.on('click', function(e) {
            var lat = e.latlng.lat.toFixed(6);
            var lng = e.latlng.lng.toFixed(6);
            document.getElementById('regLat').value = lat;
            document.getElementById('regLng').value = lng;
            var coordsInfo = document.getElementById('regCoords');
            coordsInfo.style.display = 'block';
            coordsInfo.innerHTML = '<i class="fas fa-check-circle"></i> Ubicaci&oacute;n: ' + lat + ', ' + lng;

            if (regMarker) {
                regMarker.setLatLng(e.latlng);
            } else {
                regMarker = L.marker(e.latlng).addTo(regMap);
            }
            regMarker.bindPopup('Tu ubicaci&oacute;n de recojo').openPopup();

            reverseGeocode(lat, lng);
        });

        setTimeout(function(){ regMap.invalidateSize(); }, 300);
    }

    function geocodeAddress(address) {
        if (!address || address.trim().length < 5) return;
        clearTimeout(geocodeTimer);
        geocodeTimer = setTimeout(function() {
            fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(address) + '&limit=1&countrycodes=pe')
                .then(function(r) { return r.json(); })
                .then(function(results) {
                    if (results.length > 0) {
                        var lat = parseFloat(results[0].lat);
                        var lng = parseFloat(results[0].lon);
                        var latlng = L.latLng(lat, lng);

                        document.getElementById('regLat').value = lat.toFixed(6);
                        document.getElementById('regLng').value = lng.toFixed(6);
                        var coordsInfo = document.getElementById('regCoords');
                        coordsInfo.style.display = 'block';
                        coordsInfo.innerHTML = '<i class="fas fa-check-circle"></i> Ubicaci&oacute;n autom&aacute;tica: ' + lat.toFixed(6) + ', ' + lng.toFixed(6);

                        if (regMarker) {
                            regMarker.setLatLng(latlng);
                        } else {
                            regMarker = L.marker(latlng).addTo(regMap);
                        }
                        regMarker.bindPopup('Ubicaci&oacute;n de recojo').openPopup();
                        regMap.setView(latlng, 17);
                    }
                })
                .catch(function() {});
        }, 900);
    }

    function reverseGeocode(lat, lng) {
        fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng + '&accept-language=es')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.display_name) {
                    var dirInput = document.getElementById('regDireccion');
                    var parts = data.display_name.split(',');
                    var shortAddr = parts.slice(0, 3).join(',');
                    dirInput.value = shortAddr;
                }
            })
            .catch(function() {});
    }

    var origSwitchAuthTab = switchAuthTab;
    switchAuthTab = function(tab, evt) {
        origSwitchAuthTab(tab, evt);
        if (tab === 'register') {
            setTimeout(initRegMap, 100);
        }
    };

    document.addEventListener("DOMContentLoaded", function() {
        var dirInput = document.getElementById('regDireccion');
        if (dirInput) {
            dirInput.addEventListener('input', function() {
                geocodeAddress(this.value);
            });
        }
    });

    var regTelInput = document.getElementById('regTelefono');
    if (regTelInput) {
        regTelInput.addEventListener('input', function() {
            var err = document.getElementById('regTelError');
            if (this.value.length > 0 && this.value.length !== 9) {
                err.style.display = 'block';
                this.style.borderColor = 'var(--danger)';
            } else {
                err.style.display = 'none';
                this.style.borderColor = '';
            }
        });
        regTelInput.closest('form').addEventListener('submit', function(e) {
            if (regTelInput.value.length !== 9) {
                e.preventDefault();
                document.getElementById('regTelError').style.display = 'block';
                regTelInput.focus();
            }
        });
    }
</script>

<%@ include file="footer.jsp" %>
