/* 
 * Admin Logic - New One
 * Manejo de secciones: Dashboard, Reportes, Clientes, Empleados, Productos, Chat
 */

var currentSection = 'dashboard'; 

// ==========================================
// 1. INICIALIZACIÓN Y NAVEGACIÓN
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const viewParam = urlParams.get('view');

    if(viewParam) { 
        showSection(viewParam); 
        currentSection = viewParam; 
    }
});

function showSection(sectionId) {
    currentSection = sectionId;
    
    document.querySelectorAll('.admin-section, .section').forEach(sec => sec.classList.remove('active'));
    document.querySelectorAll('.admin-nav-link').forEach(link => link.classList.remove('active'));
    
    const target = document.getElementById(sectionId);
    if (target) target.classList.add('active');
    
    const activeLink = document.querySelector(`[data-section="${sectionId}"]`);
    if (activeLink) activeLink.classList.add('active');
    
    if (sectionId === 'chat') {
        initChat();
    }
}

// ==========================================
// 2. MÓDULO: PRODUCTOS (CRUD)
// ==========================================
function previewImage(input){if(input.files&&input.files[0]){var r=new FileReader();r.onload=function(e){document.getElementById('imgPreview').src=e.target.result;};r.readAsDataURL(input.files[0]);}}
function abrirModalProducto(){document.getElementById('formProducto').reset();document.getElementById('prodAccion').value="nuevo_producto";document.getElementById('modalProducto').style.display='flex';}
function editarProducto(id){document.getElementById('modalProducto').style.display='flex';document.getElementById('modalProdTitle').innerText="Editar Producto";document.getElementById('prodAccion').value="actualizar_producto";fetch(`GestionServlet?accion=get_producto&id=${id}`).then(r=>r.json()).then(d=>{document.getElementById('prodId').value=d.id;document.getElementById('prodNombre').value=d.nombre;document.getElementById('prodDesc').value=d.desc;document.getElementById('prodPrecio').value=d.precio;document.getElementById('prodStock').value=d.stock;document.getElementById('prodImgUrl').value=d.imagen;if(d.imagen)document.getElementById('imgPreview').src=d.imagen;});}
function eliminarProducto(id){if(confirm("¿Eliminar este producto?")){fetch('GestionServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:`accion=eliminar_producto&id=${id}`}).then(()=>{window.location.href="admin.jsp?view=products";});}}

// ==========================================
// 3. MÓDULO: CLIENTES
// ==========================================
function filtrarClientes(){const i=document.getElementById("searchClient");const f=i.value.toUpperCase();const tr=document.getElementById("tablaClientesBody").getElementsByTagName("tr");for(let j=0;j<tr.length;j++){const td=tr[j].getElementsByTagName("td")[0];if(td){if(td.innerText.toUpperCase().indexOf(f)>-1)tr[j].style.display="";else tr[j].style.display="none";}}}
function abrirModalNuevoCliente(){document.getElementById('formNuevoCliente').reset();document.getElementById('modalNuevoCliente').style.display='flex';}
function guardarNuevoCliente(){const fd=new URLSearchParams(new FormData(document.getElementById('formNuevoCliente')));fetch('GestionServlet',{method:'POST',body:fd}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('Cliente creado','success');document.getElementById('modalNuevoCliente').style.display='none';setTimeout(()=>{window.location.href="admin.jsp?view=clients";},1000);}else showNotification('Error','error');});}
function editarCliente(id){document.getElementById('modalEditarCliente').style.display='flex';fetch(`GestionServlet?accion=get_cliente&id=${id}`).then(r=>r.json()).then(d=>{if(d.id){document.getElementById('editId').value=d.id;document.getElementById('editNombre').value=d.nombre;document.getElementById('editEmail').value=d.email;document.getElementById('editPass').value=d.pass;document.getElementById('editTel').value=d.tel;document.getElementById('editDir').value=d.dir;document.getElementById('editNac').value=d.nac;document.getElementById('editRef').value=d.ref;document.getElementById('editPromo').checked=d.promo;}});}
function guardarEdicionCliente(){const fd=new URLSearchParams(new FormData(document.getElementById('formEditarCliente')));fetch('GestionServlet',{method:'POST',body:fd}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('Actualizado','success');setTimeout(()=>{window.location.href="admin.jsp?view=clients";},1000);}else showNotification('Error','error');});}
function eliminarCliente(id,n){if(confirm("¿Eliminar "+n+"?")){fetch('GestionServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:`accion=eliminar_cliente&id=${id}`}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('Eliminado','success');setTimeout(()=>{window.location.href="admin.jsp?view=clients";},1000);}else showNotification('Error: tiene historial','error');});}}

// ==========================================
// 4. MÓDULO: EMPLEADOS
// ==========================================
function filtrarEmpleados(){const i=document.getElementById("searchEmployee");const f=i.value.toUpperCase();const tr=document.getElementById("tablaEmpleadosBody").getElementsByTagName("tr");for(let j=0;j<tr.length;j++){const td=tr[j].getElementsByTagName("td")[1];if(td){if(td.innerText.toUpperCase().indexOf(f)>-1)tr[j].style.display="";else tr[j].style.display="none";}}}
function editarEmpleado(id){document.getElementById('modalEmpleado').style.display='flex';fetch(`GestionServlet?accion=get_empleado&id=${id}`).then(r=>r.json()).then(d=>{document.getElementById('empId').value=d.id;document.getElementById('empNombre').value=d.nombre;document.getElementById('empCodigo').value=d.codigo;document.getElementById('empPass').value=d.pass;if(d.rol){document.getElementById('empRol').value=d.rol;}});}
function guardarEdicionEmpleado(){const fd=new URLSearchParams(new FormData(document.getElementById('formEmpleado')));fetch('GestionServlet',{method:'POST',body:fd}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('Empleado actualizado','success');setTimeout(()=>{window.location.href="admin.jsp?view=employees";},1000);}else{showNotification('Error al actualizar','error');}}).catch(()=>{showNotification('Error de conexion','error');});}
function abrirModalNuevoEmpleado(){document.getElementById('formNuevoEmpleado').reset();document.getElementById('modalNuevoEmpleado').style.display='flex';}
function guardarNuevoEmpleado(){const fd=new URLSearchParams(new FormData(document.getElementById('formNuevoEmpleado')));fetch('GestionServlet',{method:'POST',body:fd}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('Personal registrado','success');setTimeout(()=>{window.location.href="admin.jsp?view=employees";},1000);}else{showNotification('Error al registrar','error');}}).catch(()=>{showNotification('Error de conexion','error');});}
function eliminarEmpleado(id,n){if(confirm("Borrar a "+n+"?")){fetch('GestionServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:`accion=eliminar_empleado&id=${id}`}).then(r=>r.text()).then(d=>{if(d.trim()==='success'){showNotification('Eliminado','success');setTimeout(()=>{window.location.href="admin.jsp?view=employees";},1000);}else{showNotification('Error al eliminar','error');}}).catch(()=>{showNotification('Error de conexion','error');});}}

// ==========================================
// 5. UTILIDADES
// ==========================================
function showNotification(m,t){const n=document.getElementById('adminNotification');const x=document.getElementById('adminNotificationMsg');if(n&&x){x.innerText=m;n.style.borderLeftColor=t==='error'?'#dc3545':'#40E0D0';n.classList.add('show');setTimeout(()=>n.classList.remove('show'),3000);}}
function togglePassVis(id,btn){var inp=document.getElementById(id);if(inp.type==='password'){inp.type='text';btn.innerHTML='<i class="fas fa-eye-slash"></i>';}else{inp.type='password';btn.innerHTML='<i class="fas fa-eye"></i>';}}
