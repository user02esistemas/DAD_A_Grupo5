<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entidades.Clientes" %>
<%
    Clientes cliProfile = (Clientes) request.getSession().getAttribute("cliente");
    if (cliProfile == null) return;
%>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<section id="profile" class="section">
    <div class="container">
        <div class="page-header">
            <div>
                <h1>Mi Perfil</h1>
                <p>Actualiza tu informaci&oacute;n personal y seguridad.</p>
            </div>
        </div>

        <div class="card" style="max-width: 820px; margin: 0 auto;">
            <div style="display: flex; align-items: center; gap: 20px; margin-bottom: 30px; padding-bottom: 24px; border-bottom: 1px solid var(--gray-200);">
                <div id="profileInitial" style="width: 72px; height: 72px; background: var(--aqua-gradient); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 30px; color: var(--dark); font-weight: 700;">
                    U
                </div>
                <div>
                    <h3 id="profileNameDisplay" style="margin: 0; font-size: 20px;">Cargando...</h3>
                    <p style="margin: 4px 0 0; color: var(--gray-600); font-size: 14px;">Cliente Registrado</p>
                </div>
            </div>

            <form id="formProfile" onsubmit="return false;">
                <div style="display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 18px;">
                    <div style="flex: 1; min-width: 260px;">
                        <label class="form-label">Nombre Completo</label>
                        <input type="text" name="nombre" id="profileNombre" class="form-input" required>
                    </div>
                    <div style="flex: 1; min-width: 260px;">
                        <label class="form-label">Correo Electr&oacute;nico (No editable)</label>
                        <input type="email" id="profileEmail" class="form-input" readonly style="background: var(--gray-50); color: var(--gray-500); cursor: not-allowed;">
                    </div>
                </div>

                <div style="display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 18px;">
                    <div style="flex: 1; min-width: 260px;">
                        <label class="form-label">Tel&eacute;fono / Celular (9 d&iacute;gitos)</label>
                        <input type="tel" name="telefono" id="profileTelefono" class="form-input" placeholder="999999999" maxlength="9" pattern="[0-9]{9}" oninput="this.value=this.value.replace(/[^0-9]/g,'').substring(0,9)">
                        <small id="profileTelError" style="color: var(--danger); display: none;">Debe tener exactamente 9 d&iacute;gitos.</small>
                    </div>
                    <div style="flex: 1; min-width: 260px;">
                        <label class="form-label">Fecha de Nacimiento</label>
                        <input type="date" name="fechaNacimiento" id="profileFechaNac" class="form-input">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Direcci&oacute;n de Recojo (Solo lectura)</label>
                    <textarea name="direccion" id="profileDireccion" class="form-input" rows="2" placeholder="Calle, N&uacute;mero, Distrito..." readonly style="background: var(--gray-50); color: var(--gray-600); cursor: not-allowed;"></textarea>
                    <small style="color: var(--gray-500);"><i class="fas fa-info-circle"></i> La direcci&oacute;n se registra solo en el momento de crear la cuenta.</small>
                </div>

                <div class="form-group">
                    <label class="form-label"><i class="fas fa-map-marker-alt" style="color: var(--danger);"></i> Mi Ubicaci&oacute;n en el Mapa</label>
                    <div style="border-radius: var(--radius-md); overflow: hidden; border: 1.5px solid var(--gray-300);">
                        <div id="profileMap" style="height: 250px; width: 100%;"></div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px; margin-top: 8px;">
                        <i class="fas fa-info-circle" style="color: var(--gray-400); font-size: 12px;"></i>
                        <small style="color: var(--gray-500);">Ubicaci&oacute;n de recojo registrada (solo consulta).</small>
                    </div>
                    <small id="profileCoords" style="color: var(--aqua-dark); display: none;"></small>
                </div>

                <hr style="margin: 28px 0; border: 0; border-top: 1px solid var(--gray-200);">
                
                <h4 style="margin-bottom: 16px; color: var(--dark);"><i class="fas fa-lock" style="color: var(--aqua-dark);"></i> Seguridad</h4>
                <div class="form-group">
                    <label class="form-label">Nueva Contrase&ntilde;a</label>
                    <input type="password" name="password" class="form-input" placeholder="Deja en blanco para no cambiar">
                    <small style="color: var(--gray-500);">Solo escribe aqu&iacute; si deseas cambiar tu clave actual.</small>
                </div>

                <div style="text-align: right; margin-top: 28px;">
                    <button class="btn btn-primary btn-lg" onclick="updateProfile()">
                        <i class="fas fa-save"></i> Guardar Cambios
                    </button>
                </div>
            </form>
        </div>
    </div>
</section>

<script>
    var profileMap = null;
    var profileMarker = null;

    function loadProfileData() {
        fetch('PerfilClienteServlet')
            .then(response => response.json())
            .then(data => {
                if (data.error) { console.error("Error:", data.error); return; }
                
                document.getElementById('profileNombre').value = data.nombre || '';
                document.getElementById('profileEmail').value = data.email || '';
                document.getElementById('profileTelefono').value = data.telefono || '';
                document.getElementById('profileDireccion').value = data.direccion || '';
                document.getElementById('profileFechaNac').value = data.fechaNacimiento || '';
                
                document.getElementById('profileNameDisplay').innerText = data.nombre || 'Usuario';
                document.getElementById('profileInitial').innerText = data.nombre ? data.nombre.substring(0,1).toUpperCase() : 'U';
                
                var lat = parseFloat(data.lat);
                var lng = parseFloat(data.lng);
                initProfileMap(lat, lng);
            })
            .catch(error => console.error("Error:", error));
    }

    function initProfileMap(lat, lng) {
        if (profileMap) return;
        var hasCoords = !isNaN(lat) && !isNaN(lng);
        var center = hasCoords ? [lat, lng] : [-6.7714, -79.8409];
        var zoom = hasCoords ? 16 : 13;

        profileMap = L.map('profileMap').setView(center, zoom);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; OpenStreetMap'
        }).addTo(profileMap);

        if (hasCoords) {
            profileMarker = L.marker(center).addTo(profileMap);
            profileMarker.bindPopup('Tu ubicaci&oacute;n de recojo').openPopup();
            var coordsInfo = document.getElementById('profileCoords');
            coordsInfo.style.display = 'block';
            coordsInfo.innerHTML = '<i class="fas fa-check-circle"></i> Ubicaci&oacute;n registrada: ' + lat.toFixed(6) + ', ' + lng.toFixed(6);
        }

        setTimeout(function(){ profileMap.invalidateSize(); }, 300);
    }

    document.addEventListener("DOMContentLoaded", function() { loadProfileData(); });
</script>