
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionPedidosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="entidades.Empleados" %>

<%
    HttpSession sesion = request.getSession();
    Empleados usuario = (Empleados) sesion.getAttribute("usuario");
    
    if (usuario == null) {
        response.sendRedirect("auth.jsp");
        return;
    }

    long pedidosHoy = 0;
    long enProceso = 0;
    long terminados = 0;
    double ingresosMes = 0;

    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
        pedidosHoy = pedidoRMI.contarPedidosHoy();
        enProceso = pedidoRMI.contarEnProceso();
        terminados = pedidoRMI.contarTerminados();
        ingresosMes = pedidoRMI.calcularIngresosMes();
    } catch(Exception e) {}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Empleado - New One</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
    <style>
        body { font-family: var(--font-body); margin: 0; background: #f0f4f8; display: flex; height: 100vh; overflow: hidden; }

        .emp-sidebar {
            width: 260px;
            background: linear-gradient(180deg, #1e3a5f 0%, #152238 100%);
            color: var(--white);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }
        .emp-sidebar-brand {
            padding: 24px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .emp-sidebar-brand h2 { margin: 0; font-size: 20px; font-weight: 800; color: var(--white); }
        .emp-sidebar-brand h2 span { color: #7dd3fc; }
        .emp-sidebar-brand .role-tag {
            display: inline-block;
            background: rgba(125,211,252,0.15);
            color: #7dd3fc;
            padding: 2px 10px;
            border-radius: 20px;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 6px;
        }

        .emp-nav { flex: 1; padding: 16px 12px; overflow-y: auto; }
        .emp-nav-label {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: rgba(255,255,255,0.25);
            padding: 16px 12px 8px;
        }
        .emp-nav-link {
            display: flex;
            align-items: center;
            padding: 11px 16px;
            color: rgba(255,255,255,0.5);
            text-decoration: none;
            transition: all 0.2s;
            cursor: pointer;
            border-radius: var(--radius-sm);
            margin-bottom: 2px;
            font-size: 14px;
            font-weight: 500;
            gap: 12px;
        }
        .emp-nav-link:hover { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.9); }
        .emp-nav-link.active { background: rgba(125,211,252,0.12); color: #7dd3fc; }
        .emp-nav-link i { width: 20px; text-align: center; font-size: 15px; }

        .emp-footer {
            padding: 16px;
            border-top: 1px solid rgba(255,255,255,0.08);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .emp-avatar {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, #7dd3fc, #38bdf8);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; color: #1e3a5f; font-size: 14px; flex-shrink: 0;
        }
        .emp-footer-info { flex: 1; overflow: hidden; }
        .emp-footer-name { font-weight: 600; font-size: 13px; }
        .emp-footer-role { font-size: 11px; color: rgba(255,255,255,0.4); }
        .emp-logout { color: rgba(255,255,255,0.3); transition: color 0.2s; text-decoration: none; padding: 8px; }
        .emp-logout:hover { color: #f87171; }

        .emp-main { flex: 1; overflow-y: auto; padding: 0; position: relative; }
        .emp-section { display: none; padding: 32px; animation: fadeIn 0.3s ease-out; }
        .emp-section.active { display: block; }

        .emp-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px;
        }
        .emp-header h1 { font-size: 24px; margin: 0; color: #1e3a5f; }
        .emp-header p { color: var(--gray-600); font-size: 14px; margin: 4px 0 0; }

        .emp-metric {
            background: var(--white);
            padding: 20px 24px;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
            border-left: 4px solid #38bdf8;
            display: flex; align-items: center; justify-content: space-between;
        }
        .emp-metric-val { font-size: 28px; font-weight: 800; color: #1e3a5f; }
        .emp-metric-lbl { color: var(--gray-600); font-size: 13px; font-weight: 500; }
        .emp-metric-icon { font-size: 24px; color: #bae6fd; }

        .emp-notification {
            position: fixed; top: 20px; right: 20px; z-index: 5000;
            background: white; padding: 14px 24px; border-radius: var(--radius-md);
            box-shadow: var(--shadow-lg); border-left: 4px solid #38bdf8;
            transform: translateX(120%); transition: transform 0.3s ease;
            font-size: 14px; font-weight: 600;
        }
        .emp-notification.show { transform: translateX(0); }
    </style>
</head>
<body>

    <div class="emp-sidebar">
        <div class="emp-sidebar-brand">
            <h2>New<span>One</span></h2>
            <div class="role-tag"><i class="fas fa-user-hard-hat"></i> Empleado</div>
        </div>
        <nav class="emp-nav">
            <div class="emp-nav-label">Operaciones</div>
            <a class="emp-nav-link active" onclick="empShowSection('emp-dashboard')" data-section="emp-dashboard">
                <i class="fas fa-chart-pie"></i> Mi Panel
            </a>
            <a class="emp-nav-link" onclick="empShowSection('emp-recepcion')" data-section="emp-recepcion">
                <i class="fas fa-clipboard-list"></i> Recepci&oacute;n
            </a>
            <a class="emp-nav-link" onclick="empShowSection('emp-colas')" data-section="emp-colas">
                <i class="fas fa-layer-group"></i> Cola de Pedidos
            </a>
            <a class="emp-nav-link" onclick="empShowSection('emp-tracking')" data-section="emp-tracking">
                <i class="fas fa-route"></i> Seguimiento
            </a>
            <a class="emp-nav-link" onclick="empShowSection('emp-clientes')" data-section="emp-clientes">
                <i class="fas fa-user-plus"></i> Clientes
            </a>

            <div class="emp-nav-label">Comunicaci&oacute;n</div>
            <a class="emp-nav-link" onclick="empShowSection('emp-chat')" data-section="emp-chat">
                <i class="fas fa-comments"></i> Chat
            </a>
        </nav>
        <div class="emp-footer">
            <div class="emp-avatar"><%= usuario.getNombreCompleto().substring(0,1) %></div>
            <div class="emp-footer-info">
                <div class="emp-footer-name"><%= usuario.getNombreCompleto() %></div>
                <div class="emp-footer-role">Empleado Operativo</div>
            </div>
            <a href="index.jsp" class="emp-logout" title="Cerrar Sesi&oacute;n"><i class="fas fa-sign-out-alt"></i></a>
        </div>
    </div>

    <div class="emp-main">
        <div id="emp-notification" class="emp-notification">
            <strong id="emp-notificationMsg">Operaci&oacute;n Exitosa</strong>
        </div>

        <!-- DASHBOARD EMPLEADO -->
        <section id="emp-dashboard" class="emp-section active">
            <div class="container">
                <div class="emp-header">
                    <div>
                        <h1>Bienvenido, <%= usuario.getNombreCompleto() %></h1>
                        <p>Vista general de tus operaciones de hoy.</p>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px;">
                    <div class="emp-metric">
                        <div>
                            <div class="emp-metric-val"><%= pedidosHoy %></div>
                            <div class="emp-metric-lbl">Pedidos Hoy</div>
                        </div>
                        <div class="emp-metric-icon"><i class="fas fa-shopping-bag"></i></div>
                    </div>
                    <div class="emp-metric" style="border-left-color: #f59e0b;">
                        <div>
                            <div class="emp-metric-val"><%= enProceso %></div>
                            <div class="emp-metric-lbl">En Proceso</div>
                        </div>
                        <div class="emp-metric-icon" style="color: #fef3c7;"><i class="fas fa-spinner"></i></div>
                    </div>
                    <div class="emp-metric" style="border-left-color: #22c55e;">
                        <div>
                            <div class="emp-metric-val"><%= terminados %></div>
                            <div class="emp-metric-lbl">Terminados</div>
                        </div>
                        <div class="emp-metric-icon" style="color: #bbf7d0;"><i class="fas fa-check-double"></i></div>
                    </div>
                    <div class="emp-metric" style="border-left-color: #a78bfa;">
                        <div>
                            <div class="emp-metric-val">S/ <%= String.format("%.2f", ingresosMes) %></div>
                            <div class="emp-metric-lbl">Ingresos del Mes</div>
                        </div>
                        <div class="emp-metric-icon" style="color: #ddd6fe;"><i class="fas fa-coins"></i></div>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div class="card">
                        <div class="card-header"><h3>Acciones R&aacute;pidas</h3></div>
                        <div style="display: flex; flex-direction: column; gap: 10px;">
                            <button onclick="empShowSection('emp-recepcion')" style="display:flex; align-items:center; gap:12px; padding:14px 18px; background:var(--gray-50); border:1.5px solid var(--gray-200); border-radius:var(--radius-md); cursor:pointer; transition:all 0.2s; font-family:var(--font-body); font-size:14px; font-weight:500; color:var(--dark); text-align:left;">
                                <i class="fas fa-clipboard-list" style="color:#2563eb; width:20px; text-align:center;"></i> Nuevo Pedido (Walk-in)
                            </button>
                            <button onclick="empShowSection('emp-colas')" style="display:flex; align-items:center; gap:12px; padding:14px 18px; background:var(--gray-50); border:1.5px solid var(--gray-200); border-radius:var(--radius-md); cursor:pointer; transition:all 0.2s; font-family:var(--font-body); font-size:14px; font-weight:500; color:var(--dark); text-align:left;">
                                <i class="fas fa-layer-group" style="color:#f59e0b; width:20px; text-align:center;"></i> Ver Cola de Pedidos
                            </button>
                            <button onclick="empShowSection('emp-tracking')" style="display:flex; align-items:center; gap:12px; padding:14px 18px; background:var(--gray-50); border:1.5px solid var(--gray-200); border-radius:var(--radius-md); cursor:pointer; transition:all 0.2s; font-family:var(--font-body); font-size:14px; font-weight:500; color:var(--dark); text-align:left;">
                                <i class="fas fa-route" style="color:#22c55e; width:20px; text-align:center;"></i> Seguimiento
                            </button>
                            <button onclick="empShowSection('emp-chat')" style="display:flex; align-items:center; gap:12px; padding:14px 18px; background:var(--gray-50); border:1.5px solid var(--gray-200); border-radius:var(--radius-md); cursor:pointer; transition:all 0.2s; font-family:var(--font-body); font-size:14px; font-weight:500; color:var(--dark); text-align:left;">
                                <i class="fas fa-comments" style="color:#a78bfa; width:20px; text-align:center;"></i> Abrir Chat
                            </button>
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-header"><h3>Protocolo del D&iacute;a</h3></div>
                        <div style="color: var(--gray-600); font-size: 14px; line-height: 1.8;">
                            <p><i class="fas fa-clipboard-list" style="color: #2563eb;"></i> <strong>Recepci&oacute;n:</strong> Registra pedidos walk-in seleccionando servicio y datos del cliente.</p>
                            <p><i class="fas fa-layer-group" style="color: #f59e0b;"></i> <strong>Cola:</strong> Gestiona el flujo: Recibido &rarr; En Lavado &rarr; Terminado &rarr; Entregado.</p>
                            <p><i class="fas fa-route" style="color: #22c55e;"></i> <strong>Seguimiento:</strong> Actualiza estados de pedidos delivery y recojo.</p>
                            <p><i class="fas fa-comments" style="color: #a78bfa;"></i> <strong>Chat:</strong> Comunica novedades al admin y repartidores.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- COLA DE PEDIDOS -->
        <section id="emp-colas" class="emp-section">
            <div class="container">
                <div class="emp-header">
                    <div>
                        <h1>Cola de Pedidos</h1>
                        <p>Gesti&oacute;n operativa del flujo de trabajo.</p>
                    </div>
                    <button class="btn btn-outline" onclick="empShowSection('emp-dashboard')">
                        <i class="fas fa-arrow-left"></i> Volver
                    </button>
                </div>
                <jsp:include page="views/section_colas.jsp" />
            </div>
        </section>

        <!-- RECEPCIÓN WALK-IN -->
        <section id="emp-recepcion" class="emp-section">
            <div class="container">
                <div class="emp-header">
                    <div>
                        <h1>Recepci&oacute;n de Pedidos</h1>
                        <p>Registra pedidos de clientes que llegan a la tienda.</p>
                    </div>
                    <button class="btn btn-outline" onclick="empShowSection('emp-dashboard')">
                        <i class="fas fa-arrow-left"></i> Volver
                    </button>
                </div>
                <jsp:include page="views/section_recepcion.jsp" />
            </div>
        </section>

        <!-- SEGUIMIENTO -->
        <section id="emp-tracking" class="emp-section">
            <div class="container">
                <div class="emp-header">
                    <div>
                        <h1>Seguimiento de Pedidos</h1>
                        <p>Gesti&oacute;n de log&iacute;stica y estados.</p>
                    </div>
                    <button class="btn btn-outline" onclick="empShowSection('emp-dashboard')">
                        <i class="fas fa-arrow-left"></i> Volver
                    </button>
                </div>
                <jsp:include page="views/section_tracking.jsp" />
            </div>
        </section>

        <!-- CLIENTES Y BONOS -->
        <section id="emp-clientes" class="emp-section">
            <div class="container">
                <div class="emp-header">
                    <div>
                        <h1>Gesti&oacute;n de Clientes</h1>
                        <p>Registra nuevos clientes y otorga bonos de fidelidad.</p>
                    </div>
                    <button class="btn btn-outline" onclick="empShowSection('emp-dashboard')">
                        <i class="fas fa-arrow-left"></i> Volver
                    </button>
                </div>
                <jsp:include page="views/section_clientes_emp.jsp" />
            </div>
        </section>

        <!-- CHAT -->
        <section id="emp-chat" class="emp-section">
            <div class="container">
                <div class="emp-header">
                    <div>
                        <h1>Chat Interno</h1>
                        <p>Comun&iacute;cate con admin y repartidores.</p>
                    </div>
                    <button class="btn btn-outline" onclick="empShowSection('emp-dashboard')">
                        <i class="fas fa-arrow-left"></i> Volver
                    </button>
                </div>
                <jsp:include page="views/section_chat.jsp" />
            </div>
        </section>
    </div>

    <script>
        function empShowSection(id) {
            document.querySelectorAll('.emp-section').forEach(function(s) { s.classList.remove('active'); });
            document.querySelectorAll('.emp-nav-link').forEach(function(l) { l.classList.remove('active'); });
            var t = document.getElementById(id);
            if (t) t.classList.add('active');
            var l = document.querySelector('[data-section="'+id+'"]');
            if (l) l.classList.add('active');
            if (id === 'emp-chat') initChat();
            if (id === 'emp-tracking') { switchTrackingTab('servicios'); cargarPedidosTracking(); }
            if (id === 'emp-clientes') { cargarListaClientes(); }
        }
        function empNotify(msg, type) {
            var n = document.getElementById('emp-notification');
            var x = document.getElementById('emp-notificationMsg');
            if (n && x) {
                x.innerText = msg;
                n.style.borderLeftColor = type === 'error' ? '#dc3545' : '#38bdf8';
                n.classList.add('show');
                setTimeout(function(){ n.classList.remove('show'); }, 3000);
            }
        }
    </script>
    <script src="js/admin-logic.js"></script>
    <script src="js/emp-tracking.js"></script>
    <script src="js/emp-clientes.js"></script>
</body>
</html>
