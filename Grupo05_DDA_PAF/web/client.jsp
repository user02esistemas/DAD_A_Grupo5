

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entidades.Clientes" %>
<%
    HttpSession sesion = request.getSession();
    Clientes cliente = (Clientes) sesion.getAttribute("cliente");
    
    if (cliente == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Cuenta - New One</title>
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
        .sidebar-brand { padding: 24px; border-bottom: 1px solid rgba(255,255,255,0.06); display: flex; justify-content: space-between; align-items: center; }
        .sidebar-brand h2 { margin: 0; font-size: 22px; font-weight: 800; color: var(--white); }
        .sidebar-brand h2 span { color: var(--aqua); }

        .notif-bell-btn {
            position: relative;
            background: rgba(255,255,255,0.06);
            border: none;
            color: rgba(255,255,255,0.6);
            width: 40px; height: 40px;
            border-radius: var(--radius-sm);
            cursor: pointer;
            font-size: 16px;
            display: flex; align-items: center; justify-content: center;
            transition: all 0.2s;
        }
        .notif-bell-btn:hover { background: rgba(255,255,255,0.12); color: var(--white); }
        .notif-bell-btn .notif-badge {
            position: absolute;
            top: 4px; right: 4px;
            background: var(--danger);
            color: white;
            font-size: 9px;
            font-weight: 800;
            min-width: 16px; height: 16px;
            border-radius: 8px;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
            border: 2px solid var(--dark);
        }

        .ws-status {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 8px 24px;
            border-bottom: 1px solid rgba(255,255,255,0.06);
            font-size: 11px;
            color: rgba(255,255,255,0.4);
        }
        .ws-dot {
            width: 6px; height: 6px;
            border-radius: 50%;
            transition: background 0.3s;
        }
        .ws-dot.connected { background: var(--success); box-shadow: 0 0 6px var(--success); }
        .ws-dot.disconnected { background: var(--danger); box-shadow: 0 0 6px var(--danger); }

        .client-profile { padding: 24px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.06); }
        .avatar {
            width: 64px; height: 64px;
            background: var(--aqua-gradient);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 24px; font-weight: 700;
            color: var(--dark);
            margin: 0 auto 12px;
        }
        .client-name { font-weight: 600; font-size: 15px; }
        .client-role { font-size: 12px; color: rgba(255,255,255,0.4); margin-top: 2px; }

        .nav-menu { flex: 1; padding: 16px 12px; overflow-y: auto; }
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
        .nav-link.active { background: rgba(64,224,208,0.12); color: var(--aqua); }
        .nav-link i { width: 20px; text-align: center; font-size: 15px; }
        .nav-link.logout-link { margin-top: auto; border-top: 1px solid rgba(255,255,255,0.06); padding-top: 14px; }

        .main-content { flex: 1; overflow-y: auto; position: relative; }
        .container { padding: 32px; max-width: 1200px; margin: 0 auto; }

        .section { display: none; animation: fadeIn 0.3s ease; }
        .section.active { display: block; }

        .page-header { margin-bottom: 28px; display: flex; justify-content: space-between; align-items: flex-start; }
        .page-header h1 { font-size: 26px; margin: 0; }
        .page-header p { color: var(--gray-600); font-size: 14px; margin: 4px 0 0; }

        /* ========== PANEL DE NOTIFICACIONES ========== */
        .notif-panel {
            position: fixed;
            top: 0; right: -400px;
            width: 380px;
            height: 100vh;
            background: var(--white);
            box-shadow: -4px 0 24px rgba(0,0,0,0.12);
            z-index: 5000;
            display: flex;
            flex-direction: column;
            transition: right 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            border-left: 1px solid var(--gray-200);
        }
        .notif-panel.open { right: 0; }
        .notif-panel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 24px;
            border-bottom: 1px solid var(--gray-200);
            background: var(--gray-50);
        }
        .notif-panel-header h3 { margin: 0; font-size: 16px; color: var(--dark); }
        .notif-panel-actions { display: flex; gap: 8px; }
        .notif-panel-actions button {
            background: none; border: none; color: var(--gray-500);
            font-size: 12px; cursor: pointer; padding: 4px 8px;
            border-radius: var(--radius-sm);
            transition: all 0.2s;
        }
        .notif-panel-actions button:hover { background: var(--gray-100); color: var(--dark); }
        .notif-panel-close {
            background: var(--gray-100) !important;
            color: var(--gray-600) !important;
            width: 32px; height: 32px;
            display: flex; align-items: center; justify-content: center;
            border-radius: var(--radius-sm);
            font-size: 16px;
        }

        .notif-panel-list {
            flex: 1;
            overflow-y: auto;
            padding: 8px;
        }
        .notif-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 14px 16px;
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: background 0.2s;
            border: 1px solid transparent;
        }
        .notif-item:hover { background: var(--gray-50); }
        .notif-item.no-leida { background: var(--aqua-glow); border-color: rgba(64,224,208,0.15); }
        .notif-item.no-leida::before {
            content: '';
            position: absolute;
            left: 4px; top: 50%;
            transform: translateY(-50%);
            width: 6px; height: 6px;
            background: var(--aqua);
            border-radius: 50%;
        }
        .notif-item { position: relative; }
        .notif-icon {
            width: 36px; height: 36px;
            border-radius: var(--radius-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
        }
        .notif-content { flex: 1; min-width: 0; }
        .notif-mensaje { font-size: 13px; color: var(--dark); line-height: 1.4; font-weight: 500; }
        .notif-tiempo { font-size: 11px; color: var(--gray-500); margin-top: 3px; }
        .notif-pedido-tag {
            display: inline-block;
            background: var(--info-bg);
            color: var(--info);
            font-size: 10px;
            font-weight: 700;
            padding: 1px 6px;
            border-radius: 4px;
            margin-left: 4px;
        }
        .notif-empty {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 200px;
            color: var(--gray-400);
        }
        .notif-empty i { font-size: 32px; margin-bottom: 12px; }
        .notif-empty p { font-size: 13px; }

        /* Overlay */
        .notif-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.3);
            z-index: 4999;
            display: none;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .notif-overlay.open { display: block; opacity: 1; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-brand">
            <h2>New<span>One</span></h2>
            <button class="notif-bell-btn" onclick="toggleNotifPanel()" title="Notificaciones">
                <i class="fas fa-bell"></i>
                <span class="notif-badge" id="notifBadge">0</span>
            </button>
        </div>
        <div class="ws-status">
            <span class="ws-dot disconnected" id="wsStatusDot"></span>
            <span id="wsStatusLabel">Conectando...</span>
        </div>
        <div class="client-profile">
            <div class="avatar"><%= cliente.getNombreCompleto().substring(0,1) %></div>
            <div class="client-name"><%= cliente.getNombreCompleto() %></div>
            <div class="client-role">Cliente</div>
        </div>
        
        <nav class="nav-menu">
            <a class="nav-link active" onclick="showView('dashboard')" data-view="dashboard">
                <i class="fas fa-th-large"></i> Inicio
            </a>
            <a class="nav-link" onclick="showView('schedule')" data-view="schedule">
                <i class="fas fa-calendar-plus"></i> Agendar Servicio
            </a>
            <a class="nav-link" onclick="showView('store')" data-view="store">
                <i class="fas fa-shopping-bag"></i> Tienda
            </a>
            <a class="nav-link" onclick="showView('orders')" data-view="orders">
                <i class="fas fa-receipt"></i> Mis Pedidos
            </a>
            <a class="nav-link" onclick="showView('profile')" data-view="profile">
                <i class="fas fa-user-cog"></i> Mi Perfil
            </a>
            <a href="index.jsp" class="nav-link logout-link">
                <i class="fas fa-sign-out-alt"></i> Salir
            </a>
        </nav>
    </div>

    <main class="main-content">
        <jsp:include page="views/client_dashboard.jsp" />
        <jsp:include page="views/client_schedule.jsp" />
        <jsp:include page="views/client_store.jsp" />
        <jsp:include page="views/client_orders.jsp" />
        <jsp:include page="views/client_profile.jsp" />
    </main>

    <div id="notification" class="notification">
        <span id="notificationMessage" style="font-weight: 600;"></span>
    </div>

    <div class="notif-overlay" id="notifOverlay" onclick="toggleNotifPanel()"></div>
    <div class="notif-panel" id="notifPanel">
        <div class="notif-panel-header">
            <h3><i class="fas fa-bell" style="color: var(--aqua); margin-right: 8px;"></i>Notificaciones</h3>
            <div class="notif-panel-actions">
                <button onclick="limpiarNotificaciones()" title="Limpiar todo"><i class="fas fa-trash-alt"></i> Limpiar</button>
                <button class="notif-panel-close" onclick="toggleNotifPanel()"><i class="fas fa-times"></i></button>
            </div>
        </div>
        <div class="notif-panel-list" id="notifList">
            <div class="notif-empty"><i class="fas fa-bell-slash"></i><p>Sin notificaciones</p></div>
        </div>
    </div>

    <script src="js/client-logic.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            var idCliente = '<%= cliente.getIdCliente() %>';
            if (typeof initWebSocket === 'function') {
                initWebSocket(idCliente);
            }
        });
    </script>
</body>
</html>