
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionPedidosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Pedidos, entidades.DetallePedido" %>
<%@ page import="java.util.List, java.util.ArrayList, java.text.SimpleDateFormat" %>
<%@ page import="entidades.Empleados" %>

<%
    HttpSession sesion = request.getSession();
    Empleados usuario = (Empleados) sesion.getAttribute("usuario");
    
    if (usuario == null) {
        response.sendRedirect("auth.jsp");
        return;
    }

    List<Pedidos> pedidosDelivery = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
        pedidosDelivery = pedidoRMI.listarPedidosPorTrackingTab("delivery");
    } catch(Exception e) {
        System.out.println("Error repartidor: " + e.getMessage());
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM HH:mm");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Repartidor - New One</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link href="css/styles.css" rel="stylesheet">
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        body { font-family: var(--font-body); margin: 0; background: #f8fafc; display: flex; height: 100vh; overflow: hidden; }

        .rep-sidebar {
            width: 260px;
            background: linear-gradient(180deg, #0f766e 0%, #134e4a 100%);
            color: var(--white);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }
        .rep-brand { padding: 24px; border-bottom: 1px solid rgba(255,255,255,0.08); }
        .rep-brand h2 { margin: 0; font-size: 20px; font-weight: 800; }
        .rep-brand h2 span { color: #5eead4; }
        .rep-brand .rep-tag {
            display: inline-block;
            background: rgba(94,234,212,0.15);
            color: #5eead4;
            padding: 2px 10px;
            border-radius: 20px;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 6px;
        }

        .rep-nav { flex: 1; padding: 16px 12px; overflow-y: auto; }
        .rep-nav-label {
            font-size: 10px; font-weight: 700; text-transform: uppercase;
            letter-spacing: 1.5px; color: rgba(255,255,255,0.25); padding: 16px 12px 8px;
        }
        .rep-link {
            display: flex; align-items: center; padding: 11px 16px;
            color: rgba(255,255,255,0.5); text-decoration: none; transition: all 0.2s;
            cursor: pointer; border-radius: var(--radius-sm); margin-bottom: 2px;
            font-size: 14px; font-weight: 500; gap: 12px;
        }
        .rep-link:hover { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.9); }
        .rep-link.active { background: rgba(94,234,212,0.12); color: #5eead4; }
        .rep-link i { width: 20px; text-align: center; font-size: 15px; }

        .rep-footer {
            padding: 16px; border-top: 1px solid rgba(255,255,255,0.08);
            display: flex; align-items: center; gap: 12px;
        }
        .rep-avatar {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, #5eead4, #14b8a6);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-weight: 700; color: #134e4a; font-size: 14px; flex-shrink: 0;
        }
        .rep-footer-info { flex: 1; overflow: hidden; }
        .rep-footer-name { font-weight: 600; font-size: 13px; }
        .rep-footer-role { font-size: 11px; color: rgba(255,255,255,0.4); }
        .rep-logout { color: rgba(255,255,255,0.3); transition: color 0.2s; text-decoration: none; padding: 8px; }
        .rep-logout:hover { color: #f87171; }

        .rep-main { flex: 1; overflow-y: auto; padding: 32px; position: relative; }
        .rep-section { display: none; animation: fadeIn 0.3s ease-out; }
        .rep-section.active { display: block; }

        .rep-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; }
        .rep-header h1 { font-size: 24px; margin: 0; color: #134e4a; }
        .rep-header p { color: var(--gray-600); font-size: 14px; margin: 4px 0 0; }

        .rep-stat-card {
            background: var(--white); padding: 20px; border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm); text-align: center;
            border: 1px solid rgba(0,0,0,0.04); transition: all 0.2s;
        }
        .rep-stat-card:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); }
        .rep-stat-num { font-size: 32px; font-weight: 800; color: #0f766e; }
        .rep-stat-lbl { color: var(--gray-600); font-size: 13px; font-weight: 500; margin-top: 4px; }

        .delivery-card {
            background: var(--white); border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm); border: 1px solid rgba(0,0,0,0.04);
            margin-bottom: 16px; overflow: hidden; transition: all 0.2s;
        }
        .delivery-card:hover { box-shadow: var(--shadow-md); }
        .delivery-card-header {
            padding: 16px 20px; display: flex; justify-content: space-between; align-items: center;
            border-bottom: 1px solid var(--gray-100); background: #f0fdfa;
        }
        .delivery-card-body { padding: 20px; }
        .delivery-card-footer { padding: 12px 20px; border-top: 1px solid var(--gray-100); display: flex; gap: 8px; }

        .rep-status-badge {
            display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px;
            border-radius: 20px; font-size: 11px; font-weight: 700;
        }
        .rep-status-pendiente { background: #fef3c7; color: #92400e; }
        .rep-status-camino { background: #dbeafe; color: #1e40af; }
        .rep-status-entregado { background: #d1fae5; color: #065f46; }

        .rep-map-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,0.5);
            backdrop-filter: blur(4px); z-index: 3000;
            display: none; align-items: center; justify-content: center;
        }
        .rep-map-overlay.open { display: flex; }
        .rep-map-modal {
            background: var(--white); border-radius: var(--radius-xl);
            box-shadow: 0 16px 48px rgba(0,0,0,0.2);
            width: 550px; max-width: 92%; overflow: hidden;
            animation: scaleIn 0.3s ease;
        }
        .rep-map-modal-header {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px 20px; border-bottom: 1px solid var(--gray-200);
        }
        .rep-map-modal-header h4 { margin: 0; font-size: 15px; color: var(--dark); }
        .rep-map-modal-close {
            background: var(--gray-100); border: none; color: var(--gray-600);
            width: 30px; height: 30px; border-radius: var(--radius-sm);
            cursor: pointer; display: flex; align-items: center; justify-content: center;
        }
        .rep-map-modal-body { padding: 0; }
        .rep-map-address {
            padding: 12px 20px; background: var(--gray-50);
            font-size: 13px; color: var(--gray-700);
            display: flex; align-items: center; gap: 8px;
            border-top: 1px solid var(--gray-200);
        }
        .rep-no-location {
            padding: 30px; text-align: center; color: var(--gray-500);
            font-size: 13px;
        }
        
        .rep-mobile-logout { display: none; }

        /* RESPONSIVE DESIGN PARA CELULARES */
        @media (max-width: 768px) {
            body { flex-direction: column; }
            .rep-sidebar {
                width: 100%; height: 70px;
                position: fixed; bottom: 0; left: 0;
                flex-direction: row; justify-content: space-around; align-items: center;
                padding: 0; z-index: 2000;
                box-shadow: 0 -4px 12px rgba(0,0,0,0.15);
            }
            .rep-brand, .rep-footer, .rep-nav-label { display: none; }
            .rep-mobile-logout { display: flex; color: #ef4444 !important; }
            .rep-nav {
                display: flex; flex-direction: row; width: 100%; padding: 0;
                justify-content: space-evenly; align-items: center; overflow: visible;
            }
            .rep-link {
                flex-direction: column; padding: 10px; margin: 0;
                font-size: 11px; gap: 4px; border-radius: 0;
                justify-content: center; flex: 1; text-align: center;
            }
            .rep-link.active {
                background: transparent; border-top: 3px solid #5eead4; color: #5eead4;
            }
            .rep-link i { font-size: 20px; }
            
            .rep-main { padding: 16px; padding-bottom: 90px; }
            .rep-header { flex-direction: column; align-items: flex-start; gap: 12px; margin-bottom: 20px; }
            .rep-header h1 { font-size: 22px; }
            .rep-header button { width: 100%; }
            
            .rep-stat-grid { grid-template-columns: 1fr !important; gap: 12px !important; margin-bottom: 20px !important; }
            .rep-delivery-details { grid-template-columns: 1fr !important; gap: 16px !important; }
            
            .delivery-card-header { flex-direction: column; align-items: flex-start; gap: 10px; }
            .delivery-card-footer { flex-direction: column; }
            .delivery-card-footer button { width: 100%; padding: 12px; font-size: 14px; }
            
            .rep-map-modal { width: 95%; max-width: 100%; }
        }
    </style>
</head>
<body>

    <div class="rep-sidebar">
        <div class="rep-brand">
            <h2>New<span>One</span></h2>
            <div class="rep-tag"><i class="fas fa-motorcycle"></i> Repartidor</div>
        </div>
        <nav class="rep-nav">
            <div class="rep-nav-label">Entregas</div>
            <a class="rep-link active" onclick="repShowSection('rep-inicio')" data-section="rep-inicio">
                <i class="fas fa-home"></i> Inicio
            </a>
            <a class="rep-link" onclick="repShowSection('rep-entregas')" data-section="rep-entregas">
                <i class="fas fa-truck"></i> Mis Entregas
            </a>
            <a class="rep-link" onclick="repShowSection('rep-historial')" data-section="rep-historial">
                <i class="fas fa-history"></i> Historial
            </a>
            
            <div class="rep-nav-label">Comunicaci&oacute;n</div>
            <a class="rep-link" onclick="repShowSection('rep-chat')" data-section="rep-chat">
                <i class="fas fa-comments"></i> Chat
            </a>
            <a href="index.jsp" class="rep-link rep-mobile-logout" title="Cerrar Sesión">
                <i class="fas fa-sign-out-alt"></i> Salir
            </a>
        </nav>
        <div class="rep-footer">
            <div class="rep-avatar"><%= usuario.getNombreCompleto().substring(0,1) %></div>
            <div class="rep-footer-info">
                <div class="rep-footer-name"><%= usuario.getNombreCompleto() %></div>
                <div class="rep-footer-role">Repartidor</div>
            </div>
            <a href="index.jsp" class="rep-logout" title="Cerrar Sesi&oacute;n"><i class="fas fa-sign-out-alt"></i></a>
        </div>
    </div>

    <div class="rep-main">
        <div id="rep-notification" class="notification">
            <strong id="rep-notificationMsg">Notificaci&oacute;n</strong>
        </div>

        <!-- INICIO REPARTIDOR -->
        <section id="rep-inicio" class="rep-section active">
            <div class="rep-header">
                <div>
                    <h1>Hola, <%= usuario.getNombreCompleto() %></h1>
                    <p>Resumen de tus entregas del d&iacute;a.</p>
                </div>
            </div>

            <div class="rep-stat-grid" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px;">
                <div class="rep-stat-card">
                    <div class="rep-stat-num"><%= pedidosDelivery.size() %></div>
                    <div class="rep-stat-lbl">Entregas Pendientes</div>
                </div>
                <div class="rep-stat-card">
                    <div class="rep-stat-num" style="color: #22c55e;">0</div>
                    <div class="rep-stat-lbl">Completadas Hoy</div>
                </div>
                <div class="rep-stat-card">
                    <div class="rep-stat-num" style="color: #f59e0b;">S/ 0.00</div>
                    <div class="rep-stat-lbl">Cobros Pendientes</div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h3><i class="fas fa-motorcycle" style="color: #0f766e;"></i> Entregas Asignadas</h3>
                </div>
                <% if (pedidosDelivery.isEmpty()) { %>
                    <div style="text-align: center; padding: 40px; color: var(--gray-500);">
                        <i class="fas fa-inbox" style="font-size: 40px; color: var(--gray-300); display: block; margin-bottom: 12px;"></i>
                        No hay entregas pendientes por el momento.
                    </div>
                <% } else { %>
                    <% for (Pedidos p : pedidosDelivery) {
                        String st = p.getEstado();
                        String item = "Producto";
                        if (!p.getDetallePedidoList().isEmpty() && p.getDetallePedidoList().get(0).getIdProducto() != null)
                            item = p.getDetallePedidoList().get(0).getIdProducto().getNombre();
                        
                        String badgeClass = "rep-status-pendiente";
                        if ("En Camino".equals(st)) badgeClass = "rep-status-camino";
                        if ("Entregado".equals(st)) badgeClass = "rep-status-entregado";
                    %>
                    <div class="delivery-card">
                        <div class="delivery-card-header">
                            <div>
                                <strong style="font-size: 15px;">Pedido #<%= p.getIdPedido() %></strong>
                                <span style="color: var(--gray-600); font-size: 13px; margin-left: 8px;"><%= item %></span>
                            </div>
                            <span class="rep-status-badge <%= badgeClass %>"><%= st %></span>
                        </div>
                        <div class="delivery-card-body">
                            <div class="rep-delivery-details" style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 14px;">
                                <div>
                                    <span style="color: var(--gray-500); font-size: 12px;">CLIENTE</span><br>
                                    <strong><%= p.getIdCliente().getNombreCompleto() %></strong>
                                </div>
                                <div>
                                    <span style="color: var(--gray-500); font-size: 12px;">MONTO</span><br>
                                    <strong style="color: #0f766e;">S/ <%= String.format("%.2f", p.getMontoTotal()) %></strong>
                                </div>
                                <div>
                                    <span style="color: var(--gray-500); font-size: 12px;">FECHA</span><br>
                                    <span><%= sdf.format(p.getFechaRecepcion()) %></span>
                                </div>
                                <div>
                                    <span style="color: var(--gray-500); font-size: 12px;">ESTADO PAGO</span><br>
                                    <span><%= p.getEstadoPago() != null ? p.getEstadoPago() : "Pendiente" %></span>
                                </div>
                            </div>
                            <%
                                String dirCliente = p.getIdCliente().getDireccion() != null ? p.getIdCliente().getDireccion() : "";
                                String dirVisible = dirCliente;
                                String latCli = "";
                                String lngCli = "";
                                if (dirCliente.contains("||")) {
                                    dirVisible = dirCliente.substring(0, dirCliente.indexOf("||"));
                                    String[] coordsParts = dirCliente.substring(dirCliente.indexOf("||") + 2).split(",");
                                    if (coordsParts.length == 2) {
                                        latCli = coordsParts[0].trim();
                                        lngCli = coordsParts[1].trim();
                                    }
                                }
                                boolean hasCoords = !latCli.isEmpty() && !lngCli.isEmpty();
                            %>
                            <div style="margin-top: 12px; padding: 10px; background: #f0fdfa; border-radius: 8px; font-size: 13px;">
                                <i class="fas fa-map-marker-alt" style="color: #0f766e;"></i>
                                <strong>Direcci&oacute;n:</strong> <%= dirVisible %>
                                <% if (hasCoords) { %>
                                    <span style="color: #0f766e; font-size: 11px; margin-left: 6px;"><i class="fas fa-check-circle"></i> GPS</span>
                                <% } %>
                            </div>
                        </div>
                        <div class="delivery-card-footer">
                            <% if (!"En Camino".equals(st) && !"Entregado".equals(st)) { %>
                            <button class="btn btn-primary btn-sm" onclick="repActualizarEstado(<%= p.getIdPedido() %>, 'En Camino')" style="background: #0f766e;">
                                <i class="fas fa-play"></i> Iniciar Entrega
                            </button>
                            <% } %>
                            <% if ("En Camino".equals(st)) { %>
                            <button class="btn btn-sm" style="background: #22c55e; color: white;" onclick="repActualizarEstado(<%= p.getIdPedido() %>, 'Entregado')">
                                <i class="fas fa-check"></i> Marcar Entregado
                            </button>
                            <% } %>
                            <% if ("Entregado".equals(st)) { %>
                            <button class="btn btn-sm" style="background: #22c55e; color: white; opacity: 0.6; cursor: not-allowed;" disabled>
                                <i class="fas fa-check-double"></i> Entrega Completada
                            </button>
                            <% } %>
                            <% if (hasCoords) { %>
                            <button class="btn btn-outline btn-sm" onclick="abrirMapaRepartidor('<%= latCli %>', '<%= lngCli %>', '<%= dirVisible.replace("'", "\\'") %>', '<%= p.getIdCliente().getNombreCompleto().replace("'", "\\'") %>')">
                                <i class="fas fa-map-marked-alt"></i> Ver Ubicaci&oacute;n
                            </button>
                            <% } else { %>
                            <button class="btn btn-outline btn-sm" disabled title="Cliente sin coordenadas registradas" style="opacity: 0.5;">
                                <i class="fas fa-map-marked-alt"></i> Sin GPS
                            </button>
                            <% } %>
                            <button class="btn btn-outline btn-sm" onclick="repShowSection('rep-chat')">
                                <i class="fas fa-comment"></i> Contactar Admin
                            </button>
                        </div>
                    </div>
                    <% } %>
                <% } %>
            </div>
        </section>

        <!-- ENTREGAS REPARTIDOR -->
        <section id="rep-entregas" class="rep-section">
            <div class="rep-header">
                <div>
                    <h1>Mis Entregas</h1>
                    <p>Gestiona y actualiza el estado de tus env&iacute;os.</p>
                </div>
                <button class="btn btn-outline" onclick="repShowSection('rep-inicio')">
                    <i class="fas fa-arrow-left"></i> Volver
                </button>
            </div>
            <jsp:include page="views/repartidor_entregas.jsp" />
        </section>

        <!-- HISTORIAL REPARTIDOR -->
        <section id="rep-historial" class="rep-section">
            <div class="rep-header">
                <div>
                    <h1>Historial de Entregas</h1>
                    <p>Registro de tus entregas completadas.</p>
                </div>
                <button class="btn btn-outline" onclick="repShowSection('rep-inicio')">
                    <i class="fas fa-arrow-left"></i> Volver
                </button>
            </div>
            <div class="card">
                <% boolean hayHistorial = false; 
                   for(Pedidos p : pedidosDelivery) {
                       if("Entregado".equals(p.getEstado())) { hayHistorial = true; break; }
                   }
                   if (!hayHistorial) { %>
                <div style="text-align: center; padding: 40px; color: var(--gray-500);">
                    <i class="fas fa-history" style="font-size: 40px; color: var(--gray-300); display: block; margin-bottom: 12px;"></i>
                    Tus entregas completadas aparecer&aacute;n aqu&iacute;.
                </div>
                <% } else { %>
                <div style="overflow-x: auto;">
                    <table class="table">
                        <thead><tr><th>ID</th><th>Cliente</th><th>Fecha</th><th>Estado</th></tr></thead>
                        <tbody>
                        <% for(Pedidos p : pedidosDelivery) { 
                            if("Entregado".equals(p.getEstado())) { 
                                String fch = new java.text.SimpleDateFormat("dd/MM HH:mm").format(p.getFechaRecepcion());
                        %>
                            <tr>
                                <td data-label="ID">#<%= p.getIdPedido() %></td>
                                <td data-label="Cliente"><%= p.getIdCliente().getNombreCompleto() %></td>
                                <td data-label="Fecha"><%= fch %></td>
                                <td data-label="Estado"><span class="badge badge-success">Completado</span></td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
        </section>

        <!-- CHAT REPARTIDOR -->
        <section id="rep-chat" class="rep-section">
            <div class="rep-header">
                <div>
                    <h1>Chat</h1>
                    <p>Comun&iacute;cate con admin y empleados.</p>
                </div>
                <button class="btn btn-outline" onclick="repShowSection('rep-inicio')">
                    <i class="fas fa-arrow-left"></i> Volver
                </button>
            </div>
            <jsp:include page="views/section_chat.jsp" />
        </section>
    </div>

    <script>
        function repShowSection(id) {
            document.querySelectorAll('.rep-section').forEach(s => s.classList.remove('active'));
            document.querySelectorAll('.rep-link').forEach(l => l.classList.remove('active'));
            var t = document.getElementById(id);
            if (t) t.classList.add('active');
            var l = document.querySelector('[data-section="'+id+'"]');
            if (l) l.classList.add('active');
            if (id === 'rep-chat') initChat();
        }
        function repActualizarEstado(id, estado) {
            var fd = new URLSearchParams();
            fd.append('idPedido', id);
            fd.append('nuevoEstado', estado);
            fd.append('nuevaNota', 'Actualizado por repartidor');
            fd.append('notasAnteriores', '');
            fetch('TrackingServlet', { method: 'POST', body: fd }).then(function(r){ return r.text(); }).then(function(d){
                if (d.trim() === 'success') {
                    repNotify('Estado actualizado: ' + estado, 'success');
                    setTimeout(function(){ location.reload(); }, 1200);
                } else {
                    repNotify('Error al actualizar', 'error');
                }
            });
        }
        function repNotify(msg, type) {
            var n = document.getElementById('rep-notification');
            var x = document.getElementById('rep-notificationMsg');
            if (n && x) {
                x.innerText = msg;
                n.style.borderLeftColor = type === 'error' ? '#dc3545' : '#14b8a6';
                n.classList.add('show');
                setTimeout(function(){ n.classList.remove('show'); }, 3000);
            }
        }

        var repMap = null;
        var repMapMarker = null;

        function abrirMapaRepartidor(lat, lng, direccion, nombreCliente) {
            var overlay = document.getElementById('repMapOverlay');
            overlay.classList.add('open');
            document.getElementById('repMapAddress').innerHTML = '<i class="fas fa-user"></i> <strong>' + nombreCliente + '</strong> &mdash; ' + direccion;

            if (repMap) {
                repMap.remove();
                repMap = null;
            }

            setTimeout(function() {
                repMap = L.map('repMapContainer').setView([parseFloat(lat), parseFloat(lng)], 16);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; OpenStreetMap'
                }).addTo(repMap);
                repMapMarker = L.marker([parseFloat(lat), parseFloat(lng)]).addTo(repMap);
                repMapMarker.bindPopup('<strong>' + nombreCliente + '</strong><br>' + direccion).openPopup();
                repMap.invalidateSize();
            }, 100);
        }

        function cerrarMapaRepartidor() {
            document.getElementById('repMapOverlay').classList.remove('open');
            if (repMap) { repMap.remove(); repMap = null; }
        }
    </script>

    <div id="repMapOverlay" class="rep-map-overlay" onclick="if(event.target===this) cerrarMapaRepartidor();">
        <div class="rep-map-modal">
            <div class="rep-map-modal-header">
                <h4><i class="fas fa-map-marked-alt" style="color: #0f766e;"></i> Ubicaci&oacute;n del Cliente</h4>
                <button class="rep-map-modal-close" onclick="cerrarMapaRepartidor()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="rep-map-modal-body">
                <div id="repMapContainer" style="height: 320px; width: 100%;"></div>
            </div>
            <div class="rep-map-address" id="repMapAddress">
                <i class="fas fa-info-circle" style="color: var(--gray-400);"></i>
                <span>Cargando...</span>
            </div>
        </div>
    </div>
</body>
</html>
