
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



        <!-- ===================== REPARTIDOR ===================== -->
        <div class="auth-panel" id="panel-repartidor">
            <div class="auth-panel-header" style="background: #f0fdfa;">
                <div class="icon-circle icon-repartidor"><i class="fas fa-motorcycle"></i></div>
                <h3>Acceso Repartidor</h3>
                <p>Panel de entregas y delivery</p>
            </div>
            <div class="auth-panel-body">
                <form action="RepartidorLoginServlet" method="post">
                    <div class="form-group">
                        <label class="form-label">C&oacute;digo repartidor</label>
                        <input type="text" name="repCode" class="form-input" placeholder="Ingresa tu c&oacute;digo" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Contrase&ntilde;a</label>
                        <input type="password" name="password" class="form-input" placeholder="Ingresa tu contrase&ntilde;a" required>
                    </div>
                    <button type="submit" class="btn btn-block btn-lg" style="margin-top: 8px; background: #0f766e; color: white;">
                        <i class="fas fa-right-to-bracket"></i> Acceder al Panel
                    </button>
                </form>
            </div>
        </div>

    </div>
</div>

<script>
    var tabMap = { 'repartidor': 0 };

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
