

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
        e.printStackTrace();
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
        body { font-family: var(--font-body); margin: 0; background: var(--gray-50); display: flex; height: 100vh; overflow: hidden; }

        .sidebar {
            width: 260px;
            background: var(--dark);
            color: var(--white);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }
        .sidebar-brand {
            padding: 24px;
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        .sidebar-brand h2 { margin: 0; font-size: 22px; font-weight: 800; color: var(--white); }
        .sidebar-brand h2 span { color: var(--aqua); }

        .nav-menu { flex: 1; padding: 16px 12px; overflow-y: auto; }
        .nav-section-label {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: rgba(255,255,255,0.3);
            padding: 16px 12px 8px;
        }
        .nav-link {
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
        .nav-link:hover { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.9); }
        .nav-link.active {
            background: rgba(64,224,208,0.12);
            color: var(--aqua);
        }
        .nav-link i { width: 20px; text-align: center; font-size: 15px; }

        .sidebar-footer {
            padding: 16px;
            border-top: 1px solid rgba(255,255,255,0.06);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .user-avatar {
            width: 36px; height: 36px;
            background: var(--aqua-gradient);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700;
            color: var(--dark);
            font-size: 14px;
            flex-shrink: 0;
        }
        .user-info { flex: 1; overflow: hidden; }
        .user-name { font-weight: 600; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .user-role { font-size: 11px; color: rgba(255,255,255,0.4); }
        .btn-logout {
            color: rgba(255,255,255,0.3);
            transition: color 0.2s;
            text-decoration: none;
            padding: 8px;
        }
        .btn-logout:hover { color: var(--danger); }

        .main-content { flex: 1; overflow-y: auto; padding: 0; position: relative; }
        .section { display: none; padding: 32px; animation: fadeIn 0.3s ease-out; }
        .section.active { display: block; }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
        }
        .page-header h1 { font-size: 26px; margin: 0; }
        .page-header p { color: var(--gray-600); font-size: 14px; margin: 4px 0 0; }

        .quick-actions { display: grid; gap: 10px; }
        .quick-action-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 18px;
            background: var(--gray-50);
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all var(--transition-base);
            font-family: var(--font-body);
            font-size: 14px;
            font-weight: 500;
            color: var(--dark);
            text-align: left;
        }
        .quick-action-btn:hover { border-color: var(--aqua); background: var(--aqua-glow); }
        .quick-action-btn i { color: var(--aqua-dark); width: 20px; text-align: center; }

        .status-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid var(--gray-100);
        }
        .status-row:last-child { border-bottom: none; }
        .status-label { display: flex; align-items: center; gap: 10px; font-size: 14px; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-brand">
            <h2>New<span>One</span></h2>
        </div>
        <nav class="nav-menu">
            <div class="nav-section-label">Principal</div>
            <a class="nav-link active" onclick="showSection('dashboard')" data-section="dashboard">
                <i class="fas fa-th-large"></i> Dashboard
            </a>
            
            <div class="nav-section-label">Gesti&oacute;n</div>
            <a class="nav-link" onclick="showSection('appointment')" data-section="appointment">
                <i class="fas fa-plus-circle"></i> Nuevo Pedido
            </a>
            <a class="nav-link" onclick="showSection('tracking')" data-section="tracking">
                <i class="fas fa-route"></i> Seguimiento
            </a>
            
            <div class="nav-section-label">Administrar</div>
            <a class="nav-link" onclick="showSection('clients')" data-section="clients">
                <i class="fas fa-users"></i> Clientes
            </a>
            <a class="nav-link" onclick="showSection('employees')" data-section="employees">
                <i class="fas fa-user-tie"></i> Empleados
            </a>
            <a class="nav-link" onclick="showSection('products')" data-section="products">
                <i class="fas fa-box-open"></i> Productos
            </a>
        </nav>
        <div class="sidebar-footer">
            <div class="user-avatar"><%= usuario.getNombreCompleto().substring(0,1) %></div>
            <div class="user-info">
                <div class="user-name"><%= usuario.getNombreCompleto() %></div>
                <div class="user-role">Administrador</div>
            </div>
            <a href="index.jsp" class="btn-logout" title="Cerrar Sesi&oacute;n"><i class="fas fa-sign-out-alt"></i></a>
        </div>
    </div>

    <div class="main-content">
        
        <div id="notification" class="notification">
            <strong id="notificationMessage">Operaci&oacute;n Exitosa</strong>
        </div>

        <section id="dashboard" class="section active">
            <div class="container">
                <div class="page-header">
                    <div>
                        <h1>Resumen del Negocio</h1>
                        <p>Vista general de la actividad de hoy.</p>
                    </div>
                </div>

                <div class="metrics-grid">
                    <div class="metric-card">
                        <div>
                            <div class="metric-value"><%= pedidosHoy %></div>
                            <div class="metric-label">Pedidos Hoy</div>
                        </div>
                        <div class="metric-icon"><i class="fas fa-shopping-bag"></i></div>
                    </div>
                    <div class="metric-card">
                        <div>
                            <div class="metric-value">S/ <%= String.format("%.2f", ingresosMes) %></div>
                            <div class="metric-label">Ingresos del Mes</div>
                        </div>
                        <div class="metric-icon"><i class="fas fa-chart-line"></i></div>
                    </div>
                    <div class="metric-card">
                        <div>
                            <div class="metric-value"><%= clientesActivos %></div>
                            <div class="metric-label">Clientes Activos</div>
                        </div>
                        <div class="metric-icon"><i class="fas fa-users"></i></div>
                    </div>
                    <div class="metric-card">
                        <div>
                            <div class="metric-value"><%= citasPendientes %></div>
                            <div class="metric-label">Citas Pendientes</div>
                        </div>
                        <div class="metric-icon"><i class="fas fa-calendar-check"></i></div>
                    </div>
                </div>

                <div class="dashboard-grid">
                    <div class="card">
                        <div class="card-header">
                            <h3>Acciones R&aacute;pidas</h3>
                        </div>
                        <div class="quick-actions">
                            <button class="quick-action-btn" onclick="showSection('appointment', 'store')">
                                <i class="fas fa-store"></i> Atenci&oacute;n en Tienda
                            </button>
                            <button class="quick-action-btn" onclick="showSection('appointment', 'reservation')">
                                <i class="fas fa-calendar-plus"></i> Reservar Cita
                            </button>
                            <button class="quick-action-btn" onclick="showSection('appointment', 'delivery')">
                                <i class="fas fa-motorcycle"></i> Programar Delivery
                            </button>
                            <a href="ReporteServlet" class="quick-action-btn" style="text-decoration: none;">
                                <i class="fas fa-file-excel"></i> Descargar Reporte (Excel)
                            </a>
                        </div>
                    </div>
                    
                    <div class="card">
                        <div class="card-header">
                            <h3>Estado del D&iacute;a</h3>
                        </div>
                        <div class="status-row">
                            <div class="status-label">
                                <span class="status-dot" style="background: var(--success);"></span>
                                En Proceso
                            </div>
                            <strong><%= enProceso %></strong>
                        </div>
                        <div class="status-row">
                            <div class="status-label">
                                <span class="status-dot" style="background: var(--info);"></span>
                                Terminados
                            </div>
                            <strong><%= terminados %></strong>
                        </div>
                        <div class="status-row">
                            <div class="status-label">
                                <span class="status-dot" style="background: var(--warning);"></span>
                                Citas Pendientes
                            </div>
                            <strong><%= citasPendientes %></strong>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <jsp:include page="views/section_appointment.jsp" />
        <jsp:include page="views/section_tracking.jsp" />
        <jsp:include page="views/section_employees.jsp" />
        <jsp:include page="views/section_clients.jsp" />
        <jsp:include page="views/section_products.jsp" />

    </div>

    <script src="js/admin-logic.js"></script>
</body>
</html>