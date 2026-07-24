<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionProductosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Productos" %>
<%@ page import="java.util.List, java.util.ArrayList" %>

<%
    List<Productos> prods = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
        List<Productos> todos = productoRMI.listarTodosProductos();
        for(Productos p : todos) {
            if(p.getEstado() != null && p.getEstado()) {
                prods.add(p);
            }
        }
    } catch(Exception e) { 
        System.out.println("Error en productos: " + e.getMessage());
    }
%>

<section id="products" class="section">
    <div class="container">
        <div class="page-header">
            <div>
                <h1>Gesti&oacute;n de Productos</h1>
                <p>Administra el inventario de la tienda.</p>
            </div>
            <button class="btn btn-primary" onclick="abrirModalProducto()">
                <i class="fas fa-box-open"></i> Nuevo Producto
            </button>
        </div>

        <div class="dashboard-grid">
            <% for(Productos p : prods) { %>
            <div class="card" style="display: flex; flex-direction: column; justify-content: space-between;">
                <div>
                    <div style="height: 140px; overflow: hidden; border-radius: var(--radius-md); margin-bottom: 14px; background: var(--gray-50); display: flex; align-items: center; justify-content: center;">
                        <% if(p.getImagenUrl() != null && !p.getImagenUrl().isEmpty()) { %>
                            <img src="<%= p.getImagenUrl() %>" style="width: 100%; height: 100%; object-fit: cover;">
                        <% } else { %>
                            <i class="fas fa-image" style="font-size: 40px; color: var(--gray-300);"></i>
                        <% } %>
                    </div>
                    <h4 style="margin: 0 0 6px 0; font-size: 17px;"><%= p.getNombre() %></h4>
                    <p style="color: var(--gray-600); font-size: 13px; margin: 0 0 12px 0; height: 36px; overflow: hidden; line-height: 1.5;">
                        <%= p.getDescripcion() != null ? p.getDescripcion() : "Sin descripci&oacute;n" %>
                    </p>
                </div>
                
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                        <span style="font-weight: 800; color: var(--aqua-dark); font-size: 20px;">S/ <%= p.getPrecio() %></span>
                        <span class="badge badge-dark">Stock: <%= p.getStock() %></span>
                    </div>
                    <div style="display: flex; gap: 8px;">
                        <button class="btn btn-outline btn-sm" style="flex: 1;" onclick="editarProducto(<%= p.getIdProducto() %>)">
                            <i class="fas fa-pen"></i> Editar
                        </button>
                        <button class="btn btn-danger btn-sm" style="flex: 1;" onclick="eliminarProducto(<%= p.getIdProducto() %>)">
                            <i class="fas fa-trash"></i> Eliminar
                        </button>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>
    
    <div id="modalProducto" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="modalProdTitle">Producto</h3>
                <button class="modal-close" onclick="document.getElementById('modalProducto').style.display='none'">&times;</button>
            </div>
            <div class="modal-body">
                <form id="formProducto" action="GestionServlet" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="accion" id="prodAccion" value="nuevo_producto">
                    <input type="hidden" name="idProducto" id="prodId">
                    <input type="hidden" id="prodImgUrl">
                    <div class="form-group">
                        <label class="form-label">Nombre</label>
                        <input type="text" name="nombre" id="prodNombre" class="form-input" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Descripci&oacute;n</label>
                        <textarea name="desc" id="prodDesc" class="form-input" rows="2"></textarea>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Precio (S/)</label>
                            <input type="number" name="precio" id="prodPrecio" class="form-input" required step="0.01" min="0">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Stock</label>
                            <input type="number" name="stock" id="prodStock" class="form-input" required min="0">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Imagen</label>
                        <div style="display: flex; align-items: center; gap: 12px;">
                            <img id="imgPreview" src="" style="width: 48px; height: 48px; border-radius: var(--radius-sm); object-fit: cover; border: 1px solid var(--gray-200);">
                            <input type="file" name="imagenFile" onchange="previewImage(this)" class="form-input" style="padding: 8px;">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">
                        <i class="fas fa-save"></i> Guardar
                    </button>
                </form>
            </div>
        </div>
    </div>
</section>