document.addEventListener("DOMContentLoaded", () => {
    const urlParams = new URLSearchParams(window.location.search);
    const view = urlParams.get('view');
    
    if (view) {
        showView(view, false);
    } else {
        const dashLink = document.querySelector('.nav-link[data-view="dashboard"]');
        if(dashLink) dashLink.classList.add('active');
    }

    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const localIso = new Date(tomorrow.getTime() - (tomorrow.getTimezoneOffset() * 60000)).toISOString().slice(0,16);
    
    const dateInputService = document.getElementById('serviceDate');
    if(dateInputService) dateInputService.value = localIso.split('T')[0];
});


window.addEventListener('popstate', (event) => {
    const urlParams = new URLSearchParams(window.location.search);
    const view = urlParams.get('view') || 'dashboard';
    showView(view, false);
});

function showView(viewId, pushState = true) {
    document.querySelectorAll('.section').forEach(sec => sec.classList.remove('active'));
    document.querySelectorAll('.nav-link').forEach(link => link.classList.remove('active'));
    
    const targetSection = document.getElementById(viewId);
    if (targetSection) targetSection.classList.add('active');
    
    const activeLink = document.querySelector(`.nav-link[data-view="${viewId}"]`);
    if (activeLink) activeLink.classList.add('active');

    if (pushState) {
        const newUrl = new URL(window.location);
        newUrl.searchParams.set('view', viewId);
        window.history.pushState({}, '', newUrl);
    }
}

// ======================================================
// MÓDULO: AGENDAR SERVICIO (LAVANDÍA / CITAS)
// ======================================================

function selectServiceItem(id, price) {
    document.querySelectorAll('.service-option').forEach(el => el.classList.remove('selected'));
    document.getElementById('serv_' + id).classList.add('selected');
    
    document.getElementById('selectedServiceId').value = id;
    document.getElementById('selectedServicePrice').value = price;
    
    const name = document.getElementById('serv_' + id).querySelector('div').innerText;
    document.getElementById('summaryName').innerText = name;
    document.getElementById('summaryTotal').innerText = "S/ " + price.toFixed(2);
}

function toggleServiceAddress(isDelivery) {
    const addr = document.getElementById('serviceAddressGroup');
    const labelMode = document.getElementById('summaryMode');
    const mainBtn = document.getElementById('btnSubmitService');

    if (isDelivery) {
        addr.style.display = 'block';
        labelMode.innerText = "Delivery Recojo";
        if(mainBtn) {
            mainBtn.innerText = "Confirmar y Pagar";
            mainBtn.style.backgroundColor = "var(--aqua)";
            mainBtn.style.color = "var(--dark)";
        }
    } else {
        addr.style.display = 'none';
        labelMode.innerText = "En Local";
        if(mainBtn) {
            mainBtn.innerText = "Agendar Reserva";
            mainBtn.style.backgroundColor = "#ffc107";
            mainBtn.style.color = "black";
        }
    }
}

function selectTime(btn, time) {
    document.querySelectorAll('.time-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById('selectedTime').value = time;
    
    const date = document.getElementById('serviceDate').value;
    document.getElementById('summaryDate').innerText = date + " " + time;
}

function openServicePayment() {
    if (!document.getElementById('selectedServiceId').value) return showNotification("Debes elegir un servicio.", "error");
    if (!document.getElementById('selectedTime').value || !document.getElementById('serviceDate').value) return showNotification("Selecciona fecha y hora.", "error");
    
    const isDelivery = document.querySelector('input[name="modalidadServ"][value="Delivery Recojo"]').checked;
    
    if (isDelivery && document.getElementById('serviceAddress').value.trim() === "") {
        return showNotification("Ingresa la dirección de recojo.", "error");
    }

    if (!isDelivery) {
        if(confirm("¿Confirmar reserva de turno?\nEl pago se realizará en el local.")) {
            submitServiceOrder('Pendiente');
        }
    } else {
        document.getElementById('payServiceAmount').innerText = document.getElementById('summaryTotal').innerText;
        document.getElementById('modalServicePayment').style.display = "flex";
    }
}

function submitServiceOrder(metodoPagoDirecto = null) {
    document.getElementById('modalServicePayment').style.display = "none";
    
    const fd = new URLSearchParams();
    fd.append('idServicio', document.getElementById('selectedServiceId').value);
    
    const mode = document.querySelector('input[name="modalidadServ"]:checked').value;
    fd.append('modalidad', mode);
    
    const dir = mode === 'Delivery Recojo' ? document.getElementById('serviceAddress').value : 'Tienda Principal';
    fd.append('direccion', dir);
    
    fd.append('fecha', document.getElementById('serviceDate').value);
    fd.append('hora', document.getElementById('selectedTime').value);
    
    const metodo = metodoPagoDirecto ? metodoPagoDirecto : 'Tarjeta Web';
    fd.append('metodoPago', metodo);

    fetch('ServicioClienteServlet', { method: 'POST', body: fd })
    .then(r => r.text())
    .then(res => {
        if(res.trim() === 'success') {
            const msg = (metodo === 'Pendiente') ? "Cita Reservada Correctamente" : "Servicio Pagado y Agendado";
            showNotification(msg, "success");
            setTimeout(() => { window.location.href = "client.jsp?view=orders"; }, 1500);
        } else {
            showNotification("Error: " + res, "error");
        }
    })
    .catch(err => console.error(err));
}

function cancelarPedido(id) {
    if(!confirm("¿Estás seguro de que deseas cancelar esta cita?\nEsta acción eliminará la reserva de forma permanente.")) {
        return;
    }
    
    const fd = new URLSearchParams();
    fd.append('accion', 'cancelar');
    fd.append('idPedido', id);
    
    fetch('OrdenClienteServlet', { method: 'POST', body: fd })
    .then(r => r.text())
    .then(res => {
        if(res.trim() === 'success') {
            showNotification("Cita cancelada correctamente.", "success");
            setTimeout(() => { location.reload(); }, 1500); 
        } else {
            showNotification("Error al cancelar: " + res, "error");
        }
    })
    .catch(err => console.error(err));
}

function updateProfile() {
    const btn = document.querySelector('#formProfile button');
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Guardando...';
    btn.disabled = true;

    const fd = new URLSearchParams(new FormData(document.getElementById('formProfile')));
    
    fetch('PerfilClienteServlet', { method: 'POST', body: fd })
    .then(r => r.text())
    .then(res => {
        if(res.trim() === 'success') {
            showNotification("Perfil actualizado correctamente.", "success");
            setTimeout(() => { location.reload(); }, 1000);
        } else {
            showNotification("Error: " + res, "error");
            btn.innerHTML = originalText;
            btn.disabled = false;
        }
    })
    .catch(err => {
        console.error(err);
        showNotification("Error de conexión.", "error");
        btn.innerHTML = originalText;
        btn.disabled = false;
    });
}

// ======================================================
// UTILIDADES COMUNES
// ======================================================

function showNotification(msg, type) {
    const notif = document.getElementById('notification');
    const txt = document.getElementById('notificationMessage');
    
    if(notif && txt) {
        txt.innerText = msg;
        notif.style.borderLeftColor = type === 'error' ? '#dc3545' : '#40E0D0';
        notif.style.transform = "translateX(0)";
        setTimeout(() => {
            notif.style.transform = "translateX(150%)";
        }, 3000);
    }
}

function formatTimestamp(ts) {
    const d = new Date(ts);
    const now = new Date();
    const diffMs = now - d;
    const diffMin = Math.floor(diffMs / 60000);
    
    if (diffMin < 1) return 'Ahora mismo';
    if (diffMin < 60) return 'Hace ' + diffMin + ' min';
    
    const diffHrs = Math.floor(diffMin / 60);
    if (diffHrs < 24) return 'Hace ' + diffHrs + 'h';
    
    const day = d.getDate().toString().padStart(2, '0');
    const month = (d.getMonth() + 1).toString().padStart(2, '0');
    return day + '/' + month + ' ' + d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0');
}

// ======================================================
// SISTEMA DE NOTIFICACIONES EN TIEMPO REAL
// ======================================================

const NotificacionesRT = {
    socket: null,
    idCliente: null,
    notificaciones: [],
    maxHistorial: 30,
    reconectando: false,
    intentosReconexion: 0,
    maxReintentos: 20,

    init: function(idCliente) {
        if (!idCliente) return;
        this.idCliente = idCliente;
        this.cargarHistorial();
        this.conectar();
        this.renderizarBadge();
    },

    conectar: function() {
        if (this.socket && this.socket.readyState === WebSocket.OPEN) return;

        const wsUrl = "ws://" + window.location.host + "/AdminEmpleado_Web/notificaciones/" + this.idCliente;
        this.socket = new WebSocket(wsUrl);

        this.socket.onopen = () => {
            console.log("[NotificacionesRT] Conectado");
            this.reconectando = false;
            this.intentosReconexion = 0;
            this.actualizarEstadoConexion(true);
        };

        this.socket.onmessage = (event) => {
            this.procesarMensaje(event.data);
        };

        this.socket.onclose = () => {
            console.log("[NotificacionesRT] Desconectado");
            this.actualizarEstadoConexion(false);
            this.programarReconexion();
        };

        this.socket.onerror = (error) => {
            console.error("[NotificacionesRT] Error:", error);
            this.actualizarEstadoConexion(false);
        };
    },

    procesarMensaje: function(data) {
        try {
            const parsed = JSON.parse(data);
            
            if (Array.isArray(parsed)) {
                parsed.forEach(notif => this.procesarNotificacion(notif));
                return;
            }

            if (parsed.tipo === 'conexion') {
                console.log("[NotificacionesRT] " + parsed.mensaje);
                return;
            }

            this.procesarNotificacion(parsed);
        } catch (e) {
            this.procesarNotificacion({
                tipo: 'sistema',
                mensaje: data,
                timestamp: Date.now(),
                icono: 'fa-bell',
                color: 'aqua'
            });
        }
    },

    procesarNotificacion: function(notif) {
        if (!notif.timestamp) notif.timestamp = Date.now();
        if (!notif.leida) notif.leida = false;

        this.notificaciones.unshift(notif);
        if (this.notificaciones.length > this.maxHistorial) {
            this.notificaciones = this.notificaciones.slice(0, this.maxHistorial);
        }

        this.guardarHistorial();
        this.renderizarBadge();
        this.renderizarPanel();

        const tipo = notif.tipo || 'sistema';
        if (tipo === 'pedido_estado' || tipo === 'pedido_entregado' || tipo === 'pedido_cancelado') {
            this.refrescarVistas();
            this.resaltarPedido(notif.idPedido);
        }

        const colorMap = {
            'info': 'info',
            'success': 'success',
            'danger': 'danger',
            'warning': 'warning',
            'aqua': 'success'
        };
        const toastType = colorMap[notif.color] || 'success';
        showNotification(notif.mensaje, toastType);
    },

    refrescarVistas: function() {
        if (typeof loadDashboardData === 'function') {
            setTimeout(() => loadDashboardData(), 300);
        }
        if (typeof loadOrdersData === 'function') {
            setTimeout(() => loadOrdersData(), 300);
        }
    },

    resaltarPedido: function(idPedido) {
        if (!idPedido) return;
        setTimeout(() => {
            const card = document.getElementById('pedido-' + idPedido);
            if (card) {
                card.classList.add('pedido-actualizado');
                card.scrollIntoView({ behavior: 'smooth', block: 'center' });
                setTimeout(() => card.classList.remove('pedido-actualizado'), 3000);
            }
        }, 500);
    },

    programarReconexion: function() {
        if (this.reconectando) return;
        this.reconectando = true;

        const intentar = () => {
            if (this.intentosReconexion >= this.maxReintentos) {
                console.log("[NotificacionesRT] Maximos reintentos alcanzados");
                return;
            }
            this.intentosReconexion++;
            const delay = Math.min(1000 * Math.pow(1.5, this.intentosReconexion - 1), 30000);
            console.log("[NotificacionesRT] Reconexion en " + delay + "ms (intento " + this.intentosReconexion + ")");
            setTimeout(() => {
                this.reconectando = false;
                this.conectar();
            }, delay);
        };
        intentar();
    },

    actualizarEstadoConexion: function(conectado) {
        const dot = document.getElementById('wsStatusDot');
        const label = document.getElementById('wsStatusLabel');
        if (dot) {
            dot.className = conectado ? 'ws-dot connected' : 'ws-dot disconnected';
        }
        if (label) {
            label.textContent = conectado ? 'Conectado' : 'Desconectado';
            label.style.color = conectado ? 'var(--success)' : 'var(--danger)';
        }
    },

    togglePanel: function() {
        const panel = document.getElementById('notifPanel');
        const overlay = document.getElementById('notifOverlay');
        if (!panel) return;

        const isVisible = panel.classList.contains('open');
        if (isVisible) {
            panel.classList.remove('open');
            if (overlay) overlay.classList.remove('open');
        } else {
            panel.classList.add('open');
            if (overlay) overlay.classList.add('open');
            this.marcarTodasLeidas();
        }
    },

    renderizarBadge: function() {
        const badge = document.getElementById('notifBadge');
        if (!badge) return;

        const noLeidas = this.notificaciones.filter(n => !n.leida).length;
        if (noLeidas > 0) {
            badge.textContent = noLeidas > 99 ? '99+' : noLeidas;
            badge.style.display = 'flex';
        } else {
            badge.style.display = 'none';
        }
    },

    renderizarPanel: function() {
        const list = document.getElementById('notifList');
        if (!list) return;

        if (this.notificaciones.length === 0) {
            list.innerHTML = '<div class="notif-empty"><i class="fas fa-bell-slash"></i><p>Sin notificaciones</p></div>';
            return;
        }

        list.innerHTML = this.notificaciones.map((n, i) => {
            const iconClass = n.icono || 'fa-bell';
            const colorVar = 'var(--' + (n.color || 'aqua') + ')';
            const leidaClass = n.leida ? 'leida' : 'no-leida';
            const tiempo = formatTimestamp(n.timestamp);
            const pedidoTag = n.idPedido ? '<span class="notif-pedido-tag">#' + n.idPedido + '</span>' : '';

            return '<div class="notif-item ' + leidaClass + '" onclick="NotificacionesRT.marcarLeida(' + i + ')">'
                + '<div class="notif-icon" style="background:' + colorVar + '20; color:' + colorVar + ';">'
                + '<i class="fas ' + iconClass + '"></i></div>'
                + '<div class="notif-content">'
                + '<div class="notif-mensaje">' + n.mensaje + ' ' + pedidoTag + '</div>'
                + '<div class="notif-tiempo">' + tiempo + '</div>'
                + '</div></div>';
        }).join('');
    },

    marcarLeida: function(index) {
        if (this.notificaciones[index]) {
            this.notificaciones[index].leida = true;
            this.guardarHistorial();
            this.renderizarBadge();
            this.renderizarPanel();
        }
    },

    marcarTodasLeidas: function() {
        this.notificaciones.forEach(n => n.leida = true);
        this.guardarHistorial();
        this.renderizarBadge();
        this.renderizarPanel();
    },

    limpiarHistorial: function() {
        this.notificaciones = [];
        this.guardarHistorial();
        this.renderizarBadge();
        this.renderizarPanel();
    },

    guardarHistorial: function() {
        try {
            const key = 'notif_historial_' + this.idCliente;
            localStorage.setItem(key, JSON.stringify(this.notificaciones.slice(0, this.maxHistorial)));
        } catch (e) { /* silently fail */ }
    },

    cargarHistorial: function() {
        try {
            const key = 'notif_historial_' + this.idCliente;
            const data = localStorage.getItem(key);
            if (data) {
                this.notificaciones = JSON.parse(data);
            }
        } catch (e) {
            this.notificaciones = [];
        }
    }
};

function initWebSocket(idCliente) {
    NotificacionesRT.init(idCliente);
}

function toggleNotifPanel() {
    NotificacionesRT.togglePanel();
    const overlay = document.getElementById('notifOverlay');
    const panel = document.getElementById('notifPanel');
    if (overlay && panel) {
        const isOpen = panel.classList.contains('open');
        overlay.classList.toggle('open', isOpen);
    }
}

function limpiarNotificaciones() {
    NotificacionesRT.limpiarHistorial();
}
