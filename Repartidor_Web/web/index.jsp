

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionProductosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry" %>
<%@ page import="java.rmi.registry.Registry" %>
<%@ page import="entidades.Productos" %>
<%@ page import="java.util.List, java.util.ArrayList" %>

<%
    List<Productos> productosPublicos = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
        List<Productos> todosActivos = productoRMI.listarProductosActivos();
        
        int limite = Math.min(8, todosActivos.size());
        productosPublicos = todosActivos.subList(0, limite);
    } catch(Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New One - Limpieza y Restauraci&oacute;n</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
    <style>
        /* ============ LANDING PAGE ============ */
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
            transition: all 0.3s;
        }
        .navbar.scrolled { box-shadow: var(--shadow-md); }
        .logo { font-size: 26px; font-weight: 800; color: var(--dark); text-decoration: none; letter-spacing: -0.5px; }
        .logo span { color: var(--aqua); }
        .nav-links { display: flex; gap: 28px; align-items: center; }
        .nav-links a { text-decoration: none; color: var(--gray-700); font-weight: 500; font-size: 14px; transition: color 0.3s; position: relative; }
        .nav-links a::after { content: ''; position: absolute; bottom: -4px; left: 0; width: 0; height: 2px; background: var(--aqua); transition: width 0.3s; }
        .nav-links a:hover { color: var(--dark); }
        .nav-links a:hover::after { width: 100%; }
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
        .btn-nav::after { display: none !important; }

        /* HERO */
        .hero {
            min-height: 90vh;
            background: linear-gradient(135deg, rgba(26,29,35,0.85) 0%, rgba(45,49,57,0.75) 100%),
                        url('https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80');
            background-size: cover; background-position: center;
            display: flex; align-items: center; justify-content: center;
            text-align: center; color: var(--white);
            position: relative; overflow: hidden;
        }
        .hero::before {
            content: '';
            position: absolute;
            bottom: -50%; right: -20%;
            width: 600px; height: 600px;
            background: radial-gradient(circle, rgba(64,224,208,0.15) 0%, transparent 70%);
            border-radius: 50%;
        }
        .hero-content { position: relative; z-index: 1; max-width: 700px; padding: 0 20px; }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(64,224,208,0.15);
            border: 1px solid rgba(64,224,208,0.3);
            color: var(--aqua);
            padding: 8px 20px;
            border-radius: var(--radius-full);
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 24px;
            backdrop-filter: blur(10px);
        }
        .hero h1 {
            font-family: var(--font-display);
            font-size: 56px;
            font-weight: 700;
            margin-bottom: 20px;
            letter-spacing: -1px;
            line-height: 1.15;
        }
        .hero p { font-size: 18px; opacity: 0.85; margin-bottom: 36px; max-width: 520px; margin-left: auto; margin-right: auto; line-height: 1.7; }
        .btn-hero {
            display: inline-flex; align-items: center; gap: 10px;
            background: var(--aqua-gradient);
            color: var(--dark);
            padding: 16px 40px;
            border-radius: var(--radius-full);
            font-weight: 700;
            font-size: 16px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all 0.3s;
            box-shadow: var(--shadow-aqua);
        }
        .btn-hero:hover { transform: translateY(-3px); box-shadow: 0 8px 32px rgba(64,224,208,0.4); }

        /* SECTIONS */
        .section-padding { padding: 100px 60px; }
        .section-header { text-align: center; margin-bottom: 60px; }
        .section-header .overline {
            display: inline-block;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 3px;
            color: var(--aqua);
            margin-bottom: 12px;
        }
        .section-header h2 { font-family: var(--font-display); font-size: 42px; color: var(--dark); margin-bottom: 16px; }
        .section-header p { color: var(--gray-600); font-size: 17px; max-width: 500px; margin: 0 auto; }

        /* SERVICES */
        .services-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 28px; }
        .service-card {
            background: var(--white);
            padding: 44px 36px;
            border-radius: var(--radius-xl);
            text-align: center;
            box-shadow: var(--shadow-sm);
            border: 1px solid rgba(0,0,0,0.04);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        .service-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            background: var(--aqua-gradient);
            opacity: 0;
            transition: opacity 0.3s;
        }
        .service-card:hover { transform: translateY(-8px); box-shadow: var(--shadow-lg); }
        .service-card:hover::before { opacity: 1; }
        .service-icon {
            width: 72px; height: 72px;
            background: var(--aqua-glow);
            border-radius: var(--radius-lg);
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 24px;
            font-size: 28px;
            color: var(--aqua-dark);
            transition: all 0.3s;
        }
        .service-card:hover .service-icon { background: var(--aqua-gradient); color: var(--dark); transform: scale(1.05); }
        .service-card h3 { font-size: 20px; margin-bottom: 12px; }
        .service-card p { color: var(--gray-600); font-size: 14px; line-height: 1.7; margin-bottom: 20px; }
        .btn-service {
            display: inline-flex; align-items: center; gap: 8px;
            color: var(--aqua-dark);
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s;
        }
        .btn-service i { transition: transform 0.3s; }
        .btn-service:hover { color: var(--dark); }
        .btn-service:hover i { transform: translateX(4px); }

        /* SHOP */
        .shop-bg { background: var(--gray-50); }
        .shop-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 28px; }
        .product-card-public {
            background: var(--white);
            border-radius: var(--radius-xl);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            border: 1px solid rgba(0,0,0,0.04);
            transition: all 0.4s;
        }
        .product-card-public:hover { transform: translateY(-6px); box-shadow: var(--shadow-lg); }
        .product-image {
            height: 230px;
            background: var(--gray-50);
            display: flex; align-items: center; justify-content: center;
            overflow: hidden;
            border-bottom: 1px solid var(--gray-200);
        }
        .product-image img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s; }
        .product-card-public:hover .product-image img { transform: scale(1.05); }
        .product-details { padding: 24px; text-align: center; }
        .product-details h3 { font-size: 17px; margin-bottom: 8px; }
        .product-details .price {
            font-size: 22px; font-weight: 800; color: var(--aqua-dark);
            display: block; margin-bottom: 16px;
        }
        .btn-buy {
            display: inline-flex; align-items: center; gap: 8px;
            background: var(--dark);
            color: var(--white);
            padding: 11px 28px;
            border-radius: var(--radius-full);
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s;
        }
        .btn-buy:hover { background: var(--aqua-gradient); color: var(--dark); box-shadow: var(--shadow-aqua); transform: translateY(-2px); }

        /* FOOTER LANDING */
        footer.landing-footer {
            background: var(--dark);
            color: var(--white);
            padding: 60px;
            text-align: center;
        }
        footer.landing-footer .footer-logo { font-size: 28px; font-weight: 800; margin-bottom: 20px; }
        footer.landing-footer .footer-logo span { color: var(--aqua); }
        .social-links { margin-bottom: 24px; display: flex; gap: 16px; justify-content: center; }
        .social-links a {
            width: 44px; height: 44px;
            background: rgba(255,255,255,0.08);
            border-radius: var(--radius-sm);
            display: flex; align-items: center; justify-content: center;
            color: var(--white);
            font-size: 18px;
            transition: all 0.3s;
        }
        .social-links a:hover { background: var(--aqua); color: var(--dark); transform: translateY(-3px); }

        @media (max-width: 768px) {
            .navbar { padding: 14px 20px; }
            .section-padding { padding: 60px 20px; }
            .hero h1 { font-size: 36px; }
            .section-header h2 { font-size: 30px; }
        }
    </style>
</head>
<body>

    <nav class="navbar" id="mainNav">
        <a href="#" class="logo">New<span>One</span> <span style="font-size: 14px; font-weight: 500; color: var(--gray-500); margin-left: 8px;">Portal Repartidor</span></a>
        <div class="nav-links">
            <a href="auth.jsp" class="btn-nav">Ingresar al Sistema</a>
        </div>
    </nav>

    <header id="inicio" class="hero">
        <div class="hero-content">
            <div class="hero-badge">
                <i class="fas fa-motorcycle"></i> App de Delivery
            </div>
            <h1>Portal de Repartidores</h1>
            <p>Gestiona tus entregas, revisa tus rutas y mant&eacute;n el control de tus despachos en tiempo real.</p>
            <a href="auth.jsp" class="btn-hero">
                Ingresar al Sistema <i class="fas fa-right-to-bracket"></i>
            </a>
        </div>
    </header>

    <footer id="contacto" class="landing-footer">
        <div class="footer-logo">New<span>One</span></div>
        <div class="social-links">
            <a href="#"><i class="fab fa-facebook-f"></i></a>
            <a href="#"><i class="fab fa-instagram"></i></a>
            <a href="#"><i class="fab fa-whatsapp"></i></a>
        </div>
        <p style="opacity: 0.7; font-size: 14px;">&copy; 2025 New One. Todos los derechos reservados.</p>
        <p style="font-size: 12px; opacity: 0.4; margin-top: 8px;">Chiclayo, Per&uacute;</p>
    </footer>

    <script>
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        });
        window.addEventListener('scroll', () => {
            document.getElementById('mainNav').classList.toggle('scrolled', window.scrollY > 50);
        });
    </script>
</body>
</html>