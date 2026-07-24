<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entidades.Clientes" %>
<%
    Clientes cliSched = (Clientes) session.getAttribute("cliente");
    String dirDefault = (cliSched!=null && cliSched.getDireccion()!=null) ? cliSched.getDireccion() : "";
%>

<section id="schedule" class="section">
    <div class="container">
        <div class="page-header">
            <div>
                <h1>Agendar Servicio</h1>
                <p>Programa un lavado o restauraci&oacute;n para tus zapatillas.</p>
            </div>
        </div>

        <div style="display: flex; flex-wrap: wrap; gap: 24px;">
            <div style="flex: 2; min-width: 300px;">
                <div class="card">
                    <form id="serviceForm" onsubmit="return false;">
                        <div class="form-group">
                            <label class="form-label">Elige el Servicio</label>
                            <div id="servicesContainer" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px;">
                                <div style="color: var(--gray-500); padding: 20px; text-align: center;">Cargando servicios...</div>
                            </div>
                            <input type="hidden" id="selectedServiceId">
                            <input type="hidden" id="selectedServicePrice">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Modalidad de Entrega</label>
                            <div style="display: flex; gap: 12px;">
                                <label class="radio-card">
                                    <input type="radio" name="modalidadServ" value="En Local" checked onchange="toggleServiceAddress(false)">
                                    <span><i class="fas fa-store"></i> Ir&eacute; al Local</span>
                                </label>
                                <label class="radio-card">
                                    <input type="radio" name="modalidadServ" value="Delivery Recojo" onchange="toggleServiceAddress(true)">
                                    <span><i class="fas fa-motorcycle"></i> Recojo a Domicilio</span>
                                </label>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Fecha y Hora Preferida</label>
                            <input type="date" id="serviceDate" class="form-input" style="margin-bottom: 12px;">
                            <div class="time-grid" id="timeSlotsContainer">
                                <button type="button" class="time-btn" onclick="selectTime(this, '09:00')">09:00 AM</button>
                                <button type="button" class="time-btn" onclick="selectTime(this, '11:00')">11:00 AM</button>
                                <button type="button" class="time-btn" onclick="selectTime(this, '14:00')">02:00 PM</button>
                                <button type="button" class="time-btn" onclick="selectTime(this, '16:00')">04:00 PM</button>
                                <button type="button" class="time-btn" onclick="selectTime(this, '18:00')">06:00 PM</button>
                            </div>
                            <input type="hidden" id="selectedTime">
                        </div>

                        <div class="form-group" id="serviceAddressGroup" style="display: none;">
                            <label class="form-label">Direcci&oacute;n de Recojo</label>
                            <textarea id="serviceAddress" class="form-input" rows="2"><%= dirDefault %></textarea>
                        </div>
                    </form>
                </div>
            </div>

            <div style="flex: 1; min-width: 260px;">
                <div class="card card-elevated" style="position: sticky; top: 24px;">
                    <h3 style="margin-top: 0; font-size: 18px;">Resumen</h3>
                    <hr style="border: 0; border-top: 1px solid var(--gray-200); margin: 14px 0;">
                    
                    <div style="display: flex; justify-content: space-between; margin-bottom: 12px;">
                        <span style="color: var(--gray-600);">Servicio:</span>
                        <span id="summaryName" style="font-weight: 600;">--</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; margin-bottom: 12px;">
                        <span style="color: var(--gray-600);">Modalidad:</span>
                        <span id="summaryMode">En Local</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; margin-bottom: 20px;">
                        <span style="color: var(--gray-600);">Fecha:</span>
                        <span id="summaryDate">--</span>
                    </div>
                    
                    <div style="background: var(--aqua-glow); padding: 18px; border-radius: var(--radius-md); text-align: center; margin-bottom: 20px; border: 1.5px solid var(--aqua);">
                        <div style="font-size: 13px; color: var(--gray-600); margin-bottom: 4px;">Total a Pagar</div>
                        <div style="font-size: 30px; font-weight: 800; color: var(--dark);" id="summaryTotal">S/ 0.00</div>
                    </div>
                    
                    <button class="btn btn-primary btn-block btn-lg" id="btnSubmitService" onclick="openServicePayment()">
                        <i class="fas fa-calendar-check"></i> Agendar Reserva
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div id="modalServicePayment" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Pago de Servicio</h3>
                <button class="modal-close" onclick="document.getElementById('modalServicePayment').style.display='none'">&times;</button>
            </div>
            <div class="modal-body">
                <div style="text-align: center; margin-bottom: 20px;">
                    <p style="color: var(--gray-600);">Monto a pagar:</p>
                    <h2 style="color: var(--aqua-dark); margin: 8px 0;" id="payServiceAmount"></h2>
                </div>
                <div class="form-group">
                    <label class="form-label">N&uacute;mero de Tarjeta</label>
                    <input type="text" class="form-input" placeholder="0000 0000 0000 0000" maxlength="19">
                </div>
                <div style="display: flex; gap: 10px;">
                    <input type="text" class="form-input" placeholder="MM/YY" maxlength="5">
                    <input type="text" class="form-input" placeholder="CVC" maxlength="3">
                </div>
                <button class="btn btn-primary btn-block btn-lg" style="margin-top: 20px;" onclick="submitServiceOrder()">
                    <i class="fas fa-lock"></i> Procesar Cita
                </button>
            </div>
        </div>
    </div>
</section>

<style>
    .service-option { border: 2px solid var(--gray-200); padding: 16px; border-radius: var(--radius-md); text-align: center; cursor: pointer; transition: all var(--transition-base); background: var(--white); }
    .service-option:hover { border-color: var(--aqua); background: var(--aqua-glow); }
    .service-option.selected { border-color: var(--aqua); background: var(--aqua-glow); box-shadow: var(--shadow-aqua); }
</style>

<script>
    function loadServicesData() {
        fetch('ServiciosServlet')
            .then(response => response.json())
            .then(data => {
                const container = document.getElementById('servicesContainer');
                container.innerHTML = '';
                
                if (data.error) {
                    container.innerHTML = '<div style="color: var(--danger);">Error: ' + data.error + '</div>';
                    return;
                }
                
                data.forEach(s => {
                    const servHtml = `
                        <div class="service-option" onclick="selectServiceItem(\${s.id}, \${s.precio})" id="serv_\${s.id}">
                            <div style="font-weight: 600;">\${s.nombre}</div>
                            <div style="color: var(--aqua-dark); font-weight: 700; font-size: 18px; margin-top: 4px;">S/ \${s.precio}</div>
                        </div>
                    `;
                    container.insertAdjacentHTML('beforeend', servHtml);
                });
            })
            .catch(error => console.error("Error:", error));
    }
    
    document.addEventListener("DOMContentLoaded", function() { loadServicesData(); });
</script>