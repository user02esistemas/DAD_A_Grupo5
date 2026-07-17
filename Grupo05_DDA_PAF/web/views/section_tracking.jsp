<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionPedidosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Pedidos, entidades.DetallePedido" %>
<%@ page import="java.util.List, java.util.ArrayList, java.text.SimpleDateFormat" %>

<%
    List<Pedidos> listaServicios = new ArrayList<>();
    List<Pedidos> listaDelivery = new ArrayList<>();
    List<Pedidos> listaRecojo = new ArrayList<>();
    
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
        listaServicios = pedidoRMI.listarPedidosPorTrackingTab("servicios");
        listaDelivery = pedidoRMI.listarPedidosPorTrackingTab("delivery");
        listaRecojo = pedidoRMI.listarPedidosPorTrackingTab("recojo");
    } catch(Exception e) { 
        System.out.println("Error en tracking: " + e.getMessage());
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM HH:mm");
%>

<section id="tracking" class="section">
    <div class="container">
        <div class="page-header">
            <div>
                <h1>Seguimiento de Pedidos</h1>
                <p>Gestiona la log&iacute;stica de servicios y ventas.</p>
            </div>
        </div>

        <div style="display: flex; gap: 8px; margin-bottom: 24px;">
            <button class="btn btn-primary" id="tabBtnServ" onclick="switchTrackingTab('servicios')">
                <i class="fas fa-shirt"></i> Servicios (<%= listaServicios.size() %>)
            </button>
            <button class="btn btn-outline" id="tabBtnDel" onclick="switchTrackingTab('delivery')">
                <i class="fas fa-motorcycle"></i> Delivery (<%= listaDelivery.size() %>)
            </button>
            <button class="btn btn-outline" id="tabBtnRec" onclick="switchTrackingTab('recojo')">
                <i class="fas fa-store"></i> Recojo (<%= listaRecojo.size() %>)
            </button>
        </div>

        <div class="card">
            <div class="card-header">
                <h3 id="trackingTitle">Cola de Servicios</h3>
                <input type="text" id="searchInput" class="form-input" onkeyup="filtrarPedidos()" placeholder="Buscar pedido..." style="width: 260px;">
            </div>
            
            <div style="overflow-x: auto;">
                <table class="table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Cliente / Detalle</th>
                            <th>Estado</th>
                            <th>Fecha</th>
                            <th>Acci&oacute;n</th>
                        </tr>
                    </thead>
                    
                    <tbody id="tablaServiciosBody">
                        <% for (Pedidos p : listaServicios) { 
                             String st = p.getEstado();
                             String badgeClass = "badge-dark";
                             if("En Lavado".equals(st)) badgeClass = "badge-warning";
                             if("Terminado".equals(st)) badgeClass = "badge-success";
                             if("Cita Programada".equals(st)) badgeClass = "badge-purple";
                             
                             String item = "Servicio";
                             if(!p.getDetallePedidoList().isEmpty() && p.getDetallePedidoList().get(0).getIdServicio() != null)
                                 item = p.getDetallePedidoList().get(0).getIdServicio().getNombre();
                        %>
                        <tr>
                            <td><strong>#<%= p.getIdPedido() %></strong></td>
                            <td>
                                <div style="font-weight: 600;"><%= p.getIdCliente().getNombreCompleto() %></div>
                                <small class="text-aqua"><i class="fas fa-shirt"></i> <%= item %></small>
                            </td>
                            <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                            <td style="color: var(--gray-600);"><%= sdf.format(p.getFechaRecepcion()) %></td>
                            <td><button class="btn btn-primary btn-sm" onclick="abrirModalSeguimiento(<%= p.getIdPedido() %>, 'servicio')">Gestionar</button></td>
                        </tr>
                        <% } %>
                    </tbody>

                    <tbody id="tablaDeliveryBody" style="display: none;">
                        <% for (Pedidos p : listaDelivery) { 
                             String st = p.getEstado();
                             String badgeClass = "badge-info";
                             if("En Camino".equals(st)) badgeClass = "badge-warning";
                             if("Entregado".equals(st)) badgeClass = "badge-dark";
                             
                             String item = "Producto";
                             if(!p.getDetallePedidoList().isEmpty() && p.getDetallePedidoList().get(0).getIdProducto() != null)
                                 item = p.getDetallePedidoList().get(0).getIdProducto().getNombre();
                        %>
                        <tr>
                            <td><strong>#<%= p.getIdPedido() %></strong></td>
                            <td>
                                <div style="font-weight: 600;"><%= p.getIdCliente().getNombreCompleto() %></div>
                                <small style="color: var(--purple);"><i class="fas fa-motorcycle"></i> <%= item %></small>
                            </td>
                            <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                            <td style="color: var(--gray-600);"><%= sdf.format(p.getFechaRecepcion()) %></td>
                            <td><button class="btn btn-primary btn-sm" onclick="abrirModalSeguimiento(<%= p.getIdPedido() %>, 'delivery')">Gestionar</button></td>
                        </tr>
                        <% } %>
                    </tbody>

                    <tbody id="tablaRecojoBody" style="display: none;">
                        <% for (Pedidos p : listaRecojo) { 
                             String st = p.getEstado();
                             String badgeClass = "badge-purple";
                             if("Listo para Recoger".equals(st)) badgeClass = "badge-success";
                             if("Entregado".equals(st)) badgeClass = "badge-dark";
                             
                             String item = "Producto";
                             if(!p.getDetallePedidoList().isEmpty() && p.getDetallePedidoList().get(0).getIdProducto() != null)
                                 item = p.getDetallePedidoList().get(0).getIdProducto().getNombre();
                        %>
                        <tr>
                            <td><strong>#<%= p.getIdPedido() %></strong></td>
                            <td>
                                <div style="font-weight: 600;"><%= p.getIdCliente().getNombreCompleto() %></div>
                                <small style="color: var(--warning);"><i class="fas fa-store"></i> <%= item %></small>
                            </td>
                            <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                            <td style="color: var(--gray-600);"><%= sdf.format(p.getFechaRecepcion()) %></td>
                            <td><button class="btn btn-primary btn-sm" onclick="abrirModalSeguimiento(<%= p.getIdPedido() %>, 'recojo')">Gestionar</button></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <div id="trackingModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); backdrop-filter:blur(4px); z-index:2000; justify-content:center; align-items:center;">
        <div class="card" style="width: 520px; max-width: 92%; max-height: 90vh; overflow-y: auto;">
            <div class="card-header">
                <h3>Pedido #<span id="modalId"></span></h3>
                <button class="modal-close" onclick="cerrarModalSeguimiento()">&times;</button>
            </div>
            <form onsubmit="return false;">
                <input type="hidden" id="modalIdHidden">
                <input type="hidden" id="modalMonto">
                <input type="hidden" id="modalEstadoOriginal">
                <input type="hidden" id="modalNotasAnt">
                
                <div class="form-group">
                    <label class="form-label">Cliente</label>
                    <input type="text" id="modalCliente" class="form-input" readonly style="background: var(--gray-50);">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Nuevo Estado</label>
                    <select id="modalEstado" class="form-input" style="font-weight: 600;"></select>
                </div>
                
                <div class="form-group">
                    <label class="form-label" style="color: var(--aqua-dark);"><i class="fas fa-comment-dots"></i> Enviar Mensaje</label>
                    <textarea id="modalNotaNueva" class="form-input" rows="2" placeholder="Escribe aqu&iacute;..."></textarea>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Historial</label>
                    <textarea id="modalHistorial" class="form-input" rows="3" readonly style="background: var(--gray-50); font-size: 12px;"></textarea>
                </div>
                
                <button class="btn btn-primary btn-block" onclick="procesarSeguimiento()" style="margin-top: 8px;">
                    <i class="fas fa-check"></i> Guardar
                </button>
            </form>
        </div>
    </div>
    
    <div id="modalPagoTracking" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); backdrop-filter:blur(4px); z-index:2100; justify-content:center; align-items:center;">
        <div class="card" style="width: 420px;">
            <div class="card-header">
                <h3>Cobrar</h3>
                <button class="modal-close" onclick="cerrarModalPagoTracking()">&times;</button>
            </div>
            <div style="text-align: center; margin: 20px 0;">
                <p style="color: var(--gray-600); font-size: 14px;">Monto a cobrar:</p>
                <h2 style="color: var(--aqua-dark); font-size: 32px; margin: 8px 0;" id="trackMontoDisplay"></h2>
            </div>
            <div id="trackOpcionesPago">
                <button class="btn btn-block" style="background: var(--success); color: white; margin-bottom: 10px;" onclick="confirmarPagoTracking('Efectivo')">
                    <i class="fas fa-money-bill-wave"></i> Efectivo
                </button>
                <button class="btn btn-primary btn-block" onclick="mostrarFormTarjetaTracking()">
                    <i class="fas fa-credit-card"></i> Tarjeta
                </button>
            </div>
            <div id="trackFormTarjeta" style="display: none;">
                <input type="text" class="form-input" placeholder="0000 0000 0000 0000" style="margin-bottom: 10px;">
                <button class="btn btn-primary btn-block" onclick="confirmarPagoTracking('Tarjeta')">
                    <i class="fas fa-lock"></i> Procesar
                </button>
            </div>
        </div>
    </div>
</section>