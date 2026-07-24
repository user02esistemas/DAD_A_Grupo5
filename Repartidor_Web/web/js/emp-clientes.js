var selectedClientId = null;
var selectedClientData = null;
var bonoSearchResults = [];

function switchClienteTab(tab) {
    document.getElementById('tabBtnRegistrar').className = tab === 'registrar' ? 'btn btn-primary' : 'btn btn-outline';
    document.getElementById('tabBtnBonos').className = tab === 'bonos' ? 'btn btn-primary' : 'btn btn-outline';
    document.getElementById('emp-tab-registrar').style.display = tab === 'registrar' ? 'block' : 'none';
    document.getElementById('emp-tab-bonos').style.display = tab === 'bonos' ? 'block' : 'none';
}

function registrarClienteEmp() {
    var form = document.getElementById('formRegistrarClienteEmp');
    var fd = new URLSearchParams(new FormData(form));
    if (!fd.get('nombre') || fd.get('nombre').trim() === '') {
        empNotify('Ingresa el nombre del cliente', 'error');
        return;
    }
    fd.append('accion', 'registrar_cliente_rapido');
    fetch('EmpClienteServlet', { method: 'POST', body: fd })
        .then(function(r) { return r.text(); })
        .then(function(res) {
            if (res.trim() === 'success') {
                empNotify('Cliente registrado exitosamente', 'success');
                form.reset();
            } else {
                empNotify('Error: ' + res, 'error');
            }
        })
        .catch(function() { empNotify('Error de conexion', 'error'); });
}

function buscarClienteEmp() {
    var q = document.getElementById('empSearchCliente').value.trim();
    var container = document.getElementById('empResultadosCliente');
    if (q.length < 2) {
        container.innerHTML = '<div style="text-align:center; padding:20px; color:var(--gray-400);"><i class="fas fa-search" style="font-size:24px;"></i><p style="margin-top:8px;">Escribe para buscar un cliente</p></div>';
        return;
    }
    fetch('EmpClienteServlet?accion=buscar_cliente&q=' + encodeURIComponent(q))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.length === 0) {
                container.innerHTML = '<div style="text-align:center; padding:20px; color:var(--gray-400);">No se encontraron clientes</div>';
                return;
            }
            var html = '';
            for (var i = 0; i < data.length; i++) {
                var c = data[i];
                html += '<div class="emp-cliente-search-item">';
                html += '<div><div style="font-weight:600;">' + esc(c.nombre) + '</div>';
                html += '<div style="font-size:12px; color:var(--gray-500);">' + esc(c.telefono) + ' | ' + esc(c.email) + '</div></div>';
                html += '<div style="text-align:right;"><span class="nivel-badge nivel-bronce">' + c.puntos + ' pts</span></div>';
                html += '</div>';
            }
            container.innerHTML = html;
        })
        .catch(function() { container.innerHTML = '<div style="text-align:center; padding:15px; color:#dc3545;">Error al buscar</div>'; });
}

function buscarClienteBono() {
    var q = document.getElementById('empBonoSearch').value.trim();
    var container = document.getElementById('empBonoResultados');
    var form = document.getElementById('empBonoForm');

    if (q.length < 2) {
        container.innerHTML = '<div style="text-align:center; padding:15px; color:var(--gray-400); font-size:13px;"><i class="fas fa-search"></i> Escribe nombre o telefono</div>';
        form.style.display = 'none';
        return;
    }

    fetch('EmpClienteServlet?accion=buscar_cliente&q=' + encodeURIComponent(q))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            bonoSearchResults = data;
            if (data.length === 0) {
                container.innerHTML = '<div style="text-align:center; padding:15px; color:var(--gray-400);">No encontrado</div>';
                form.style.display = 'none';
                return;
            }
            var html = '';
            for (var i = 0; i < data.length; i++) {
                var c = data[i];
                html += '<div class="emp-cliente-search-item" data-idx="' + i + '" onclick="seleccionarClienteBono(' + i + ')">';
                html += '<div><div style="font-weight:600;">' + esc(c.nombre) + '</div>';
                html += '<div style="font-size:12px; color:var(--gray-500);">' + esc(c.telefono) + '</div></div>';
                html += '<span class="nivel-badge nivel-bronce">' + c.puntos + ' pts</span>';
                html += '</div>';
            }
            container.innerHTML = html;
        });
}

function seleccionarClienteBono(idx) {
    var c = bonoSearchResults[idx];
    if (!c) return;

    selectedClientId = c.id;
    selectedClientData = c;

    document.getElementById('empBonoClienteNombre').textContent = c.nombre;
    document.getElementById('empBonoClientePuntos').textContent = c.puntos;
    document.getElementById('empBonoForm').style.display = 'block';

    document.getElementById('empBonoResultados').innerHTML =
        '<div class="emp-cliente-search-item" style="background:var(--gray-50);">' +
        '<div><div style="font-weight:600;">' + esc(c.nombre) + '</div>' +
        '<div style="font-size:12px; color:var(--gray-500);">' + esc(c.telefono) + '</div></div>' +
        '<span class="nivel-badge nivel-bronce">' + c.puntos + ' pts</span></div>';
}

function seleccionarTipoBono(btn, tipo) {
    document.querySelectorAll('.bono-tipo-btn').forEach(function(b) { b.classList.remove('bono-tipo-active'); });
    btn.classList.add('bono-tipo-active');
    document.getElementById('bonoTipoHidden').value = tipo;

    var lbl = document.getElementById('bonoCantidadLabel');
    var inp = document.getElementById('empBonoPuntos');
    var quickBtns = document.getElementById('bonoQuickBtns');

    if (tipo === 'descuento') {
        lbl.textContent = 'Porcentaje de descuento';
        inp.placeholder = 'Ej: 10, 15, 20';
        inp.max = 50;
        quickBtns.innerHTML =
            '<button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById(\'empBonoPuntos\').value=10">10%</button>' +
            '<button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById(\'empBonoPuntos\').value=15">15%</button>' +
            '<button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById(\'empBonoPuntos\').value=20">20%</button>' +
            '<button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById(\'empBonoPuntos\').value=25">25%</button>';
    } else if (tipo === 'lavado_gratis') {
        lbl.textContent = 'Servicio incluido';
        inp.value = 1;
        inp.max = 1;
        quickBtns.innerHTML = '<span style="font-size:12px; color:var(--gray-500);">Lavado Simple gratis (S/15 de valor)</span>';
    } else if (tipo === 'upgrade_gratis') {
        lbl.textContent = 'Servicio incluido';
        inp.value = 1;
        inp.max = 1;
        quickBtns.innerHTML = '<span style="font-size:12px; color:var(--gray-500);">Upgrade a Premium gratis (diferencia de S/10)</span>';
    } else {
        lbl.textContent = 'Puntos a otorgar';
        inp.placeholder = 'Ej: 10, 25, 50';
        inp.max = 1000;
        quickBtns.innerHTML =
            '<button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById(\'empBonoPuntos\').value=5">5 pts</button>' +
            '<button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById(\'empBonoPuntos\').value=10">10 pts</button>' +
            '<button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById(\'empBonoPuntos\').value=25">25 pts</button>' +
            '<button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById(\'empBonoPuntos\').value=50">50 pts</button>';
    }
}

function asignarBono() {
    if (!selectedClientId) {
        empNotify('Selecciona un cliente primero', 'error');
        return;
    }
    var tipo = document.getElementById('bonoTipoHidden').value;
    var puntos = parseInt(document.getElementById('empBonoPuntos').value);
    var motivo = document.getElementById('empBonoMotivoCustom').value.trim();

    if (!puntos || puntos <= 0) {
        empNotify('Ingresa una cantidad valida', 'error');
        return;
    }

    var fd = new URLSearchParams();
    fd.append('accion', 'asignar_bono');
    fd.append('idCliente', selectedClientId);
    fd.append('puntos', puntos);
    fd.append('tipo', tipo);
    fd.append('motivo', motivo || getDefaultMotivo(tipo));

    fetch('EmpClienteServlet', { method: 'POST', body: fd })
        .then(function(r) { return r.text(); })
        .then(function(res) {
            if (res.trim() === 'success') {
                var msg = '';
                if (tipo === 'descuento') msg = 'Bono de ' + puntos + '% de descuento otorgado';
                else if (tipo === 'lavado_gratis') msg = 'Bono de Lavado Gratis otorgado';
                else if (tipo === 'upgrade_gratis') msg = 'Bono de Upgrade Gratis otorgado';
                else msg = 'Bono de ' + puntos + ' puntos otorgado';
                empNotify(msg, 'success');
                resetBonoForm();
            } else {
                empNotify('Error: ' + res, 'error');
            }
        })
        .catch(function() { empNotify('Error de conexion', 'error'); });
}

function getDefaultMotivo(tipo) {
    if (tipo === 'descuento') return 'Descuento por consumo';
    if (tipo === 'lavado_gratis') return 'Lavado Simple gratis';
    if (tipo === 'upgrade_gratis') return 'Upgrade a Premium gratis';
    return 'Bono por consumo';
}

function resetBonoForm() {
    selectedClientId = null;
    selectedClientData = null;
    document.getElementById('empBonoForm').style.display = 'none';
    document.getElementById('empBonoSearch').value = '';
    document.getElementById('empBonoResultados').innerHTML = '<div style="text-align:center; padding:15px; color:var(--gray-400); font-size:13px;"><i class="fas fa-search"></i> Escribe nombre o telefono</div>';
    document.getElementById('empBonoPuntos').value = 10;
    document.getElementById('empBonoMotivoCustom').value = '';
    document.querySelectorAll('.bono-tipo-btn').forEach(function(b) { b.classList.remove('bono-tipo-active'); });
    document.getElementById('bonoTipoHidden').value = 'puntos';
    document.querySelector('.bono-tipo-btn[data-tipo="puntos"]').classList.add('bono-tipo-active');
}

function buscarClienteResumen() {
    var q = document.getElementById('empResumenSearch').value.trim();
    if (q.length < 2) {
        document.getElementById('resumenPlaceholder').style.display = 'block';
        document.getElementById('resumenInfo').style.display = 'none';
        return;
    }
    fetch('EmpClienteServlet?accion=buscar_cliente&q=' + encodeURIComponent(q))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.length === 0) {
                document.getElementById('resumenPlaceholder').innerHTML = '<i class="fas fa-user-slash" style="font-size:32px;"></i><p style="margin-top:8px;">Cliente no encontrado</p>';
                document.getElementById('resumenPlaceholder').style.display = 'block';
                document.getElementById('resumenInfo').style.display = 'none';
                return;
            }
            var c = data[0];
            document.getElementById('resumenPlaceholder').style.display = 'none';
            document.getElementById('resumenInfo').style.display = 'block';
            document.getElementById('resumenPuntos').textContent = c.puntos;

            var nivel = 'Bronce';
            var nextPts = 50;
            if (c.puntos >= 500) { nivel = 'Platino'; nextPts = 9999; }
            else if (c.puntos >= 200) { nivel = 'Oro'; nextPts = 500; }
            else if (c.puntos >= 50) { nivel = 'Plata'; nextPts = 200; }

            document.getElementById('resumenNivel').textContent = nivel;
            document.getElementById('resumenNivel').className = '';
            document.getElementById('resumenNivel').classList.add('nivel-badge', 'nivel-' + nivel.toLowerCase());
            document.getElementById('resumenProgreso').textContent = c.puntos + '/' + nextPts + ' pts';
            var pct = Math.min(100, (c.puntos / nextPts) * 100);
            document.getElementById('resumenBarra').style.width = pct + '%';

            fetch('EmpClienteServlet?accion=listar_bonos&idCliente=' + c.id)
                .then(function(r2) { return r2.json(); })
                .then(function(bonos) {
                    var html = '';
                    if (bonos.length === 0) {
                        html = '<div style="text-align:center; padding:10px; color:var(--gray-400); font-size:12px;">Sin historial de bonos</div>';
                    } else {
                        for (var i = bonos.length - 1; i >= 0; i--) {
                            var b = bonos[i];
                            var icon = 'fa-star';
                            var color = '#f59e0b';
                            if (b.tipo === 'descuento') { icon = 'fa-percent'; color = '#2563eb'; }
                            else if (b.tipo === 'lavado_gratis') { icon = 'fa-shirt'; color = '#22c55e'; }
                            else if (b.tipo === 'upgrade_gratis') { icon = 'fa-arrow-up'; color = '#8b5cf6'; }

                            html += '<div class="emp-cliente-bono-item">';
                            html += '<div style="display:flex; align-items:center; gap:8px;">';
                            html += '<i class="fas ' + icon + '" style="color:' + color + '; width:16px; text-align:center;"></i>';
                            html += '<div><div style="font-weight:600; color:var(--aqua-dark);">' + esc(b.descripcion) + '</div>';
                            html += '<div style="font-size:11px; color:var(--gray-500);">' + esc(b.motivo) + '</div></div></div>';
                            html += '<div style="text-align:right; font-size:11px; color:var(--gray-400);"><div>' + b.fecha + '</div>';
                            html += '<div>por ' + esc(b.empleado) + '</div></div>';
                            html += '</div>';
                        }
                    }
                    document.getElementById('resumenHistorial').innerHTML = html;
                });
        });
}

function esc(text) {
    if (!text) return '';
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(text));
    return div.innerHTML;
}
