<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section id="orders" class="section">
    <div class="container">
        <div class="page-header">
            <div>
                <h1>Mis Pedidos</h1>
                <p>Historial de actividad y seguimiento en tiempo real.</p>
            </div>
            <div style="display: flex; align-items: center; gap: 10px;">
                <span id="ordersLastUpdate" style="font-size: 11px; color: var(--gray-500); display: flex; align-items: center; gap: 5px;">
                    <span class="ws-dot connected" style="width: 5px; height: 5px;"></span>
                    Actualizando en vivo
                </span>
                <button class="btn btn-outline btn-sm" onclick="loadOrdersData()" title="Actualizar ahora">
                    <i class="fas fa-sync-alt"></i>
                </button>
            </div>
        </div>

        <div id="ordersContainer">
            <div class="card" style="text-align: center; padding: 60px;">
                <h3 style="color: var(--gray-600);">Cargando tus pedidos...</h3>
            </div>
        </div>
    </div>
</section>

<style>
    .pedido-actualizado {
        animation: pedidoPulse 3s ease-out;
        border-color: var(--aqua) !important;
        box-shadow: 0 0 0 3px var(--aqua-glow), var(--shadow-md) !important;
    }
    @keyframes pedidoPulse {
        0% { box-shadow: 0 0 0 0 rgba(64, 224, 208, 0.5); }
        30% { box-shadow: 0 0 0 8px rgba(64, 224, 208, 0.2); }
        100% { box-shadow: var(--shadow-sm); }
    }
    .order-updating {
        position: relative;
        overflow: hidden;
    }
    .order-updating::after {
        content: '';
        position: absolute;
        top: 0; left: -100%;
        width: 100%; height: 100%;
        background: linear-gradient(90deg, transparent, rgba(64,224,208,0.08), transparent);
        animation: shimmerSlide 1.5s ease-out;
    }
    @keyframes shimmerSlide {
        0% { left: -100%; }
        100% { left: 100%; }
    }
</style>

<script>
    function loadOrdersData() {
        fetch('PedidosClienteServlet')
            .then(response => response.json())
            .then(data => {
                const container = document.getElementById('ordersContainer');
                container.innerHTML = '';
                
                if (data.error) {
                    container.innerHTML = '<div class="card" style="text-align: center; padding: 60px;"><h3 style="color: var(--danger);">Error: ' + data.error + '</h3></div>';
                    return;
                }
                
                if (data.length === 0) {
                    container.innerHTML = `
                        <div class="card" style="text-align: center; padding: 60px;">
                            <i class="fas fa-receipt" style="font-size: 48px; color: var(--gray-300); margin-bottom: 16px;"></i>
                            <h3 style="color: var(--gray-600);">No hay pedidos recientes</h3>
                            <button class="btn btn-primary" onclick="showView('store')" style="margin-top: 16px;">
                                <i class="fas fa-shopping-bag"></i> Ir a la Tienda
                            </button>
                        </div>
                    `;
                    return;
                }
                
                data.forEach(p => {
                    let badgeClass = p.isCancel ? 'badge-danger' : 'badge-aqua';
                    const iconType = p.isService ? "fa-shirt" : "fa-shopping-bag";
                    const logType = p.isDelivery ? "Log&iacute;stica: Delivery" : "Log&iacute;stica: En Tienda";
                    
                    let bodyHtml = '';
                    
                    if (p.isCita) {
                        bodyHtml = `
                            <div style="background: var(--purple-bg); color: #7c3aed; padding: 18px; border-radius: var(--radius-md); text-align: center;">
                                <i class="fas fa-calendar-check" style="font-size: 20px;"></i> <strong>Cita Reservada</strong><br>
                                <span style="font-size: 13px; opacity: 0.8;">Te esperamos en el local a la hora programada.</span>
                            </div>
                        `;
                    } else if (p.isCancel) {
                        bodyHtml = `
                            <div style="background: var(--danger-bg); color: var(--danger); padding: 18px; border-radius: var(--radius-md); text-align: center;">
                                <i class="fas fa-ban" style="font-size: 20px;"></i> Pedido Cancelado.
                            </div>
                        `;
                    } else {
                        let timelineHtml = '<div class="timeline">';
                        for(let i=0; i<p.labels.length; i++) {
                            let stepClass = "";
                            let iconClass = "fas " + p.icons[i];
                            
                            if (i < p.currentStep) { stepClass = "completed"; iconClass = "fas fa-check"; }
                            else if (i === p.currentStep) { stepClass = "active"; }
                            
                            timelineHtml += `
                                <div class="tl-step \${stepClass}">
                                    <div class="tl-dot"><i class="\${iconClass}"></i></div>
                                    <div class="tl-text">\${p.labels[i]}</div>
                                </div>
                            `;
                        }
                        timelineHtml += '</div>';
                        bodyHtml = timelineHtml;
                    }
                    
                    let notasHtml = '';
                    if (p.notas && p.notas.trim() !== '') {
                        notasHtml = '<div style="margin-top: 20px; font-size: 13px; background: var(--warning-bg); color: #b87a00; padding: 12px; border-radius: var(--radius-sm);"><i class="fas fa-comment-dots"></i> ' + p.notas.split("\\n")[0] + '...</div>';
                    }
                    
                    let cancelBtn = p.isCita ? '<button class="btn btn-outline btn-sm" onclick="cancelarPedido(' + p.id + ')" style="color: var(--danger); border-color: var(--danger);">Cancelar Cita</button>' : '';
                    
                    const totalLabel = p.isCita ? "Total a Pagar (En Local)" : "Total Pagado";
                    
                    const cardHtml = `
                        <div class="order-card" id="pedido-\${p.id}">
                            <div class="order-header">
                                <div>
                                    <div style="font-weight: 700; color: var(--dark);">Pedido #\${p.id}</div>
                                    <div style="color: var(--gray-600); font-size: 13px;">\${p.fecha}</div>
                                </div>
                                <span class="badge \${badgeClass}">\${p.estado}</span>
                            </div>
                            
                            <div class="order-body">
                                <div style="display: flex; align-items: center; gap: 14px; margin-bottom: 20px;">
                                    <div style="width: 42px; height: 42px; background: var(--gray-50); border-radius: var(--radius-sm); display: flex; align-items: center; justify-content: center; color: var(--gray-600);">
                                        <i class="fas \${iconType}"></i>
                                    </div>
                                    <div>
                                        <h4 style="margin: 0; font-size: 16px; color: var(--dark);">\${p.itemName}</h4>
                                        <div style="font-size: 13px; color: var(--gray-600);">\${p.itemType} &bull; \${logType}</div>
                                    </div>
                                </div>
                                
                                \${bodyHtml}
                                \${notasHtml}
                            </div>
                            
                            <div class="order-footer">
                                <div>
                                    <div style="font-size: 12px; color: var(--gray-600);">\${totalLabel}</div>
                                    <div style="font-size: 20px; font-weight: 800; color: var(--aqua-dark);">S/ \${p.total.toFixed(2)}</div>
                                </div>
                                \${cancelBtn}
                            </div>
                        </div>
                    `;
                    
                    container.insertAdjacentHTML('beforeend', cardHtml);
                });

                const lastUpdate = document.getElementById('ordersLastUpdate');
                if (lastUpdate) {
                    const now = new Date();
                    const time = now.getHours().toString().padStart(2,'0') + ':' + now.getMinutes().toString().padStart(2,'0') + ':' + now.getSeconds().toString().padStart(2,'0');
                    lastUpdate.innerHTML = '<span class="ws-dot connected" style="width: 5px; height: 5px;"></span> Actualizado ' + time;
                }
            })
            .catch(error => console.error("Error:", error));
    }
    
    document.addEventListener("DOMContentLoaded", function() { loadOrdersData(); });
</script>