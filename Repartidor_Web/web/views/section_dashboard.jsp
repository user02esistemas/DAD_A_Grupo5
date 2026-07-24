<%-- 
    Document   : section_dashboard
    Created on : 4 dic. 2025, 21:39:16
    Author     : Grupo_05
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.persistence.*, conexión.connectionDrive" %>
<%@ page import="java.math.BigDecimal" %>

<%
    long pedidosHoy = 0;
    BigDecimal ingresosMes = BigDecimal.ZERO;
    long clientesActivos = 0;
    long enProceso = 0;
    long terminados = 0;
    long citasPendientes = 0;

    EntityManager emDash = connectionDrive.getEntityManager();
    
    try {
        Query q1 = emDash.createNativeQuery("SELECT COUNT(*) FROM Pedidos WHERE CAST(fecha_recepcion AS DATE) = CAST(GETDATE() AS DATE)");
        pedidosHoy = ((Number) q1.getSingleResult()).longValue();

        Query q2 = emDash.createNativeQuery("SELECT ISNULL(SUM(monto_total), 0) FROM Pedidos WHERE MONTH(fecha_recepcion) = MONTH(GETDATE()) AND YEAR(fecha_recepcion) = YEAR(GETDATE())");
        Object resultadoIngreso = q2.getSingleResult();
        if (resultadoIngreso != null) {
            ingresosMes = new BigDecimal(resultadoIngreso.toString());
        }

        clientesActivos = (long) emDash.createQuery("SELECT COUNT(c) FROM Clientes c").getSingleResult();

        enProceso = (long) emDash.createQuery("SELECT COUNT(p) FROM Pedidos p WHERE p.estado NOT IN ('Terminado', 'Entregado', 'Cancelado')").getSingleResult();
        terminados = (long) emDash.createQuery("SELECT COUNT(p) FROM Pedidos p WHERE p.estado = 'Terminado'").getSingleResult();
        
        citasPendientes = (long) emDash.createQuery("SELECT COUNT(c) FROM Citas c WHERE c.estado = 'Pendiente'").getSingleResult();

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(emDash != null && emDash.isOpen()) emDash.close();
    }
%>

<section id="dashboard" class="section active">
    <div class="container">
        
        <div class="card-header" style="border:none; padding:0; margin-bottom: 20px;">
            <h2>Resumen del Negocio</h2>
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-value"><%= pedidosHoy %></div>
                <div class="metric-label">Pedidos Hoy</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">S/ <%= String.format("%.2f", ingresosMes) %></div>
                <div class="metric-label">Ingresos Mes</div>
            </div>
            <div class="metric-card">
                <div class="metric-value"><%= clientesActivos %></div>
                <div class="metric-label">Clientes Activos</div>
            </div>
            <div class="metric-card">
                <div class="metric-value"><%= citasPendientes %></div>
                <div class="metric-label">Citas Pendientes</div>
            </div>
        </div>

        <div class="dashboard-grid">
            
            <div class="card">
                <div class="card-header"><h3 class="card-title">Acciones Rápidas</h3></div>
                <div style="display: grid; gap: 12px;">
                    <button class="btn btn-primary" onclick="showSection('appointment', 'store')">
                        <i class="fas fa-store"></i> Atención en Tienda
                    </button>
                    <button class="btn" style="background: #fff3cd; color:#856404;" onclick="showSection('appointment', 'reservation')">
                        <i class="fas fa-calendar-check"></i> Reservar Cita
                    </button>
                    <button class="btn" style="background: #d1ecf1; color:#0c5460;" onclick="showSection('appointment', 'delivery')">
                        <i class="fas fa-motorcycle"></i> Programar Delivery
                    </button>
                    
                    <hr style="border:0; border-top:1px solid #eee; margin: 5px 0;">
                    
                    <a href="ReporteServlet" class="btn btn-secondary" style="text-align: center; text-decoration: none; display: block; line-height: 20px;">
                        <i class="fas fa-file-excel"></i> Descargar Reporte (Excel)
                    </a>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header"><h3 class="card-title">Estado del Día</h3></div>
                <div style="line-height: 2.5; font-size: 14px;">
                    <div style="display: flex; justify-content: space-between; border-bottom: 1px solid #f8f9fa;">
                        <span><i class="fas fa-circle" style="color: #28a745; font-size: 10px;"></i> En Proceso (Activos)</span>
                        <strong><%= enProceso %></strong>
                    </div>
                    <div style="display: flex; justify-content: space-between; border-bottom: 1px solid #f8f9fa;">
                        <span><i class="fas fa-circle" style="color: #007bff; font-size: 10px;"></i> Terminados</span>
                        <strong><%= terminados %></strong>
                    </div>
                    <div style="display: flex; justify-content: space-between; border-bottom: 1px solid #f8f9fa;">
                        <span><i class="fas fa-circle" style="color: #ffc107; font-size: 10px;"></i> Citas Pendientes</span>
                        <strong><%= citasPendientes %></strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span><i class="fas fa-users" style="color: #6c757d; font-size: 10px;"></i> Total Clientes</span>
                        <strong><%= clientesActivos %></strong>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</section>
