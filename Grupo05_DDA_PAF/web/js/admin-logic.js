/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

var currentCalendarDate = new Date(); 
var selectedDateObj = null;           
var selectedTime = null;
var currentSection = 'dashboard'; 
var currentTrackingTab = 'servicios';

// ==========================================
// 1. INICIALIZACIÓN Y NAVEGACIÓN
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const viewParam = urlParams.get('view');
    const tabParam = urlParams.get('tab');

    if(viewParam) { 
        showSection(viewParam); 
        currentSection = viewParam; 
    }

    if (viewParam === 'tracking' && tabParam) {
        setTimeout(() => {
            switchTrackingTab(tabParam);
        }, 50);
    }

    document.querySelectorAll('.nav-link').forEach(link => { link.addEventListener('click', (e) => { /* handled via onclick */ }); });
    renderCalendar(); 
    renderTimeSlots();
});

function showSection(sectionId, mode = null) {
    currentSection = sectionId;
    
    document.querySelectorAll('.section').forEach(sec => sec.classList.remove('active'));
    document.querySelectorAll('.nav-link').forEach(link => link.classList.remove('active'));
    
    const target = document.getElementById(sectionId);
    if (target) target.classList.add('active');
    
    const activeLink = document.querySelector(`[data-section="${sectionId}"]`);
    if (activeLink) activeLink.classList.add('active');
    
    if (sectionId === 'appointment') {
        setTimeout(() => {
            renderCalendar(); renderTimeSlots();
            if (mode) {
                const radio = document.querySelector(`input[name="deliveryMode"][value="${mode}"]`);
                if(radio) { radio.checked = true; }
            }
            toggleDeliveryMode(); toggleClientMode(); calculateCost();      
        }, 50);
    }
}

// ==========================================
// 2. MÓDULO: SEGUIMIENTO (TRACKING 3 TABS)
// ==========================================

function switchTrackingTab(tab) {
    currentTrackingTab = tab;
    
    const bodyServ = document.getElementById('tablaServiciosBody');
    const bodyDel = document.getElementById('tablaDeliveryBody');
    const bodyRec = document.getElementById('tablaRecojoBody');
    
    const btnServ = document.getElementById('tabBtnServ');
    const btnDel = document.getElementById('tabBtnDel');
    const btnRec = document.getElementById('tabBtnRec');
    const title = document.getElementById('trackingTitle');

    [btnServ, btnDel, btnRec].forEach(b => {
        if(b) { b.style.background = '#e9ecef'; b.style.color = '#666'; b.style.fontWeight = 'normal'; }
    });

    if(bodyServ) bodyServ.style.display = 'none';
    if(bodyDel) bodyDel.style.display = 'none';
    if(bodyRec) bodyRec.style.display = 'none';

    if (tab === 'servicios') {
        if(bodyServ) bodyServ.style.display = '';
        if(btnServ) { btnServ.style.background = 'var(--color-aqua)'; btnServ.style.color = 'var(--color-dark)'; btnServ.style.fontWeight = 'bold'; }
        if(title) title.innerText = "Cola de Servicios (Lavado)";
    } else if (tab === 'delivery') {
        if(bodyDel) bodyDel.style.display = '';
        if(btnDel) { btnDel.style.background = 'var(--color-aqua)'; btnDel.style.color = 'var(--color-dark)'; btnDel.style.fontWeight = 'bold'; }
        if(title) title.innerText = "Envíos Pendientes (Delivery)";
    } else {
        if(bodyRec) bodyRec.style.display = '';
        if(btnRec) { btnRec.style.background = 'var(--color-aqua)'; btnRec.style.color = 'var(--color-dark)'; btnRec.style.fontWeight = 'bold'; }
        if(title) title.innerText = "Retiros en Tienda (Recojo)";
    }
    
    filtrarPedidos();
}

function filtrarPedidos() {
    const input = document.getElementById("searchInput");
    if(!input) return;
    const filter = input.value.toUpperCase();
    
    let tableBody;
    if(currentTrackingTab === 'servicios') tableBody = document.getElementById("tablaServiciosBody");
    else if(currentTrackingTab === 'delivery') tableBody = document.getElementById("tablaDeliveryBody");
    else tableBody = document.getElementById("tablaRecojoBody");
    
    if(!tableBody) return;

    const tr = tableBody.getElementsByTagName("tr");
    for (let i = 0; i < tr.length; i++) {
        const td1 = tr[i].getElementsByTagName("td")[0];
        const td2 = tr[i].getElementsByTagName("td")[1];
        if (td1 || td2) {
            if ((td1.innerText + td2.innerText).toUpperCase().indexOf(filter) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }
}

function abrirModalSeguimiento(id, tipo) {
    document.getElementById('trackingModal').style.display = 'flex';
    document.getElementById('modalCliente').value = "Cargando...";
    
    const select = document.getElementById('modalEstado');
    select.innerHTML = ''; 
    
    let ops = [];
    if (tipo === 'servicio') {
        ops = ['Recibido', 'En Lavado', 'Terminado', 'Entregado', 'Cancelado'];
    } else if (tipo === 'delivery') {
        ops = ['Preparando Envío', 'En Camino', 'Entregado', 'Cancelado'];
    } else { // Recojo
        ops = ['Preparando para Recojo', 'Listo para Recoger', 'Entregado', 'Cancelado'];
    }
    
    ops.forEach(op => select.add(new Option(op, op)));

    fetch(`TrackingServlet?id=${id}`).then(r => r.json()).then(d => {
        if (d.id) {
            document.getElementById('modalIdHidden').value = d.id;
            document.getElementById('modalId').innerText = d.id;
            document.getElementById('modalCliente').value = d.cliente + " (" + d.servicio + ")";
            
            let exists = false;
            for(let i=0; i<select.options.length; i++) if(select.options[i].value == d.estado) exists = true;
            if(!exists) { 
                const opt = new Option(d.estado, d.estado); 
                opt.style.color = "#6f42c1"; 
                select.add(opt, 0); 
            }
            select.value = d.estado;

            document.getElementById('modalHistorial').value = d.notas || "";
            document.getElementById('modalNotasAnt').value = d.notas || "";
            document.getElementById('modalMonto').value = d.monto || 0;
            document.getElementById('modalEstadoOriginal').value = d.estado;
        }
    });
}

function cerrarModalSeguimiento() { document.getElementById('trackingModal').style.display = 'none'; }

function procesarSeguimiento() {
    const estadoOriginal = document.getElementById('modalEstadoOriginal').value;
    const nuevoEstado = document.getElementById('modalEstado').value;
    const monto = parseFloat(document.getElementById('modalMonto').value);

    if (estadoOriginal === 'Cita Programada' && nuevoEstado !== 'Cancelado' && nuevoEstado !== 'Cita Programada') {
        document.getElementById('trackingModal').style.display = 'none';
        document.getElementById('trackMontoDisplay').innerText = "S/ " + monto.toFixed(2);
        document.getElementById('modalPagoTracking').style.display = 'flex';
        document.getElementById('trackOpcionesPago').style.display = 'block';
        document.getElementById('trackFormTarjeta').style.display = 'none';
    } else {
        enviarActualizacionServidor(null);
    }
}

function mostrarFormTarjetaTracking() { document.getElementById('trackOpcionesPago').style.display = 'none'; document.getElementById('trackFormTarjeta').style.display = 'block'; }
function cancelarTarjetaTracking() { document.getElementById('trackFormTarjeta').style.display = 'none'; document.getElementById('trackOpcionesPago').style.display = 'block'; }
function cerrarModalPagoTracking() { document.getElementById('modalPagoTracking').style.display = 'none'; document.getElementById('trackingModal').style.display = 'flex'; }
function confirmarPagoTracking(metodo) { document.getElementById('modalPagoTracking').style.display = 'none'; enviarActualizacionServidor(metodo); }

function enviarActualizacionServidor(metodoPago) {
    const fd = new URLSearchParams();
    fd.append('idPedido', document.getElementById('modalIdHidden').value);
    fd.append('nuevoEstado', document.getElementById('modalEstado').value);
    fd.append('nuevaNota', document.getElementById('modalNotaNueva').value);
    fd.append('notasAnteriores', document.getElementById('modalNotasAnt').value);
    
    if (metodoPago) {
        fd.append('paymentMethod', metodoPago);
        fd.append('montoPago', document.getElementById('modalMonto').value);
    }
    
    fetch('TrackingServlet', { method: 'POST', body: fd }).then(r => r.text()).then(d => {
        if (d.trim() === 'success') {
            showNotification('✅ Actualizado', 'success');
            setTimeout(() => { 
                window.location.href = `admin.jsp?view=tracking&tab=${currentTrackingTab}`; 
            }, 1000);
        } else {
            showNotification('Error', 'error');
        }
    });
}

// ==========================================
// 3. MÓDULO: PRODUCTOS (CRUD)
// ==========================================

function previewImage(input){if(input.files&&input.files[0]){var r=new FileReader();r.onload=function(e){document.getElementById('imgPreview').src=e.target.result;};r.readAsDataURL(input.files[0]);}}
function abrirModalProducto(){document.getElementById('formProducto').reset();document.getElementById('prodAccion').value="nuevo_producto";document.getElementById('modalProducto').style.display='flex';}
function editarProducto(id){document.getElementById('modalProducto').style.display='flex';document.getElementById('modalProdTitle').innerText="Editar Producto";document.getElementById('prodAccion').value="actualizar_producto";fetch(`GestionServlet?accion=get_producto&id=${id}`).then(r=>r.json()).then(d=>{document.getElementById('prodId').value=d.id;document.getElementById('prodNombre').value=d.nombre;document.getElementById('prodDesc').value=d.desc;document.getElementById('prodPrecio').value=d.precio;document.getElementById('prodStock').value=d.stock;document.getElementById('prodImgUrl').value=d.imagen;if(d.imagen)document.getElementById('imgPreview').src=d.imagen;});}
function eliminarProducto(id){if(confirm("¿Eliminar este producto?")){fetch('GestionServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:`accion=eliminar_producto&id=${id}`}).then(()=>{window.location.href="admin.jsp?view=products";});}}

// ==========================================
// 4. MÓDULO: CLIENTES
// ==========================================
function filtrarClientes(){const i=document.getElementById("searchClient");const f=i.value.toUpperCase();const tr=document.getElementById("tablaClientesBody").getElementsByTagName("tr");for(let j=0;j<tr.length;j++){const td=tr[j].getElementsByTagName("td")[0];if(td){if(td.innerText.toUpperCase().indexOf(f)>-1)tr[j].style.display="";else tr[j].style.display="none";}}}
function abrirModalNuevoCliente(){document.getElementById('formNuevoCliente').reset();document.getElementById('modalNuevoCliente').style.display='flex';}
function guardarNuevoCliente(){const fd=new URLSearchParams(new FormData(document.getElementById('formNuevoCliente')));fetch('GestionServlet',{method:'POST',body:fd}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('✅ Cliente creado','success');document.getElementById('modalNuevoCliente').style.display='none';setTimeout(()=>{window.location.href="admin.jsp?view=clients";},1000);}else showNotification('Error','error');});}
function editarCliente(id){document.getElementById('modalEditarCliente').style.display='flex';fetch(`GestionServlet?accion=get_cliente&id=${id}`).then(r=>r.json()).then(d=>{if(d.id){document.getElementById('editId').value=d.id;document.getElementById('editNombre').value=d.nombre;document.getElementById('editEmail').value=d.email;document.getElementById('editPass').value=d.pass;document.getElementById('editTel').value=d.tel;document.getElementById('editDir').value=d.dir;document.getElementById('editNac').value=d.nac;document.getElementById('editRef').value=d.ref;document.getElementById('editPromo').checked=d.promo;}});}
function guardarEdicionCliente(){const fd=new URLSearchParams(new FormData(document.getElementById('formEditarCliente')));fetch('GestionServlet',{method:'POST',body:fd}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('✅ Actualizado','success');setTimeout(()=>{window.location.href="admin.jsp?view=clients";},1000);}else showNotification('Error','error');});}
function eliminarCliente(id,n){if(confirm("¿Eliminar "+n+"?")){fetch('GestionServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:`accion=eliminar_cliente&id=${id}`}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('Eliminado','success');setTimeout(()=>{window.location.href="admin.jsp?view=clients";},1000);}else showNotification('Error: tiene historial','error');});}}

// ==========================================
// 5. MÓDULO: EMPLEADOS
// ==========================================
function filtrarEmpleados(){const i=document.getElementById("searchEmployee");const f=i.value.toUpperCase();const tr=document.getElementById("tablaEmpleadosBody").getElementsByTagName("tr");for(let j=0;j<tr.length;j++){const td=tr[j].getElementsByTagName("td")[1];if(td){if(td.innerText.toUpperCase().indexOf(f)>-1)tr[j].style.display="";else tr[j].style.display="none";}}}
function editarEmpleado(id){document.getElementById('modalEmpleado').style.display='flex';fetch(`GestionServlet?accion=get_empleado&id=${id}`).then(r=>r.json()).then(d=>{document.getElementById('empId').value=d.id;document.getElementById('empNombre').value=d.nombre;document.getElementById('empCodigo').value=d.codigo;document.getElementById('empPass').value=d.pass;});}
function guardarEdicionEmpleado(){const fd=new URLSearchParams(new FormData(document.getElementById('formEmpleado')));fetch('GestionServlet',{method:'POST',body:fd}).then(()=>{window.location.href="admin.jsp?view=employees";});}
function abrirModalNuevoEmpleado(){document.getElementById('formNuevoEmpleado').reset();document.getElementById('modalNuevoEmpleado').style.display='flex';}
function guardarNuevoEmpleado(){const fd=new URLSearchParams(new FormData(document.getElementById('formNuevoEmpleado')));fetch('GestionServlet',{method:'POST',body:fd}).then(()=>{window.location.href="admin.jsp?view=employees";});}
function eliminarEmpleado(id,n){if(confirm("Borrar a "+n+"?")){fetch('GestionServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:`accion=eliminar_empleado&id=${id}`}).then(()=>{window.location.href="admin.jsp?view=employees";});}}

// ==========================================
// 6. MÓDULO: AGENDAR (ADMIN)
// ==========================================
function toggleDeliveryMode(){const r=document.querySelector('input[name="deliveryMode"]:checked');if(!r)return;const m=r.value;const c=document.getElementById('calendar-card');const d=document.querySelector('#appointment .dashboard-grid');const t=document.getElementById('formTitle');const tc=document.getElementById('totalContainer');const b=document.getElementById('mainActionBtn');if(m==='store'){c.style.display='none';d.style.display='block';t.innerText="Recepción Inmediata";tc.style.display='block';b.innerText="PROCESAR PEDIDO";b.className="btn btn-primary";selectedDateObj=new Date();selectedTime="00:00";}else if(m==='reservation'){c.style.display='block';d.style.gridTemplateColumns='repeat(auto-fit, minmax(300px, 1fr))';t.innerText="Reservar Turno";tc.style.display='none';b.innerText="RESERVAR TURNO";b.style.backgroundColor="#ffc107";b.style.color="black";resetCalendarSelection();}else{c.style.display='block';d.style.gridTemplateColumns='repeat(auto-fit, minmax(300px, 1fr))';t.innerText="Programar Delivery";tc.style.display='block';b.innerText="CONFIRMAR DELIVERY";b.style.backgroundColor="#40E0D0";b.style.color="black";resetCalendarSelection();}updateAddressVisibility();calculateCost();}
function updateAddressVisibility(){const d=document.querySelector('input[name="deliveryMode"]:checked');const g=document.querySelector('input[name="clientType"]:checked');const ag=document.getElementById('address-group');if(d&&g&&d.value==='delivery'&&g.value==='guest')ag.style.display='block';else ag.style.display='none';}
function toggleClientMode(){const g=document.querySelector('input[name="clientType"][value="guest"]').checked;document.getElementById('client-registered-group').style.display=g?'none':'block';document.getElementById('client-guest-group').style.display=g?'block':'none';updateAddressVisibility();}
function resetCalendarSelection(){if(selectedTime==="00:00"){selectedDateObj=null;selectedTime=null;if(document.getElementById('selectedDateDisplay'))document.getElementById('selectedDateDisplay').innerText="Selecciona fecha";if(document.getElementById('selectedTimeDisplay'))document.getElementById('selectedTimeDisplay').innerText="--:--";const cal=document.getElementById('calendar');if(cal)cal.querySelectorAll('.selected').forEach(e=>e.classList.remove('selected'));}}
function initiateProcess(){const m=document.querySelector('input[name="deliveryMode"]:checked').value;if(!validarFormularioBasico(m))return;if(m==='reservation')enviarDatosAlServlet(null);else if(m==='delivery')enviarDatosAlServlet('Contraentrega');else abrirModalPago();}
function validarFormularioBasico(m){if(document.getElementById('serviceType').value==="")return showNotification('⚠️ Selecciona servicio','error'),!1;if(m!=='store'&&(!selectedDateObj||!selectedTime||selectedTime==="00:00"))return showNotification('⚠️ Selecciona fecha','error'),!1;const g=document.querySelector('input[name="clientType"][value="guest"]').checked;if(m==='delivery'&&g&&document.getElementById('pickupAddress').value.trim()==="")return showNotification('⚠️ Ingresa dirección','error'),!1;if(g&&(!document.getElementById('guestName').value||!document.getElementById('guestPhone').value))return showNotification('⚠️ Datos incompletos','error'),!1;if(!g&&!document.getElementById('registeredClientId').value)return showNotification('⚠️ Selecciona cliente','error'),!1;return!0;}
function enviarDatosAlServlet(mp){const m=document.querySelector('input[name="deliveryMode"]:checked').value;const g=document.querySelector('input[name="clientType"][value="guest"]').checked;const fd=new URLSearchParams();fd.append('clientType',g?'guest':'registered');if(g){fd.append('guestName',document.getElementById('guestName').value);fd.append('guestPhone',document.getElementById('guestPhone').value);}else{fd.append('registeredClientId',document.getElementById('registeredClientId').value);}const s=document.getElementById('serviceType');let sid=1;if(s.value==='2')sid=2;if(s.value==='3')sid=3;fd.append('serviceType',sid);const q=document.getElementById('quantity').value;const p=parseFloat(s.options[s.selectedIndex].getAttribute('data-price'));fd.append('quantity',q);fd.append('total',(p*q).toFixed(2));fd.append('deliveryMode',m);fd.append('pickupAddress',document.getElementById('pickupAddress').value||"En Tienda");const y=selectedDateObj.getFullYear();const mo=String(selectedDateObj.getMonth()+1).padStart(2,'0');const da=String(selectedDateObj.getDate()).padStart(2,'0');let dt="";if(m!=='store'){let t=selectedTime.split(' ');let hm=t[0].split(':');let h=parseInt(hm[0]);if(t[1]==='PM'&&h<12)h+=12;if(t[1]==='AM'&&h===12)h=0;dt=`${y}-${mo}-${da} ${String(h).padStart(2,'0')}:${hm[1]}:00`;}else{const n=new Date();dt=`${y}-${mo}-${da} ${n.getHours()}:${n.getMinutes()}:00`;}fd.append('datetime',dt);if(mp)fd.append('paymentMethod',mp);fetch('AgendarServlet',{method:'POST',body:fd}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('✅ Operación Exitosa','success');setTimeout(()=>{window.location.href="admin.jsp?view=appointment";},1500);}else showNotification('Error: '+d,'error');});}
function abrirModalPago(){const t=document.getElementById('totalDisplay').innerText;document.getElementById('montoCobrarModal').innerText=t;document.getElementById('montoBtnTarjeta').innerText=t;cancelarTarjeta();cancelarEfectivo();document.getElementById('modalPago').style.display='flex';}
function cerrarModalPago(){document.getElementById('modalPago').style.display='none';}
function mostrarConfirmacionEfectivo(){document.getElementById('opcionEfectivo').style.display='none';document.getElementById('opcionTarjeta').style.display='none';document.getElementById('confirmEfectivo').style.display='block';}
function cancelarEfectivo(){document.getElementById('confirmEfectivo').style.display='none';document.getElementById('opcionEfectivo').style.display='block';document.getElementById('opcionTarjeta').style.display='block';}
function mostrarFormularioTarjeta(){document.getElementById('opcionEfectivo').style.display='none';document.getElementById('opcionTarjeta').style.display='none';document.getElementById('formTarjeta').style.display='block';}
function cancelarTarjeta(){document.getElementById('formTarjeta').style.display='none';document.getElementById('opcionEfectivo').style.display='block';document.getElementById('opcionTarjeta').style.display='block';}
function confirmarPago(m){enviarDatosAlServlet(m);cerrarModalPago();}
function calculateCost(){const s=document.getElementById('serviceType');const q=document.getElementById('quantity');const t=document.getElementById('totalDisplay');if(s&&s.selectedIndex>0){const p=parseFloat(s.options[s.selectedIndex].getAttribute('data-price'))||0;const v=parseInt(q.value)||1;if(t)t.innerText="S/ "+(p*v).toFixed(2);}else if(t)t.innerText="S/ 0.00";}
function showNotification(m,t){const n=document.getElementById('notification');const x=document.getElementById('notificationMessage');if(n&&x){x.innerText=m;n.style.borderLeftColor=t==='error'?'#dc3545':'#40E0D0';n.classList.add('show');setTimeout(()=>n.classList.remove('show'),3000);}}

// --- CALENDARIO ---
function renderCalendar(){const c=document.getElementById('calendar');const l=document.getElementById('currentMonthYear');if(!c)return;c.innerHTML='';const y=currentCalendarDate.getFullYear();const m=currentCalendarDate.getMonth();l.innerText=`${["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"][m]} ${y}`;['D','L','M','M','J','V','S'].forEach(d=>{const e=document.createElement('div');e.className='calendar-header-day';e.innerText=d;c.appendChild(e);});const f=new Date(y,m,1).getDay();const t=new Date(y,m+1,0).getDate();for(let i=0;i<f;i++)c.appendChild(document.createElement('div'));for(let i=1;i<=t;i++){const b=document.createElement('div');b.className='calendar-day';b.innerText=i;if(selectedDateObj&&selectedDateObj.getDate()===i&&selectedDateObj.getMonth()===m)b.classList.add('selected');b.onclick=function(){c.querySelectorAll('.calendar-day').forEach(x=>x.classList.remove('selected'));this.classList.add('selected');selectedDateObj=new Date(y,m,i);if(document.getElementById('selectedDateDisplay'))document.getElementById('selectedDateDisplay').innerText=selectedDateObj.toLocaleDateString();};c.appendChild(b);}}
function prevMonth(){currentCalendarDate.setMonth(currentCalendarDate.getMonth()-1);renderCalendar();}
function nextMonth(){currentCalendarDate.setMonth(currentCalendarDate.getMonth()+1);renderCalendar();}
function renderTimeSlots(){const c=document.getElementById('timeSlots');if(!c||c.innerHTML.trim()!=="")return;['09:00 AM','11:00 AM','01:00 PM','03:00 PM','05:00 PM'].forEach(t=>{const b=document.createElement('button');b.className='btn btn-secondary';b.innerText=t;b.type='button';b.style.fontSize='12px';b.onclick=function(){document.querySelectorAll('#timeSlots .btn').forEach(x=>{x.classList.remove('btn-primary');x.classList.add('btn-secondary');});this.classList.remove('btn-secondary');this.classList.add('btn-primary');selectedTime=t;if(document.getElementById('selectedTimeDisplay'))document.getElementById('selectedTimeDisplay').innerText=t;};c.appendChild(b);});}