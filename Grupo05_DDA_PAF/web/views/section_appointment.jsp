<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionClientesRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Clientes" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    List<Clientes> listaClientes = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
        listaClientes = clienteRMI.listarClientes();
    } catch(Exception e) {
        e.printStackTrace();
    }
%>

<style>
    .calendar { display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px; margin-top: 10px; }
    .calendar-day { padding: 10px; text-align: center; border-radius: var(--radius-sm); cursor: pointer; background: var(--gray-50); font-size: 14px; font-weight: 500; transition: all var(--transition-fast); border: 1.5px solid transparent; }
    .calendar-day:hover { background: var(--aqua-glow); border-color: var(--aqua); }
    .calendar-day.selected { background: var(--aqua-gradient); color: var(--dark); font-weight: 700; box-shadow: var(--shadow-aqua); }
    .calendar-header-day { font-weight: 700; text-align: center; padding: 8px 0; color: var(--gray-600); font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; }
    #modalPago { z-index: 9999 !important; background: rgba(0,0,0,0.5); backdrop-filter: blur(4px); }
</style>

<section id="appointment" class="section">
    <div class="container">
        <div class="page-header">
            <div>
                <h1 id="formTitle">Registrar Nuevo Pedido</h1>
                <p>Crea un nuevo pedido para un cliente.</p>
            </div>
            <button class="btn btn-outline" onclick="showSection('dashboard')">
                <i class="fas fa-arrow-left"></i> Volver
            </button>
        </div>

        <div class="card" style="margin-bottom: 24px;">
            <label class="form-label" style="margin-bottom: 12px;">1. Modalidad de Atenci&oacute;n</label>
            <div style="display: flex; flex-wrap: wrap; gap: 12px;">
                <label class="radio-card" style="border-color: var(--aqua); background: var(--aqua-glow);">
                    <input type="radio" name="deliveryMode" value="store" checked onclick="toggleDeliveryMode()"> 
                    <span><i class="fas fa-store"></i> Atenci&oacute;n Ya</span>
                </label>
                <label class="radio-card">
                    <input type="radio" name="deliveryMode" value="reservation" onclick="toggleDeliveryMode()"> 
                    <span><i class="fas fa-calendar-check"></i> Reserva de Turno</span>
                </label>
                <label class="radio-card">
                    <input type="radio" name="deliveryMode" value="delivery" onclick="toggleDeliveryMode()"> 
                    <span><i class="fas fa-motorcycle"></i> Delivery</span>
                </label>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="card" id="calendar-card" style="display: none;">
                <div class="card-header"><h3>Fecha y Hora</h3></div>
                
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                    <button type="button" class="btn btn-outline btn-sm" onclick="prevMonth()"><i class="fas fa-chevron-left"></i></button>
                    <strong id="currentMonthYear" style="font-size: 15px;">Mes A&ntilde;o</strong>
                    <button type="button" class="btn btn-outline btn-sm" onclick="nextMonth()"><i class="fas fa-chevron-right"></i></button>
                </div>

                <div class="calendar" id="calendar"></div>
                
                <div style="margin-top: 14px; text-align: center;">
                    <span id="selectedDateDisplay" style="color: var(--aqua-dark); font-weight: 700;">Selecciona fecha</span>
                </div>
                
                <hr style="border: 0; border-top: 1px solid var(--gray-200); margin: 16px 0;">
                
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;" id="timeSlots"></div>
                <div style="margin-top: 10px; text-align: center;">
                    <span id="selectedTimeDisplay" style="color: var(--aqua-dark); font-weight: 700;">--:--</span>
                </div>
            </div>

            <div class="card" id="details-card" style="width: 100%;">
                <div class="card-header"><h3>2. Datos del Cliente y Servicio</h3></div>
                
                <form id="appointmentForm" onsubmit="return false;">
                    <div class="form-group">
                        <label class="form-label">Cliente</label>
                        <div style="display: flex; gap: 16px; margin-bottom: 12px;">
                            <label style="cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px;">
                                <input type="radio" name="clientType" value="registered" checked onclick="toggleClientMode()"> Registrado
                            </label>
                            <label style="cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px;">
                                <input type="radio" name="clientType" value="guest" onclick="toggleClientMode()"> Nuevo
                            </label>
                        </div>
                        
                        <div id="client-registered-group">
                            <select class="form-input" id="registeredClientId">
                                <option value="">-- Buscar Cliente --</option>
                                <% for (Clientes c : listaClientes) { %>
                                    <option value="<%= c.getIdCliente() %>"><%= c.getNombreCompleto() %> (<%= c.getTelefono() %>)</option>
                                <% } %>
                            </select>
                        </div>

                        <div id="client-guest-group" style="display: none;">
                            <input type="text" class="form-input" id="guestName" placeholder="Nombre Completo" style="margin-bottom: 8px;">
                            <input type="tel" class="form-input" id="guestPhone" placeholder="Tel&eacute;fono">
                        </div>
                    </div>
                    
                    <div id="address-group" style="display: none; margin-bottom: 18px; background: var(--aqua-glow); padding: 14px; border-radius: var(--radius-md); border: 1.5px dashed var(--aqua);">
                        <label class="form-label" style="color: var(--aqua-dark); font-weight: 700;">
                            <i class="fas fa-map-marker-alt"></i> Direcci&oacute;n de Recojo
                        </label>
                        <textarea class="form-input" id="pickupAddress" rows="2" placeholder="Calle, N&uacute;mero, Referencia..."></textarea>
                    </div>

                    <hr style="border: 0; border-top: 1px solid var(--gray-200); margin: 16px 0;">

                    <div class="form-group">
                        <label class="form-label">Servicio</label>
                        <div style="display: flex; gap: 10px;">
                            <select class="form-input" id="serviceType" onchange="calculateCost()" style="flex: 2;">
                                <option value="" data-price="0">Seleccionar...</option>
                                <option value="1" data-price="15">Lavado Simple (S/ 15)</option>
                                <option value="2" data-price="25">Lavado Premium (S/ 25)</option>
                                <option value="3" data-price="40">Restauraci&oacute;n (S/ 40)</option>
                            </select>
                            <input type="number" class="form-input" id="quantity" min="1" value="1" onchange="calculateCost()" style="flex: 1;">
                        </div>
                    </div>
                </form>
                
                <div style="margin-top: 24px; padding: 18px; background: var(--aqua-glow); border-radius: var(--radius-md); border: 1.5px solid var(--aqua);">
                    <div style="display: flex; justify-content: space-between; font-weight: 700; align-items: center;">
                        <span style="font-size: 15px;">Total a Pagar:</span> 
                        <span id="totalDisplay" style="font-size: 28px; color: var(--dark);">S/ 0.00</span>
                    </div>
                </div>
                
                <button id="mainActionBtn" type="button" class="btn btn-primary btn-block btn-lg" style="margin-top: 18px;" onclick="initiateProcess()">
                    <i class="fas fa-check-circle"></i> PROCESAR PEDIDO
                </button>
            </div>
        </div>
    </div>

    <div id="modalPago" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; justify-content:center; align-items:center;">
        <div class="card" style="width: 460px; max-width: 92%; box-shadow: var(--shadow-xl);">
            <div class="card-header">
                <h3>M&eacute;todo de Pago</h3>
                <button class="modal-close" onclick="cerrarModalPago()">&times;</button>
            </div>
            <div style="text-align: center; margin-bottom: 24px;">
                <p style="color: var(--gray-600); font-size: 14px;">Monto a cobrar:</p>
                <h2 style="color: var(--aqua-dark); font-size: 34px; margin: 8px 0;" id="montoCobrarModal">S/ 0.00</h2>
            </div>
            
            <div id="opcionEfectivo">
                <button class="btn btn-block" style="background: var(--success); color: white; margin-bottom: 10px; padding: 14px;" onclick="mostrarConfirmacionEfectivo()">
                    <i class="fas fa-money-bill-wave"></i> Pago en Efectivo
                </button>
            </div>
            <div id="opcionTarjeta">
                <button class="btn btn-primary btn-block" style="padding: 14px;" onclick="mostrarFormularioTarjeta()">
                    <i class="fas fa-credit-card"></i> Pago con Tarjeta
                </button>
            </div>

            <div id="formTarjeta" style="display: none; margin-top: 16px;">
                <div class="form-group">
                    <label class="form-label">N&uacute;mero de Tarjeta</label>
                    <input type="text" class="form-input" placeholder="0000 0000 0000 0000">
                </div>
                <div style="display: flex; gap: 10px;">
                    <input type="text" class="form-input" placeholder="MM/YY" style="width: 50%;">
                    <input type="text" class="form-input" placeholder="CVC" style="width: 50%;">
                </div>
                <button class="btn btn-primary btn-block" style="margin-top: 16px;" onclick="confirmarPago('Tarjeta')">
                    <i class="fas fa-lock"></i> Pagar S/ <span id="montoBtnTarjeta"></span>
                </button>
                <button class="btn btn-outline btn-block" style="margin-top: 8px;" onclick="cancelarTarjeta()">Cancelar</button>
            </div>

            <div id="confirmEfectivo" style="display: none; margin-top: 16px;">
                <p style="color: var(--success); font-weight: 600; text-align: center; margin-bottom: 12px;">
                    <i class="fas fa-check-circle"></i> &iquest;Confirmar recepci&oacute;n de efectivo?
                </p>
                <button class="btn btn-primary btn-block" onclick="confirmarPago('Efectivo')">Confirmar Pago</button>
                <button class="btn btn-outline btn-block" style="margin-top: 8px;" onclick="cancelarEfectivo()">Cancelar</button>
            </div>
        </div>
    </div>
</section>