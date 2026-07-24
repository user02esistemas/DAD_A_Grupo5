
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionPedidosRemoto, Interfaces.IGestionClientesRemoto, Interfaces.IGestionServiciosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%@ page import="entidades.Empleados" %>

<%
    HttpSession sesion = request.getSession();
    Empleados usuario = (Empleados) sesion.getAttribute("usuario");
    
    if (usuario == null) {
        response.sendRedirect("auth.jsp");
        return;
    }

    String rol = (String) sesion.getAttribute("rol");
    if (rol != null && (rol.equals("empleado") || rol.equals("repartidor"))) {
        if ("empleado".equals(rol)) { response.sendRedirect("empleado.jsp"); return; }
        if ("repartidor".equals(rol)) { response.sendRedirect("repartidor.jsp"); return; }
    }

    long pedidosHoy = 0;
    BigDecimal ingresosMes = BigDecimal.ZERO;
    long clientesActivos = 0;
    long enProceso = 0;
    long terminados = 0;
    long citasPendientes = 0;

    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionPedidosRemoto pedidoRMI = (IGestionPedidosRemoto) registry.lookup("pedidoServicio");
        IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
        IGestionServiciosRemoto servicioRMI = (IGestionServiciosRemoto) registry.lookup("servicioCitaServicio");
        
        pedidosHoy = pedidoRMI.contarPedidosHoy();
        double ingresos = pedidoRMI.calcularIngresosMes();
        ingresosMes = new BigDecimal(String.valueOf(ingresos));
        clientesActivos = clienteRMI.listarClientes().size();
        enProceso = pedidoRMI.contarEnProceso();
        terminados = pedidoRMI.contarTerminados();
        citasPendientes = servicioRMI.listarCitasPendientes().size();
    } catch(Exception e) {
        System.out.println("Error en Dashboard Metrics RMI: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Administrativo - New One</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
    <style>
        body { font-family: var(--font-body); margin: 0; background: #fafafa; display: flex; height: 100vh; overflow: hidden; }

        .admin-sidebar {
            width: 270px;
            background: linear-gradient(180deg, #111827 0%, #030712 100%);
            color: var(--white);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }
        .admin-brand {
            padding: 24px;
            border-bottom: 1px solid rgba(255,255,255,0.06);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .admin-brand-icon {
            width: 42px; height: 42px;
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; color: #78350f; font-weight: 900;
        }
        .admin-brand h2 { margin: 0; font-size: 20px; font-weight: 800; }
        .admin-brand h2 span { color: #fbbf24; }
        .admin-brand-tag {
            display: inline-block;
            background: rgba(251,191,36,0.12);
            color: #fbbf24;
            padding: 2px 10px;
            border-radius: 20px;
            font-size: 9px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
        }

        .admin-nav { flex: 1; padding: 16px 12px; overflow-y: auto; }
        .admin-nav-label {
            font-size: 10px; font-weight: 700; text-transform: uppercase;
            letter-spacing: 1.5px; color: rgba(255,255,255,0.2); padding: 18px 12px 8px;
        }
        .admin-nav-link {
            display: flex; align-items: center; padding: 11px 16px;
            color: rgba(255,255,255,0.45); text-decoration: none;
            transition: all 0.2s; cursor: pointer;
            border-radius: var(--radius-sm); margin-bottom: 2px;
            font-size: 14px; font-weight: 500; gap: 12px;
        }
        .admin-nav-link:hover { background: rgba(255,255,255,0.05); color: rgba(255,255,255,0.85); }
        .admin-nav-link.active { background: rgba(251,191,36,0.1); color: #fbbf24; }
        .admin-nav-link i { width: 20px; text-align: center; font-size: 15px; }

        .admin-footer {
            padding: 16px;
            border-top: 1px solid rgba(255,255,255,0.06);
            display: flex; align-items: center; gap: 12px;
        }
        .admin-avatar {
            width: 38px; height: 38px;
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-weight: 800; color: #78350f; font-size: 15px; flex-shrink: 0;
        }
        .admin-footer-info { flex: 1; overflow: hidden; }
        .admin-footer-name { font-weight: 600; font-size: 13px; }
        .admin-footer-role { font-size: 11px; color: rgba(255,255,255,0.35); }
        .admin-logout { color: rgba(255,255,255,0.25); transition: color 0.2s; text-decoration: none; padding: 8px; }
        .admin-logout:hover { color: #ef4444; }

        .admin-main { flex: 1; overflow-y: auto; padding: 0; position: relative; }
        .admin-section { display: none; padding: 32px; animation: fadeIn 0.3s ease-out; }
        .admin-section.active { display: block; }
        .section { display: none; padding: 32px; animation: fadeIn 0.3s ease-out; }
        .section.active { display: block; }

        .admin-page-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px;
        }
        .admin-page-header h1 { font-size: 26px; margin: 0; color: #111827; }
        .admin-page-header p { color: var(--gray-600); font-size: 14px; margin: 4px 0 0; }

        .admin-metric-card {
            background: var(--white); padding: 24px; border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm); border: 1px solid rgba(0,0,0,0.04);
            display: flex; align-items: center; justify-content: space-between;
            transition: all 0.2s; position: relative; overflow: hidden;
        }
        .admin-metric-card::before {
            content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px;
            border-radius: 0 4px 4px 0;
        }
        .admin-metric-card.gold::before { background: linear-gradient(180deg, #fbbf24, #f59e0b); }
        .admin-metric-card.emerald::before { background: linear-gradient(180deg, #34d399, #059669); }
        .admin-metric-card.blue::before { background: linear-gradient(180deg, #60a5fa, #2563eb); }
        .admin-metric-card.purple::before { background: linear-gradient(180deg, #a78bfa, #7c3aed); }
        .admin-metric-card.rose::before { background: linear-gradient(180deg, #fb7185, #e11d48); }
        .admin-metric-card:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); }
        .admin-metric-val { font-size: 30px; font-weight: 800; color: #111827; }
        .admin-metric-lbl { color: var(--gray-600); font-size: 13px; font-weight: 500; margin-top: 2px; }
        .admin-metric-icon { font-size: 28px; color: var(--gray-300); }
    </style>
</head>
<body>

    <div class="admin-sidebar">
        <div class="admin-brand">
            <div class="admin-brand-icon"><i class="fas fa-crown"></i></div>
            <div>
                <h2>New<span>One</span></h2>
                <div class="admin-brand-tag">Administrador</div>
            </div>
        </div>
        <nav class="admin-nav">
            <div class="admin-nav-label">Panel Ejecutivo</div>
            <a class="admin-nav-link active" onclick="adminShowSection('dashboard')" data-section="dashboard">
                <i class="fas fa-chart-line"></i> Dashboard
            </a>
            <a class="admin-nav-link" onclick="adminShowSection('reportes')" data-section="reportes">
                <i class="fas fa-file-invoice-dollar"></i> Reportes
            </a>
            
            <div class="admin-nav-label">Administraci&oacute;n</div>
            <a class="admin-nav-link" onclick="adminShowSection('employees')" data-section="employees">
                <i class="fas fa-user-tie"></i> Personal
            </a>
            <a class="admin-nav-link" onclick="adminShowSection('products')" data-section="products">
                <i class="fas fa-box-open"></i> Productos
            </a>
            
            <div class="admin-nav-label">Comunicaci&oacute;n</div>
            <a class="admin-nav-link" onclick="adminShowSection('chat')" data-section="chat">
                <i class="fas fa-comments"></i> Chat Interno
            </a>
        </nav>
        <div class="admin-footer">
            <div class="admin-avatar"><%= usuario.getNombreCompleto().substring(0,1) %></div>
            <div class="admin-footer-info">
                <div class="admin-footer-name"><%= usuario.getNombreCompleto() %></div>
                <div class="admin-footer-role">Administrador General</div>
            </div>
            <a href="index.jsp" class="admin-logout" title="Cerrar Sesi&oacute;n"><i class="fas fa-sign-out-alt"></i></a>
        </div>
    </div>

    <div class="admin-main">
        
        <div id="adminNotification" class="notification">
            <strong id="adminNotificationMsg">Operaci&oacute;n Exitosa</strong>
        </div>

        <!-- DASHBOARD ADMIN -->
        <section id="dashboard" class="admin-section active">
            <div class="container">
                <div class="admin-page-header">
                    <div>
                        <h1>Panel Ejecutivo</h1>
                        <p>Resumen general del negocio - New One</p>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <a href="ReporteServlet" class="btn btn-outline btn-sm">
                            <i class="fas fa-file-excel"></i> Reporte Excel
                        </a>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 30px;">
                    <div class="admin-metric-card gold">
                        <div>
                            <div class="admin-metric-val"><%= pedidosHoy %></div>
                            <div class="admin-metric-lbl">Pedidos Hoy</div>
                        </div>
                        <div class="admin-metric-icon"><i class="fas fa-shopping-bag"></i></div>
                    </div>
                    <div class="admin-metric-card emerald">
                        <div>
                            <div class="admin-metric-val">S/ <%= String.format("%.2f", ingresosMes) %></div>
                            <div class="admin-metric-lbl">Ingresos del Mes</div>
                        </div>
                        <div class="admin-metric-icon"><i class="fas fa-chart-line"></i></div>
                    </div>
                    <div class="admin-metric-card blue">
                        <div>
                            <div class="admin-metric-val"><%= clientesActivos %></div>
                            <div class="admin-metric-lbl">Clientes Activos</div>
                        </div>
                        <div class="admin-metric-icon"><i class="fas fa-users"></i></div>
                    </div>
                    <div class="admin-metric-card purple">
                        <div>
                            <div class="admin-metric-val"><%= enProceso %></div>
                            <div class="admin-metric-lbl">En Proceso</div>
                        </div>
                        <div class="admin-metric-icon"><i class="fas fa-spinner"></i></div>
                    </div>
                    <div class="admin-metric-card rose">
                        <div>
                            <div class="admin-metric-val"><%= citasPendientes %></div>
                            <div class="admin-metric-lbl">Citas Pendientes</div>
                        </div>
                        <div class="admin-metric-icon"><i class="fas fa-calendar-check"></i></div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-signal" style="color: #22c55e;"></i> Estado del Negocio</h3>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 0;">
                        <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--gray-100);">
                            <div style="display: flex; align-items: center; gap: 10px; font-size: 14px;">
                                <span class="status-dot" style="background: #22c55e;"></span> En Proceso
                            </div>
                            <strong><%= enProceso %></strong>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--gray-100);">
                            <div style="display: flex; align-items: center; gap: 10px; font-size: 14px;">
                                <span class="status-dot" style="background: #60a5fa;"></span> Terminados
                            </div>
                            <strong><%= terminados %></strong>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--gray-100);">
                            <div style="display: flex; align-items: center; gap: 10px; font-size: 14px;">
                                <span class="status-dot" style="background: #f59e0b;"></span> Citas Pendientes
                            </div>
                            <strong><%= citasPendientes %></strong>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 0;">
                            <div style="display: flex; align-items: center; gap: 10px; font-size: 14px;">
                                <span class="status-dot" style="background: #a78bfa;"></span> Total Clientes
                            </div>
                            <strong><%= clientesActivos %></strong>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- REPORTES -->
        <section id="reportes" class="admin-section">
            <div class="container">
                <div class="admin-page-header">
                    <div>
                        <h1>Reportes y An&aacute;lisis</h1>
                        <p>Genera reportes del negocio.</p>
                    </div>
                </div>
                <div class="card">
                    <div class="card-header"><h3>Reporte de Pedidos</h3></div>
                    <div style="padding: 20px; text-align: center;">
                        <a href="ReporteServlet" class="btn btn-primary btn-lg">
                            <i class="fas fa-file-excel"></i> Descargar Reporte de Pedidos (Excel)
                        </a>
                        <p style="color: var(--gray-600); margin-top: 12px; font-size: 14px;">Incluye todos los pedidos, estados, montos y fechas.</p>
                    </div>
                </div>
            </div>
        </section>



        <!-- CHAT ADMIN -->
        <section id="chat" class="admin-section">
            <div class="container">
                <div class="admin-page-header">
                    <div>
                        <h1>Comunicaci&oacute;n Interna</h1>
                        <p>Chat en tiempo real con empleados y repartidores.</p>
                    </div>
                </div>
                <jsp:include page="views/section_chat.jsp" />
            </div>
        </section>

        <jsp:include page="views/section_employees.jsp" />
        <jsp:include page="views/section_clients.jsp" />
        <jsp:include page="views/section_products.jsp" />

    </div>

    <script src="js/admin-logic.js"></script>
    <script>
        function adminShowSection(sectionId, mode) {
            document.querySelectorAll('.admin-section, .section').forEach(s => s.classList.remove('active'));
            document.querySelectorAll('.admin-nav-link').forEach(l => l.classList.remove('active'));
            var t = document.getElementById(sectionId);
            if (t) t.classList.add('active');
            var l = document.querySelector('[data-section="'+sectionId+'"]');
            if (l) l.classList.add('active');
            
            if (sectionId === 'chat') {
                initChat();
            }
        }
        
        function showSection(sectionId, mode) {
            adminShowSection(sectionId, mode);
        }
    </script>
</body>
</html>
