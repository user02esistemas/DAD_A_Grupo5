
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Interfaces.IGestionProductosRemoto" %>
<%@ page import="java.rmi.registry.LocateRegistry, java.rmi.registry.Registry" %>
<%@ page import="entidades.Productos" %>
<%@ page import="java.util.List, java.util.ArrayList" %>

<%
    List<Productos> productosPOS = new ArrayList<>();
    try {
        Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
        IGestionProductosRemoto productoRMI = (IGestionProductosRemoto) registry.lookup("productoServicio");
        List<Productos> todos = productoRMI.listarTodosProductos();
        for (Productos p : todos) {
            if (p.getEstado() != null && p.getEstado()) {
                productosPOS.add(p);
            }
        }
    } catch(Exception e) {}
%>

<style>
    .pos-layout { display: grid; grid-template-columns: 1fr 380px; gap: 24px; }
    
    .pos-products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
        gap: 14px;
    }
    .pos-product-card {
        background: var(--white);
        border-radius: var(--radius-md);
        border: 2px solid var(--gray-200);
        padding: 16px;
        text-align: center;
        cursor: pointer;
        transition: all 0.2s;
    }
    .pos-product-card:hover { border-color: #0f766e; transform: translateY(-2px); box-shadow: var(--shadow-md); }
    .pos-product-card.selected { border-color: #0f766e; background: #f0fdfa; }
    .pos-product-icon { font-size: 36px; color: #99f6e4; margin-bottom: 8px; }
    .pos-product-name { font-weight: 600; font-size: 14px; margin-bottom: 4px; }
    .pos-product-price { color: #0f766e; font-weight: 800; font-size: 18px; }
    .pos-product-stock { color: var(--gray-500); font-size: 11px; }

    .pos-cart {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
        border: 1px solid rgba(0,0,0,0.04);
        display: flex;
        flex-direction: column;
        height: 600px;
    }
    .pos-cart-header {
        padding: 20px;
        border-bottom: 1px solid var(--gray-200);
        background: var(--gray-50);
    }
    .pos-cart-header h3 { margin: 0; font-size: 18px; }
    .pos-cart-items { flex: 1; overflow-y: auto; padding: 16px; }
    .pos-cart-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px;
        background: var(--gray-50);
        border-radius: var(--radius-sm);
        margin-bottom: 10px;
    }
    .pos-cart-item-info { flex: 1; }
    .pos-cart-item-name { font-weight: 600; font-size: 14px; }
    .pos-cart-item-price { color: #0f766e; font-size: 13px; font-weight: 600; }
    .pos-cart-item-qty {
        display: flex; align-items: center; gap: 6px;
    }
    .pos-cart-item-qty button {
        width: 28px; height: 28px; border: 1px solid var(--gray-300);
        background: white; border-radius: 50%; cursor: pointer;
        display: flex; align-items: center; justify-content: center;
        font-size: 14px; font-weight: 700; transition: all 0.15s;
    }
    .pos-cart-item-qty button:hover { border-color: #0f766e; color: #0f766e; }
    .pos-cart-item-remove { color: #ef4444; cursor: pointer; font-size: 14px; padding: 4px; }
    .pos-cart-item-remove:hover { color: #dc2626; }

    .pos-cart-footer {
        padding: 20px;
        border-top: 2px solid var(--gray-200);
    }
    .pos-total-row {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 16px;
    }
    .pos-total-label { font-size: 14px; color: var(--gray-600); }
    .pos-total-amount { font-size: 32px; font-weight: 800; color: #0f766e; }

    .pos-payment-methods {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
        margin-bottom: 12px;
    }
    .pos-pay-btn {
        padding: 14px 12px;
        border: 2px solid var(--gray-200);
        border-radius: var(--radius-md);
        background: var(--white);
        cursor: pointer;
        text-align: center;
        transition: all 0.2s;
        font-family: var(--font-body);
    }
    .pos-pay-btn:hover { border-color: #0f766e; background: #f0fdfa; }
    .pos-pay-btn.active { border-color: #0f766e; background: #f0fdfa; box-shadow: 0 0 0 3px rgba(15,118,110,0.1); }
    .pos-pay-btn i { font-size: 24px; display: block; margin-bottom: 6px; }
    .pos-pay-btn span { font-size: 12px; font-weight: 600; }

    .pos-yape { color: #7c3aed; }
    .pos-contra { color: #ea580c; }
    .pos-transfer { color: #2563eb; }
    .pos-efectivo { color: #16a34a; }

    .pos-confirm-btn {
        width: 100%;
        padding: 16px;
        border: none;
        border-radius: var(--radius-md);
        font-family: var(--font-body);
        font-size: 16px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }
    .pos-confirm-btn:hover { transform: translateY(-1px); box-shadow: var(--shadow-md); }

    .pos-yape-qr {
        text-align: center;
        padding: 20px;
        background: #faf5ff;
        border-radius: var(--radius-md);
        border: 2px dashed #7c3aed;
        margin: 12px 0;
    }
    .pos-yape-qr i { font-size: 60px; color: #7c3aed; }
    .pos-yape-qr p { color: #7c3aed; font-weight: 600; margin-top: 8px; font-size: 14px; }
    .pos-yape-qr .yape-number { font-size: 20px; font-weight: 800; color: #7c3aed; letter-spacing: 2px; }

    .pos-transfer-info {
        padding: 16px;
        background: #eff6ff;
        border-radius: var(--radius-md);
        border: 1.5px solid #93c5fd;
        margin: 12px 0;
        font-size: 13px;
    }
    .pos-transfer-info strong { color: #1d4ed8; }
    .pos-transfer-info .bank-account { font-size: 18px; font-weight: 800; color: #1e40af; letter-spacing: 1px; margin: 8px 0; }

    .pos-success-overlay {
        position: fixed; inset: 0;
        background: rgba(0,0,0,0.6);
        backdrop-filter: blur(6px);
        z-index: 3000;
        display: none;
        justify-content: center;
        align-items: center;
    }
    .pos-success-card {
        background: white;
        border-radius: var(--radius-xl);
        padding: 40px;
        text-align: center;
        max-width: 400px;
        width: 90%;
        animation: scaleIn 0.3s ease;
    }
    .pos-success-icon {
        width: 80px; height: 80px;
        background: #d1fae5;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
        font-size: 36px;
        color: #059669;
    }
</style>

<div class="pos-layout">
    <!-- Productos -->
    <div>
        <div class="card" style="margin-bottom: 20px;">
            <div class="card-header">
                <h3><i class="fas fa-search"></i> Buscar Producto</h3>
            </div>
            <input type="text" class="form-input" id="posSearchProduct" placeholder="Buscar por nombre..." oninput="posFilterProducts()" style="width: 100%;">
        </div>
        <div class="pos-products-grid" id="posProductsGrid">
            <% for (Productos p : productosPOS) { %>
            <div class="pos-product-card" onclick="posAddProduct(<%= p.getIdProducto() %>, '<%= p.getNombre().replace("'", "\\'") %>', <%= p.getPrecio() %>, <%= p.getStock() %>)" data-name="<%= p.getNombre().toLowerCase() %>">
                <div class="pos-product-icon">
                    <i class="fas fa-spray-can"></i>
                </div>
                <div class="pos-product-name"><%= p.getNombre() %></div>
                <div class="pos-product-price">S/ <%= String.format("%.2f", p.getPrecio()) %></div>
                <div class="pos-product-stock">Stock: <%= p.getStock() %></div>
            </div>
            <% } %>
            
            <!-- Servicios tambien disponibles -->
            <div class="pos-product-card" onclick="posAddProduct(101, 'Lavado Simple', 15, 999)" data-name="lavado simple">
                <div class="pos-product-icon"><i class="fas fa-shirt"></i></div>
                <div class="pos-product-name">Lavado Simple</div>
                <div class="pos-product-price">S/ 15.00</div>
                <div class="pos-product-stock">Servicio</div>
            </div>
            <div class="pos-product-card" onclick="posAddProduct(102, 'Lavado Premium', 25, 999)" data-name="lavado premium">
                <div class="pos-product-icon"><i class="fas fa-star"></i></div>
                <div class="pos-product-name">Lavado Premium</div>
                <div class="pos-product-price">S/ 25.00</div>
                <div class="pos-product-stock">Servicio</div>
            </div>
            <div class="pos-product-card" onclick="posAddProduct(103, 'Restauracion', 40, 999)" data-name="restauracion">
                <div class="pos-product-icon"><i class="fas fa-magic"></i></div>
                <div class="pos-product-name">Restauraci&oacute;n</div>
                <div class="pos-product-price">S/ 40.00</div>
                <div class="pos-product-stock">Servicio</div>
            </div>
        </div>
    </div>
    
    <!-- Carrito / POS -->
    <div class="pos-cart">
        <div class="pos-cart-header">
            <h3><i class="fas fa-shopping-cart" style="color: #0f766e;"></i> Carrito de Venta</h3>
            <div style="display: flex; justify-content: space-between; margin-top: 8px;">
                <span style="font-size: 13px; color: var(--gray-500);" id="posItemCount">0 art&iacute;culos</span>
                <button class="btn btn-ghost btn-sm" onclick="posClearCart()" style="font-size: 12px; color: #ef4444; padding: 2px 8px;">
                    <i class="fas fa-trash"></i> Limpiar
                </button>
            </div>
        </div>
        <div class="pos-cart-items" id="posCartItems">
            <div style="text-align: center; padding: 40px 20px; color: var(--gray-400);">
                <i class="fas fa-cart-plus" style="font-size: 36px; display: block; margin-bottom: 8px;"></i>
                <span style="font-size: 14px;">Selecciona productos para vender</span>
            </div>
        </div>
        <div class="pos-cart-footer">
            <div class="pos-total-row">
                <span class="pos-total-label">Total a Pagar:</span>
                <span class="pos-total-amount" id="posTotal">S/ 0.00</span>
            </div>
            
            <div id="posPaymentSection" style="display: none;">
                <label class="form-label" style="margin-bottom: 10px; font-weight: 700;">M&eacute;todo de Pago</label>
                <div class="pos-payment-methods">
                    <button class="pos-pay-btn" onclick="posSelectPayMethod('yape')" id="posPayYape">
                        <i class="fas fa-mobile-alt pos-yape"></i>
                        <span>Yape</span>
                    </button>
                    <button class="pos-pay-btn" onclick="posSelectPayMethod('contraentrega')" id="posPayContra">
                        <i class="fas fa-hand-holding-heart pos-contra"></i>
                        <span>Contra Entrega</span>
                    </button>
                    <button class="pos-pay-btn" onclick="posSelectPayMethod('transferencia')" id="posPayTransfer">
                        <i class="fas fa-university pos-transfer"></i>
                        <span>Transferencia</span>
                    </button>
                    <button class="pos-pay-btn" onclick="posSelectPayMethod('efectivo')" id="posPayEfectivo">
                        <i class="fas fa-money-bill-wave pos-efectivo"></i>
                        <span>Efectivo</span>
                    </button>
                </div>
                
                <!-- Yape Details -->
                <div id="posYapeDetail" style="display: none;">
                    <div class="pos-yape-qr">
                        <i class="fas fa-qrcode"></i>
                        <p>Escanea el c&oacute;digo Yape</p>
                        <div class="yape-number">934 567 890</div>
                        <p style="font-size: 12px; color: var(--gray-500);">Cel: 934567890 - New One</p>
                    </div>
                    <div class="form-group">
                        <label class="form-label">C&oacute;digo de Operaci&oacute;n Yape</label>
                        <input type="text" class="form-input" id="posYapeCode" placeholder="Ej: YPF123456789" style="text-align: center; font-weight: 700; letter-spacing: 1px;">
                    </div>
                </div>
                
                <!-- Transferencia Details -->
                <div id="posTransferDetail" style="display: none;">
                    <div class="pos-transfer-info">
                        <strong><i class="fas fa-university"></i> Datos Bancarios</strong>
                        <div class="bank-account">CCI: 002 123 456 789 0123 4567</div>
                        <p style="margin: 4px 0;"><strong>Banco:</strong> Interbank</p>
                        <p style="margin: 4px 0;"><strong>Cuenta:</strong> 123-456-789</p>
                        <p style="margin: 4px 0;"><strong>Titular:</strong> New One SAC</p>
                    </div>
                    <div class="form-group">
                        <label class="form-label">N&uacute;mero de Operaci&oacute;n</label>
                        <input type="text" class="form-input" id="posTransferCode" placeholder="N&uacute;mero de transferencia" style="text-align: center; font-weight: 700;">
                    </div>
                </div>
                
                <!-- Contraentrega Info -->
                <div id="posContraDetail" style="display: none;">
                    <div style="padding: 14px; background: #fff7ed; border-radius: var(--radius-md); border: 1.5px solid #fed7aa; margin: 12px 0;">
                        <p style="color: #9a3412; font-weight: 600; font-size: 14px; margin: 0;">
                            <i class="fas fa-info-circle"></i> El cobro se realizar&aacute; al momento de la entrega. El repartidor cobrar&aacute; <strong id="posContraMonto">S/ 0.00</strong>.
                        </p>
                    </div>
                </div>
                
                <!-- Efectivo Details -->
                <div id="posEfectivoDetail" style="display: none;">
                    <div style="padding: 14px; background: #f0fdf4; border-radius: var(--radius-md); border: 1.5px solid #bbf7d0; margin: 12px 0;">
                        <p style="color: #166534; font-weight: 600; font-size: 14px; margin: 0;">
                            <i class="fas fa-money-bill-wave"></i> Pago en efectivo. Se recibe el monto total en caja.
                        </p>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Monto Recibido (S/)</label>
                        <input type="number" class="form-input" id="posEfectivoMonto" placeholder="0.00" step="0.01" oninput="posCalcChange()">
                        <small id="posCambio" style="color: #16a34a; font-weight: 600;"></small>
                    </div>
                </div>
                
                <button class="pos-confirm-btn" onclick="posConfirmSale()" id="posConfirmBtn" style="background: #0f766e; color: white; margin-top: 8px;">
                    <i class="fas fa-check-circle"></i> Confirmar Venta
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Success Overlay -->
<div class="pos-success-overlay" id="posSuccessOverlay">
    <div class="pos-success-card">
        <div class="pos-success-icon">
            <i class="fas fa-check"></i>
        </div>
        <h2 style="margin: 0 0 8px;">&iexcl;Venta Registrada!</h2>
        <p style="color: var(--gray-600); margin: 0 0 20px;">La venta se ha procesado correctamente.</p>
        <div id="posSuccessDetails" style="background: var(--gray-50); padding: 16px; border-radius: var(--radius-md); margin-bottom: 20px; text-align: left; font-size: 14px;"></div>
        <button class="btn btn-primary btn-block" onclick="posCloseSuccess()">
            <i class="fas fa-plus"></i> Nueva Venta
        </button>
    </div>
</div>

<script>
    var posCart = [];
    var posSelectedMethod = null;
    
    function posAddProduct(id, name, price, stock) {
        var existing = posCart.find(function(item){ return item.id === id; });
        if (existing) {
            if (existing.qty < stock) {
                existing.qty++;
            }
        } else {
            posCart.push({ id: id, name: name, price: price, qty: 1, stock: stock });
        }
        posRenderCart();
    }
    
    function posRemoveProduct(id) {
        posCart = posCart.filter(function(item){ return item.id !== id; });
        posRenderCart();
    }
    
    function posChangeQty(id, delta) {
        var item = posCart.find(function(i){ return i.id === id; });
        if (item) {
            item.qty += delta;
            if (item.qty <= 0) posRemoveProduct(id);
            else posRenderCart();
        }
    }
    
    function posClearCart() {
        posCart = [];
        posSelectedMethod = null;
        posRenderCart();
    }
    
    function posRenderCart() {
        var container = document.getElementById('posCartItems');
        var totalEl = document.getElementById('posTotal');
        var countEl = document.getElementById('posItemCount');
        var paySection = document.getElementById('posPaymentSection');
        
        if (posCart.length === 0) {
            container.innerHTML = '<div style="text-align: center; padding: 40px 20px; color: var(--gray-400);"><i class="fas fa-cart-plus" style="font-size: 36px; display: block; margin-bottom: 8px;"></i><span style="font-size: 14px;">Selecciona productos para vender</span></div>';
            totalEl.innerText = 'S/ 0.00';
            countEl.innerText = '0 artículos';
            paySection.style.display = 'none';
            return;
        }
        
        var html = '';
        var total = 0;
        var totalItems = 0;
        
        posCart.forEach(function(item){
            total += item.price * item.qty;
            totalItems += item.qty;
            html += '<div class="pos-cart-item">';
            html += '<div class="pos-cart-item-info">';
            html += '<div class="pos-cart-item-name">' + item.name + '</div>';
            html += '<div class="pos-cart-item-price">S/ ' + item.price.toFixed(2) + ' c/u</div>';
            html += '</div>';
            html += '<div class="pos-cart-item-qty">';
            html += '<button onclick="posChangeQty(' + item.id + ', -1)">-</button>';
            html += '<span style="font-weight: 700; min-width: 24px; text-align: center;">' + item.qty + '</span>';
            html += '<button onclick="posChangeQty(' + item.id + ', 1)">+</button>';
            html += '</div>';
            html += '<div style="font-weight: 700; color: #0f766e; min-width: 70px; text-align: right;">S/ ' + (item.price * item.qty).toFixed(2) + '</div>';
            html += '<span class="pos-cart-item-remove" onclick="posRemoveProduct(' + item.id + ')"><i class="fas fa-times"></i></span>';
            html += '</div>';
        });
        
        container.innerHTML = html;
        totalEl.innerText = 'S/ ' + total.toFixed(2);
        countEl.innerText = totalItems + ' artículos';
        paySection.style.display = 'block';
    }
    
    function posFilterProducts() {
        var q = document.getElementById('posSearchProduct').value.toLowerCase();
        document.querySelectorAll('.pos-product-card').forEach(function(card){
            var name = card.getAttribute('data-name') || '';
            card.style.display = name.includes(q) ? '' : 'none';
        });
    }
    
    function posSelectPayMethod(method) {
        posSelectedMethod = method;
        document.querySelectorAll('.pos-pay-btn').forEach(function(b){ b.classList.remove('active'); });
        
        document.getElementById('posYapeDetail').style.display = 'none';
        document.getElementById('posTransferDetail').style.display = 'none';
        document.getElementById('posContraDetail').style.display = 'none';
        document.getElementById('posEfectivoDetail').style.display = 'none';
        
        if (method === 'yape') {
            document.getElementById('posPayYape').classList.add('active');
            document.getElementById('posYapeDetail').style.display = 'block';
        } else if (method === 'transferencia') {
            document.getElementById('posPayTransfer').classList.add('active');
            document.getElementById('posTransferDetail').style.display = 'block';
        } else if (method === 'contraentrega') {
            document.getElementById('posPayContra').classList.add('active');
            document.getElementById('posContraDetail').style.display = 'block';
            var total = posCart.reduce(function(s,i){ return s + i.price * i.qty; }, 0);
            document.getElementById('posContraMonto').innerText = 'S/ ' + total.toFixed(2);
        } else if (method === 'efectivo') {
            document.getElementById('posPayEfectivo').classList.add('active');
            document.getElementById('posEfectivoDetail').style.display = 'block';
        }
    }
    
    function posCalcChange() {
        var received = parseFloat(document.getElementById('posEfectivoMonto').value) || 0;
        var total = posCart.reduce(function(s,i){ return s + i.price * i.qty; }, 0);
        var change = received - total;
        var el = document.getElementById('posCambio');
        if (change >= 0 && received > 0) {
            el.innerText = 'Cambio: S/ ' + change.toFixed(2);
        } else {
            el.innerText = '';
        }
    }
    
    function posConfirmSale() {
        if (posCart.length === 0) return;
        if (!posSelectedMethod) { alert('Selecciona un método de pago'); return; }
        
        if (posSelectedMethod === 'yape') {
            var yc = document.getElementById('posYapeCode').value;
            if (!yc) { alert('Ingresa el código de Yape'); return; }
        } else if (posSelectedMethod === 'transferencia') {
            var tc = document.getElementById('posTransferCode').value;
            if (!tc) { alert('Ingresa el número de operación'); return; }
        }

        var btn = document.getElementById('posConfirmBtn');
        var origText = btn.innerHTML;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
        btn.disabled = true;

        var payload = {
            items: posCart.map(function(item) {
                return {
                    id: item.id,
                    name: item.name,
                    price: item.price,
                    qty: item.qty,
                    type: item.id >= 101 && item.id <= 103 ? 'servicio' : 'producto'
                };
            }),
            metodoPago: posSelectedMethod,
            codigoOperacion: '',
            montoRecibido: 0
        };

        if (posSelectedMethod === 'yape') {
            payload.codigoOperacion = document.getElementById('posYapeCode').value;
        } else if (posSelectedMethod === 'transferencia') {
            payload.codigoOperacion = document.getElementById('posTransferCode').value;
        } else if (posSelectedMethod === 'efectivo') {
            payload.montoRecibido = parseFloat(document.getElementById('posEfectivoMonto').value) || 0;
        }

        fetch('POSServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            btn.innerHTML = origText;
            btn.disabled = false;

            if (res.success) {
                var total = posCart.reduce(function(s, i) { return s + i.price * i.qty; }, 0);
                var details = '<strong>Total: S/ ' + total.toFixed(2) + '</strong><br>';
                details += 'Método: ' + posSelectedMethod.toUpperCase() + '<br>';
                details += 'Artículos: ' + posCart.length + '<br>';
                details += '<br><small style="color: var(--gray-500);">Venta registrada en el sistema correctamente.</small>';

                document.getElementById('posSuccessDetails').innerHTML = details;
                document.getElementById('posSuccessOverlay').style.display = 'flex';
            } else {
                alert('Error: ' + (res.error || 'No se pudo procesar la venta'));
            }
        })
        .catch(function(err) {
            console.error(err);
            btn.innerHTML = origText;
            btn.disabled = false;
            alert('Error de conexión. Intenta nuevamente.');
        });
    }
    
    function posCloseSuccess() {
        document.getElementById('posSuccessOverlay').style.display = 'none';
        posCart = [];
        posSelectedMethod = null;
        posRenderCart();
        document.querySelectorAll('.pos-pay-btn').forEach(function(b){ b.classList.remove('active'); });
        document.getElementById('posYapeDetail').style.display = 'none';
        document.getElementById('posTransferDetail').style.display = 'none';
        document.getElementById('posContraDetail').style.display = 'none';
        document.getElementById('posEfectivoDetail').style.display = 'none';
        location.reload();
    }
</script>
