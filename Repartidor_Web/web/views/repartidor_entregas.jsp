
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionPedidosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Pedidos, entidades.DetallePedido" %>
<%@ page import="java.util.List, java.util.ArrayList, java.text.SimpleDateFormat" %>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<style>
    .rep-ent-map-overlay {
        position: fixed; inset: 0; background: rgba(0,0,0,0.5);
        backdrop-filter: blur(4px); z-index: 3000;
        display: none; align-items: center; justify-content: center;
    }
    .rep-ent-map-overlay.open { display: flex; }
    .rep-ent-map-modal {
        background: var(--white); border-radius: var(--radius-xl);
        box-shadow: 0 16px 48px rgba(0,0,0,0.2);
        width: 550px; max-width: 92%; overflow: hidden;
        animation: scaleIn 0.3s ease;
    }
    .rep-ent-map-modal-header {
        display: flex; justify-content: space-between; align-items: center;
        padding: 16px 20px; border-bottom: 1px solid var(--gray-200);
    }
    .rep-ent-map-modal-header h4 { margin: 0; font-size: 15px; color: var(--dark); }
    .rep-ent-map-close {
        background: var(--gray-100); border: none; color: var(--gray-600);
        width: 30px; height: 30px; border-radius: var(--radius-sm);
        cursor: pointer; display: flex; align-items: center; justify-content: center;
    }
    .rep-ent-map-address {
        padding: 12px 20px; background: var(--gray-50);
        font-size: 13px; color: var(--gray-700);
        display: flex; align-items: center; gap: 8px;
        border-top: 1px solid var(--gray-200);
    }
</style>

<%
    List<Pedidos> pedidosRep = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
        pedidosRep = pedidoRMI.listarPedidosPorTrackingTab("delivery");
    } catch(Exception e) {}
    
    SimpleDateFormat sdf2 = new SimpleDateFormat("dd/MM HH:mm");
%>

<div class="card">
    <div class="card-header">
        <h3><i class="fas fa-truck"></i> Entregas de Delivery</h3>
    </div>
    
    <% if (pedidosRep.isEmpty()) { %>
        <div style="text-align: center; padding: 40px; color: var(--gray-500);">
            <i class="fas fa-check-circle" style="font-size: 40px; color: #d1fae5; display: block; margin-bottom: 12px;"></i>
            &iexcl;No hay entregas pendientes! Todo al d&iacute;a.
        </div>
    <% } else { %>
        <div style="overflow-x: auto;">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Cliente</th>
                        <th>Producto</th>
                        <th>Estado</th>
                        <th>Fecha</th>
                        <th>Ubicaci&oacute;n</th>
                        <th>Acci&oacute;n</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Pedidos p : pedidosRep) {
                        String st = p.getEstado();
                        String item = "Producto";
                        if (!p.getDetallePedidoList().isEmpty() && p.getDetallePedidoList().get(0).getIdProducto() != null)
                            item = p.getDetallePedidoList().get(0).getIdProducto().getNombre();
                        
                        String badgeClass = "badge-info";
                        if ("En Camino".equals(st)) badgeClass = "badge-warning";
                        if ("Entregado".equals(st)) badgeClass = "badge-success";

                        String dirC = p.getIdCliente().getDireccion() != null ? p.getIdCliente().getDireccion() : "";
                        String dirVis = dirC;
                        String latC = "";
                        String lngC = "";
                        if (dirC.contains("||")) {
                            dirVis = dirC.substring(0, dirC.indexOf("||"));
                            String[] cp = dirC.substring(dirC.indexOf("||") + 2).split(",");
                            if (cp.length == 2) { latC = cp[0].trim(); lngC = cp[1].trim(); }
                        }
                        boolean hasGPS = !latC.isEmpty() && !lngC.isEmpty();
                    %>
                    <tr>
                        <td><strong>#<%= p.getIdPedido() %></strong></td>
                        <td><%= p.getIdCliente().getNombreCompleto() %></td>
                        <td><%= item %></td>
                        <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                        <td style="color: var(--gray-600);"><%= sdf2.format(p.getFechaRecepcion()) %></td>
                        <td>
                            <% if (hasGPS) { %>
                            <button class="btn btn-sm" style="background: #0f766e; color: white; font-size: 12px;"
                                onclick="repEntAbrirMapa('<%= latC %>', '<%= lngC %>', '<%= dirVis.replace("'","\\'") %>', '<%= p.getIdCliente().getNombreCompleto().replace("'","\\'") %>')">
                                <i class="fas fa-map-marked-alt"></i> Ver Mapa
                            </button>
                            <% } else { %>
                            <span style="color: var(--gray-400); font-size: 12px;"><i class="fas fa-map-marker-alt"></i> Sin GPS</span>
                            <% } %>
                        </td>
                        <td>
                            <div style="display: flex; gap: 6px;">
                                <% if (!"Entregado".equals(st)) { %>
                                <button class="btn btn-primary btn-sm" onclick="repActualizarEstado(<%= p.getIdPedido() %>, 'En Camino')" style="background: #0f766e; font-size: 12px;">
                                    <i class="fas fa-play"></i> En Camino
                                </button>
                                <button class="btn btn-sm" style="background: #22c55e; color: white; font-size: 12px;" onclick="repActualizarEstado(<%= p.getIdPedido() %>, 'Entregado')">
                                    <i class="fas fa-check"></i> Entregado
                                </button>
                                <% } else { %>
                                <span class="badge badge-success"><i class="fas fa-check"></i> Completado</span>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</div>

<div id="repEntMapOverlay" class="rep-ent-map-overlay" onclick="if(event.target===this) repEntCerrarMapa();">
    <div class="rep-ent-map-modal">
        <div class="rep-ent-map-modal-header">
            <h4><i class="fas fa-map-marked-alt" style="color: #0f766e;"></i> Ubicaci&oacute;n del Cliente</h4>
            <button class="rep-ent-map-close" onclick="repEntCerrarMapa()"><i class="fas fa-times"></i></button>
        </div>
        <div id="repEntMapContainer" style="height: 320px; width: 100%;"></div>
        <div class="rep-ent-map-address" id="repEntMapAddress"></div>
    </div>
</div>

<script>
    var repEntMap = null;
    var repEntMarker = null;

    function repEntAbrirMapa(lat, lng, direccion, nombre) {
        document.getElementById('repEntMapOverlay').classList.add('open');
        document.getElementById('repEntMapAddress').innerHTML = '<i class="fas fa-user"></i> <strong>' + nombre + '</strong> &mdash; ' + direccion;
        if (repEntMap) { repEntMap.remove(); repEntMap = null; }
        setTimeout(function() {
            repEntMap = L.map('repEntMapContainer').setView([parseFloat(lat), parseFloat(lng)], 16);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '&copy; OpenStreetMap' }).addTo(repEntMap);
            repEntMarker = L.marker([parseFloat(lat), parseFloat(lng)]).addTo(repEntMap);
            repEntMarker.bindPopup('<strong>' + nombre + '</strong><br>' + direccion).openPopup();
            repEntMap.invalidateSize();
        }, 100);
    }

    function repEntCerrarMapa() {
        document.getElementById('repEntMapOverlay').classList.remove('open');
        if (repEntMap) { repEntMap.remove(); repEntMap = null; }
    }
</script>
