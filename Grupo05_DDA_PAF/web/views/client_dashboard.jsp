<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entidades.Clientes" %>
<%
    Clientes cliDash = (Clientes) request.getSession().getAttribute("cliente");
    if (cliDash == null) return;
%>

<section id="dashboard" class="section active">
    <div class="container">
        <div class="page-header">
            <div>
                <h1>Hola, <%= cliDash.getNombreCompleto() %></h1>
                <p>Resumen de tu actividad reciente.</p>
            </div>
            <div style="display: flex; align-items: center; gap: 10px;">
                <span id="dashLastUpdate" style="font-size: 11px; color: var(--gray-500); display: flex; align-items: center; gap: 5px;">
                    <span class="ws-dot connected" style="width: 5px; height: 5px;"></span>
                    Sincronizado
                </span>
            </div>
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <div>
                    <div class="metric-value" id="dashActivos">0</div>
                    <div class="metric-label">En Proceso</div>
                </div>
                <div class="metric-icon"><i class="fas fa-clock"></i></div>
            </div>
            <div class="metric-card">
                <div>
                    <div class="metric-value" id="dashCompletados">0</div>
                    <div class="metric-label">Completados</div>
                </div>
                <div class="metric-icon"><i class="fas fa-check-circle"></i></div>
            </div>
            <div class="metric-card">
                <div>
                    <div class="metric-value" id="dashGastado">S/ 0.00</div>
                    <div class="metric-label">Total Invertido</div>
                </div>
                <div class="metric-icon"><i class="fas fa-wallet"></i></div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h4 style="margin: 0;">&Uacute;ltimos Movimientos</h4>
                <a href="#" onclick="showView('orders')" style="font-size: 13px; color: var(--aqua-dark); font-weight: 600; text-decoration: none;">Ver todo <i class="fas fa-arrow-right" style="font-size: 11px;"></i></a>
            </div>
            <div style="overflow-x: auto;">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Pedido</th>
                            <th>Servicio / Producto</th>
                            <th>Fecha</th>
                            <th>Total</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody id="dashRecientesBody">
                        <tr><td colspan="5" style="text-align: center; color: var(--gray-500); padding: 40px;">Cargando movimientos...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<script>
    function loadDashboardData() {
        fetch('DashboardClienteServlet')
            .then(response => response.json())
            .then(data => {
                if (data.error) { console.error("Error:", data.error); return; }
                
                document.getElementById('dashActivos').innerText = data.activos;
                document.getElementById('dashCompletados').innerText = data.completados;
                document.getElementById('dashGastado').innerText = 'S/ ' + data.gastado.toFixed(2);
                
                const tbody = document.getElementById('dashRecientesBody');
                tbody.innerHTML = '';
                
                if (data.recientes.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: var(--gray-500); padding: 40px;">No hay movimientos recientes.</td></tr>';
                    return;
                }
                
                data.recientes.forEach(p => {
                    let badgeClass = 'badge-dark';
                    const st = p.estado;
                    if(st === "En Lavado" || st === "En Camino") badgeClass = 'badge-warning';
                    if(st === "Terminado" || st === "Listo para Recoger") badgeClass = 'badge-info';
                    if(st === "Entregado") badgeClass = 'badge-success';
                    if(st === "Cancelado") badgeClass = 'badge-danger';
                    if(st === "Cita Programada" || st === "Pendiente de Recojo") badgeClass = 'badge-purple';
                    
                    const row = `<tr>
                        <td><strong>#\${p.id}</strong></td>
                        <td>\${p.item}</td>
                        <td style="color: var(--gray-600);">\${p.fecha}</td>
                        <td><strong>S/ \${p.total.toFixed(2)}</strong></td>
                        <td><span class="badge \${badgeClass}">\${st}</span></td>
                    </tr>`;
                    tbody.insertAdjacentHTML('beforeend', row);
                });

                const lastUpdate = document.getElementById('dashLastUpdate');
                if (lastUpdate) {
                    const now = new Date();
                    const time = now.getHours().toString().padStart(2,'0') + ':' + now.getMinutes().toString().padStart(2,'0') + ':' + now.getSeconds().toString().padStart(2,'0');
                    lastUpdate.innerHTML = '<span class="ws-dot connected" style="width: 5px; height: 5px;"></span> Actualizado ' + time;
                }
            })
            .catch(error => console.error("Error:", error));
    }
    
    document.addEventListener("DOMContentLoaded", function() { loadDashboardData(); });
</script>