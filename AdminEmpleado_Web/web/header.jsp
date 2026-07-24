
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acceso - New One</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
    <style>
        body { background: var(--gray-50); min-height: 100vh; }
        .navbar {
            background: rgba(255,255,255,0.92);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            padding: 16px 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(0,0,0,0.04);
            position: sticky; top: 0; z-index: 1000;
        }
        .logo { font-size: 26px; font-weight: 800; color: var(--dark); text-decoration: none; letter-spacing: -0.5px; }
        .logo span { color: var(--aqua); }
        .nav-links { display: flex; gap: 28px; align-items: center; }
        .nav-links a { text-decoration: none; color: var(--gray-700); font-weight: 500; font-size: 14px; transition: color 0.3s; }
        .nav-links a:hover { color: var(--aqua-dark); }
        .btn-nav {
            background: var(--dark);
            color: var(--white) !important;
            padding: 10px 24px;
            border-radius: var(--radius-full);
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s;
        }
        .btn-nav:hover { background: var(--aqua); color: var(--dark) !important; box-shadow: var(--shadow-aqua); }
    </style>
</head>
<body>

    <nav class="navbar">
        <a href="index.jsp" class="logo">New<span>One</span> <span style="font-size: 14px; font-weight: 500; color: var(--gray-500); margin-left: 8px;">Portal Interno</span></a>
        <div class="nav-links">
            <a href="auth.jsp" class="btn-nav">Ingresar al Sistema</a>
        </div>
    </nav>