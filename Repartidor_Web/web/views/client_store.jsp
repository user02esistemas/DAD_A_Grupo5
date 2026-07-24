<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entidades.Clientes" %>
<%
    Clientes cliStore = (Clientes) session.getAttribute("cliente");
    String direccionCliente = (cliStore != null && cliStore.getDireccion() != null) ? cliStore.getDireccion() : "";
%>

<section id="store" class="section">
    <div class="container">
        <div class="card" style="margin-bottom: 24px; border-left: 4px solid var(--aqua);">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h2 style="margin: 0; font-size: 22px;">Tienda New One</h2>
                    <p style="color: var(--gray-600); margin: 4px 0 0; font-size: 14px;">Productos de limpieza, accesorios y servicios. Agrega al carrito y paga con tu m&eacute;todo preferido.</p>
                </div>
                <div id="storeCartBadge" style="display: none; background: var(--aqua); color: var(--dark); padding: 8px 16px; border-radius: var(--radius-full); font-weight: 700; font-size: 14px; cursor: pointer;" onclick="toggleCartPanel()">
                    <i class="fas fa-shopping-cart"></i> <span id="cartBadgeCount">0</span>
                </div>
            </div>
        </div>

        <div id="storeLoading" style="text-align: center; padding: 60px; color: var(--gray-500);">
            <i class="fas fa-spinner fa-spin" style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
            Cargando productos...
        </div>

        <div id="storeContent" style="display: none;">
            <div style="display: grid; grid-template-columns: 1fr 400px; gap: 24px; align-items: start;">
                <div>
                    <div class="card" style="margin-bottom: 20px;">
                        <div style="display: flex; gap: 10px; align-items: center;">
                            <i class="fas fa-search" style="color: var(--gray-400);"></i>
                            <input type="text" class="form-input" id="storeSearch" placeholder="Buscar productos, accesorios, servicios..." oninput="storeFilterProducts()" style="border: none; padding: 0; box-shadow: none;">
                        </div>
                    </div>

                    <div style="margin-bottom: 16px; display: flex; gap: 8px; flex-wrap: wrap;">
                        <button class="btn btn-primary btn-sm" onclick="storeFilterCategory('all')" id="catAll">Todos</button>
                        <button class="btn btn-outline btn-sm" onclick="storeFilterCategory('producto')" id="catProducto">Productos</button>
                        <button class="btn btn-outline btn-sm" onclick="storeFilterCategory('servicio')" id="catServicio">Servicios</button>
                    </div>

                    <div id="storeProductsGrid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px;"></div>
                </div>

                <div id="storeCartPanel" style="position: sticky; top: 24px;">
                    <div class="card" style="border: 2px solid var(--aqua);">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid var(--gray-200);">
                            <h3 style="margin: 0; font-size: 18px;"><i class="fas fa-shopping-cart" style="color: var(--aqua-dark);"></i> Mi Carrito</h3>
                            <button class="btn btn-ghost btn-sm" onclick="storeClearCart()" style="color: var(--danger); font-size: 12px;" id="btnClearCart" style="display: none;">
                                <i class="fas fa-trash"></i> Limpiar
                            </button>
                        </div>

                        <div id="storeCartEmpty" style="text-align: center; padding: 30px 10px; color: var(--gray-400);">
                            <i class="fas fa-cart-plus" style="font-size: 40px; display: block; margin-bottom: 10px;"></i>
                            <p style="font-size: 14px;">Tu carrito est&aacute; vac&iacute;o</p>
                            <p style="font-size: 12px;">Agrega productos desde la tienda</p>
                        </div>

                        <div id="storeCartItems" style="display: none; max-height: 280px; overflow-y: auto; margin-bottom: 16px;"></div>

                        <div id="storeCartSummary" style="display: none;">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                                <span style="color: var(--gray-600); font-size: 14px;">Subtotal:</span>
                                <span style="font-weight: 600;" id="storeSubtotal">S/ 0.00</span>
                            </div>
                            <div style="display: flex; justify-content: space-between; margin-bottom: 16px; padding-top: 8px; border-top: 2px solid var(--gray-200);">
                                <span style="color: var(--dark); font-weight: 700; font-size: 16px;">Total:</span>
                                <span style="font-weight: 800; font-size: 22px; color: var(--aqua-dark);" id="storeTotal">S/ 0.00</span>
                            </div>

                            <div class="form-group">
                                <label class="form-label">&iquest;C&oacute;mo recibir tu pedido?</label>
                                <div style="display: flex; gap: 10px;">
                                    <label class="radio-card" style="flex: 1;">
                                        <input type="radio" name="storeModalidad" value="Delivery" checked onchange="storeToggleAddress(true)">
                                        <span><i class="fas fa-motorcycle"></i> Delivery</span>
                                    </label>
                                    <label class="radio-card" style="flex: 1;">
                                        <input type="radio" name="storeModalidad" value="Recojo en Tienda" onchange="storeToggleAddress(false)">
                                        <span><i class="fas fa-store"></i> Recojo</span>
                                    </label>
                                </div>
                            </div>

                            <div class="form-group" id="storeAddressGroup">
                                <label class="form-label">Direcci&oacute;n de Env&iacute;o</label>
                                <textarea id="storeAddress" class="form-input" rows="2" placeholder="Calle, N&uacute;mero, Referencia..."><%= direccionCliente %></textarea>
                            </div>

                            <div id="storePickupMsg" style="display: none; background: var(--info-bg); padding: 10px; border-radius: var(--radius-sm); color: #1976d2; font-size: 13px; margin-bottom: 12px;">
                                <i class="fas fa-info-circle"></i> Recoger&aacute;s tu pedido en nuestro local.
                            </div>

                            <div class="form-group">
                                <label class="form-label" style="font-weight: 700;">M&eacute;todo de Pago</label>
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                                    <button type="button" class="store-pay-btn" onclick="storeSelectPay('yape')" id="payBtnYape">
                                        <i class="fas fa-mobile-alt" style="color: #7c3aed;"></i> Yape
                                    </button>
                                    <button type="button" class="store-pay-btn" onclick="storeSelectPay('transferencia')" id="payBtnTransfer">
                                        <i class="fas fa-university" style="color: #2563eb;"></i> Transferencia
                                    </button>
                                    <button type="button" class="store-pay-btn" onclick="storeSelectPay('efectivo')" id="payBtnEfectivo">
                                        <i class="fas fa-money-bill-wave" style="color: #16a34a;"></i> Efectivo
                                    </button>
                                    <button type="button" class="store-pay-btn" onclick="storeSelectPay('contraentrega')" id="payBtnContra">
                                        <i class="fas fa-hand-holding-heart" style="color: #ea580c;"></i> Contra Entrega
                                    </button>
                                </div>
                            </div>

                            <div id="storePayYape" style="display: none;">
                                <div style="text-align: center; padding: 16px; background: #faf5ff; border-radius: var(--radius-md); border: 2px dashed #7c3aed; margin-bottom: 12px;">
                                    <i class="fas fa-qrcode" style="font-size: 40px; color: #7c3aed;"></i>
                                    <p style="color: #7c3aed; font-weight: 600; margin: 6px 0 2px; font-size: 13px;">Env&iacute;a a Yape</p>
                                    <div style="font-size: 18px; font-weight: 800; color: #7c3aed; letter-spacing: 2px;">934 567 890</div>
                                    <p style="font-size: 11px; color: var(--gray-500); margin: 4px 0 0;">New One SAC</p>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">C&oacute;digo de Operaci&oacute;n</label>
                                    <input type="text" class="form-input" id="storeYapeCode" placeholder="Ej: YPF123456789" style="text-align: center; font-weight: 700; letter-spacing: 1px;">
                                </div>
                            </div>

                            <div id="storePayTransfer" style="display: none;">
                                <div style="padding: 14px; background: #eff6ff; border-radius: var(--radius-md); border: 1.5px solid #93c5fd; margin-bottom: 12px; font-size: 13px;">
                                    <strong style="color: #1d4ed8;"><i class="fas fa-university"></i> Datos Bancarios</strong>
                                    <div style="font-size: 16px; font-weight: 800; color: #1e40af; letter-spacing: 1px; margin: 6px 0;">CCI: 002 123 456 789 0123 4567</div>
                                    <p style="margin: 2px 0;"><strong>Banco:</strong> Interbank</p>
                                    <p style="margin: 2px 0;"><strong>Titular:</strong> New One SAC</p>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">N&uacute;mero de Operaci&oacute;n</label>
                                    <input type="text" class="form-input" id="storeTransferCode" placeholder="N&uacute;mero de transferencia" style="text-align: center; font-weight: 700;">
                                </div>
                            </div>

                            <div id="storePayContra" style="display: none;">
                                <div style="padding: 12px; background: #fff7ed; border-radius: var(--radius-md); border: 1.5px solid #fed7aa; margin-bottom: 12px;">
                                    <p style="color: #9a3412; font-weight: 600; font-size: 13px; margin: 0;">
                                        <i class="fas fa-info-circle"></i> El cobro se har&aacute; al momento de la entrega. Monto: <strong id="storeContraMonto">S/ 0.00</strong>
                                    </p>
                                </div>
                            </div>

                            <div id="storePayEfectivo" style="display: none;">
                                <div style="padding: 12px; background: #f0fdf4; border-radius: var(--radius-md); border: 1.5px solid #bbf7d0; margin-bottom: 12px;">
                                    <p style="color: #166534; font-weight: 600; font-size: 13px; margin: 0;">
                                        <i class="fas fa-money-bill-wave"></i> Pago en efectivo en local.
                                    </p>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Monto Recibido (S/)</label>
                                    <input type="number" class="form-input" id="storeEfectivoMonto" placeholder="0.00" step="0.01" oninput="storeCalcChange()">
                                    <small id="storeCambio" style="color: #16a34a; font-weight: 600;"></small>
                                </div>
                            </div>

                            <button class="btn btn-primary btn-block btn-lg" onclick="storeCheckout()" id="btnCheckout" style="margin-top: 8px;">
                                <i class="fas fa-lock"></i> Comprar Ahora
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="storeSuccessOverlay" style="position: fixed; inset: 0; background: rgba(0,0,0,0.6); backdrop-filter: blur(6px); z-index: 3000; display: none; justify-content: center; align-items: center;">
        <div style="background: white; border-radius: var(--radius-xl); padding: 40px; text-align: center; max-width: 420px; width: 90%; animation: scaleIn 0.3s ease;">
            <div style="width: 80px; height: 80px; background: #d1fae5; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; font-size: 36px; color: #059669;">
                <i class="fas fa-check"></i>
            </div>
            <h2 style="margin: 0 0 8px;">&iexcl;Pedido Realizado!</h2>
            <p style="color: var(--gray-600); margin: 0 0 20px;">Tu compra se ha procesado correctamente.</p>
            <div id="storeSuccessDetails" style="background: var(--gray-50); padding: 16px; border-radius: var(--radius-md); margin-bottom: 20px; text-align: left; font-size: 14px;"></div>
            <button class="btn btn-primary btn-block" onclick="storeCloseSuccess()">
                <i class="fas fa-shopping-bag"></i> Seguir Comprando
            </button>
        </div>
    </div>
</section>

<style>
    .store-pay-btn {
        padding: 10px 8px;
        border: 2px solid var(--gray-200);
        border-radius: var(--radius-md);
        background: var(--white);
        cursor: pointer;
        text-align: center;
        transition: all 0.2s;
        font-family: var(--font-body);
        font-size: 12px;
        font-weight: 600;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
    }
    .store-pay-btn:hover { border-color: var(--aqua); background: var(--aqua-glow); }
    .store-pay-btn.active { border-color: var(--aqua); background: var(--aqua-glow); box-shadow: 0 0 0 3px rgba(64,224,208,0.15); }
    .store-pay-btn i { font-size: 16px; }

    .store-product-card {
        background: var(--white);
        border-radius: var(--radius-lg);
        border: 2px solid var(--gray-200);
        overflow: hidden;
        transition: all 0.2s;
        cursor: pointer;
    }
    .store-product-card:hover { border-color: var(--aqua); transform: translateY(-2px); box-shadow: var(--shadow-md); }

    .store-cart-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px;
        background: var(--gray-50);
        border-radius: var(--radius-sm);
        margin-bottom: 8px;
    }
    .store-cart-item-info { flex: 1; min-width: 0; }
    .store-cart-item-name { font-weight: 600; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .store-cart-item-price { color: var(--aqua-dark); font-size: 12px; font-weight: 600; }
    .store-cart-item-qty { display: flex; align-items: center; gap: 4px; flex-shrink: 0; }
    .store-cart-item-qty button {
        width: 24px; height: 24px; border: 1px solid var(--gray-300);
        background: white; border-radius: 50%; cursor: pointer;
        display: flex; align-items: center; justify-content: center;
        font-size: 12px; font-weight: 700; transition: all 0.15s;
    }
    .store-cart-item-qty button:hover { border-color: var(--aqua); color: var(--aqua); }
    .store-cart-item-subtotal { font-weight: 700; color: var(--aqua-dark); font-size: 13px; min-width: 60px; text-align: right; }
    .store-cart-item-remove { color: var(--danger); cursor: pointer; font-size: 12px; padding: 2px; flex-shrink: 0; }
</style>

<script>
    var storeCart = [];
    var storeSelectedPay = null;

    function storeLoadProducts() {
        fetch('ProductosServlet')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                document.getElementById('storeLoading').style.display = 'none';
                document.getElementById('storeContent').style.display = 'block';
                var grid = document.getElementById('storeProductsGrid');
                grid.innerHTML = '';

                if (data.error) { grid.innerHTML = '<div style="color: var(--danger); padding: 20px;">Error: ' + data.error + '</div>'; return; }

                data.forEach(function(p) {
                    var imgHtml = '';
                    if (p.imagen && p.imagen !== '' && p.imagen.indexOf('placeholder') === -1) {
                        imgHtml = '<img src="' + p.imagen + '" style="width:100%;height:120px;object-fit:cover;">';
                    } else {
                        imgHtml = '<div style="height:120px;background:var(--gray-50);display:flex;align-items:center;justify-content:center;"><i class="fas fa-spray-can" style="font-size:32px;color:var(--gray-300);"></i></div>';
                    }

                    var safeName = p.nombre.replace(/'/g, "\\'").replace(/"/g, '&quot;');
                    var desc = p.descripcion ? p.descripcion : '';

                    var card = document.createElement('div');
                    card.className = 'store-product-card';
                    card.setAttribute('data-name', p.nombre.toLowerCase());
                    card.setAttribute('data-category', 'producto');
                    card.innerHTML = imgHtml +
                        '<div style="padding: 14px;">' +
                            '<h4 style="margin: 0 0 4px; font-size: 15px;">' + p.nombre + '</h4>' +
                            '<p style="color: var(--gray-600); font-size: 12px; margin: 0 0 10px; height: 32px; overflow: hidden; line-height: 1.4;">' + desc + '</p>' +
                            '<div style="display: flex; justify-content: space-between; align-items: center;">' +
                                '<span style="font-weight: 800; color: var(--aqua-dark); font-size: 18px;">S/ ' + p.precio.toFixed(2) + '</span>' +
                                '<button class="btn btn-primary btn-sm" onclick="event.stopPropagation(); storeAddToCart(' + p.id + ', \'' + safeName + '\', ' + p.precio + ', 999, \'producto\')">' +
                                    '<i class="fas fa-plus"></i> Agregar' +
                                '</button>' +
                            '</div>' +
                        '</div>';
                    grid.appendChild(card);
                });

                var servicios = [
                    { id: 101, nombre: 'Lavado Simple', precio: 15, desc: 'Lavado b\u00e1sico de zapatillas', icon: 'fa-shirt' },
                    { id: 102, nombre: 'Lavado Premium', precio: 25, desc: 'Lavado profundo con tratamiento especial', icon: 'fa-star' },
                    { id: 103, nombre: 'Restauraci\u00f3n', precio: 40, desc: 'Restauraci\u00f3n completa de color y material', icon: 'fa-magic' }
                ];

                servicios.forEach(function(s) {
                    var safeName = s.nombre.replace(/'/g, "\\'");
                    var card = document.createElement('div');
                    card.className = 'store-product-card';
                    card.setAttribute('data-name', s.nombre.toLowerCase());
                    card.setAttribute('data-category', 'servicio');
                    card.innerHTML =
                        '<div style="height:120px;background:linear-gradient(135deg, var(--aqua-glow), #f0fdfa);display:flex;align-items:center;justify-content:center;">' +
                            '<i class="fas ' + s.icon + '" style="font-size:36px;color:var(--aqua-dark);"></i>' +
                        '</div>' +
                        '<div style="padding: 14px;">' +
                            '<h4 style="margin: 0 0 4px; font-size: 15px;">' + s.nombre + '</h4>' +
                            '<p style="color: var(--gray-600); font-size: 12px; margin: 0 0 10px;">' + s.desc + '</p>' +
                            '<div style="display: flex; justify-content: space-between; align-items: center;">' +
                                '<span style="font-weight: 800; color: var(--aqua-dark); font-size: 18px;">S/ ' + s.precio.toFixed(2) + '</span>' +
                                '<button class="btn btn-primary btn-sm" onclick="event.stopPropagation(); storeAddToCart(' + s.id + ', \'' + safeName + '\', ' + s.precio + ', 999, \'servicio\')">' +
                                    '<i class="fas fa-plus"></i> Agregar' +
                                '</button>' +
                            '</div>' +
                        '</div>';
                    grid.appendChild(card);
                });
            })
            .catch(function(err) {
                document.getElementById('storeLoading').innerHTML = '<div style="color: var(--danger);"><i class="fas fa-exclamation-triangle"></i> Error al cargar productos</div>';
                console.error(err);
            });
    }

    function storeFilterProducts() {
        var q = document.getElementById('storeSearch').value.toLowerCase();
        document.querySelectorAll('.store-product-card').forEach(function(card) {
            var name = card.getAttribute('data-name') || '';
            card.style.display = name.includes(q) ? '' : 'none';
        });
    }

    function storeFilterCategory(cat) {
        document.querySelectorAll('.store-product-card').forEach(function(card) {
            var c = card.getAttribute('data-category');
            if (cat === 'all') { card.style.display = ''; }
            else { card.style.display = c === cat ? '' : 'none'; }
        });
        document.querySelectorAll('#storeContent .btn-sm').forEach(function(b) { b.className = 'btn btn-outline btn-sm'; });
        var activeBtn = document.getElementById('cat' + cat.charAt(0).toUpperCase() + cat.slice(1));
        if (activeBtn) activeBtn.className = 'btn btn-primary btn-sm';
    }

    function storeAddToCart(id, name, price, stock, type) {
        var existing = storeCart.find(function(item) { return item.id === id; });
        if (existing) {
            if (existing.qty < stock) existing.qty++;
        } else {
            storeCart.push({ id: id, name: name, price: price, qty: 1, stock: stock, type: type });
        }
        storeRenderCart();
        showNotification('Agregado: ' + name, 'success');
    }

    function storeRemoveFromCart(id) {
        storeCart = storeCart.filter(function(item) { return item.id !== id; });
        storeRenderCart();
    }

    function storeChangeQty(id, delta) {
        var item = storeCart.find(function(i) { return i.id === id; });
        if (item) {
            item.qty += delta;
            if (item.qty <= 0) storeRemoveFromCart(id);
            else storeRenderCart();
        }
    }

    function storeClearCart() {
        storeCart = [];
        storeSelectedPay = null;
        storeRenderCart();
    }

    function storeRenderCart() {
        var itemsEl = document.getElementById('storeCartItems');
        var emptyEl = document.getElementById('storeCartEmpty');
        var summaryEl = document.getElementById('storeCartSummary');
        var badge = document.getElementById('storeCartBadge');
        var badgeCount = document.getElementById('cartBadgeCount');
        var btnClear = document.getElementById('btnClearCart');

        if (storeCart.length === 0) {
            emptyEl.style.display = 'block';
            itemsEl.style.display = 'none';
            summaryEl.style.display = 'none';
            badge.style.display = 'none';
            btnClear.style.display = 'none';
            storeSelectedPay = null;
            return;
        }

        emptyEl.style.display = 'none';
        itemsEl.style.display = 'block';
        summaryEl.style.display = 'block';
        badge.style.display = 'inline-flex';
        btnClear.style.display = 'inline-flex';

        var html = '';
        var total = 0;
        var totalItems = 0;

        storeCart.forEach(function(item) {
            var subtotal = item.price * item.qty;
            total += subtotal;
            totalItems += item.qty;
            html += '<div class="store-cart-item">' +
                '<div class="store-cart-item-info">' +
                    '<div class="store-cart-item-name">' + item.name + '</div>' +
                    '<div class="store-cart-item-price">S/ ' + item.price.toFixed(2) + ' c/u</div>' +
                '</div>' +
                '<div class="store-cart-item-qty">' +
                    '<button onclick="storeChangeQty(' + item.id + ', -1)">-</button>' +
                    '<span style="font-weight:700;min-width:20px;text-align:center;font-size:13px;">' + item.qty + '</span>' +
                    '<button onclick="storeChangeQty(' + item.id + ', 1)">+</button>' +
                '</div>' +
                '<div class="store-cart-item-subtotal">S/ ' + subtotal.toFixed(2) + '</div>' +
                '<span class="store-cart-item-remove" onclick="storeRemoveFromCart(' + item.id + ')"><i class="fas fa-times"></i></span>' +
            '</div>';
        });

        itemsEl.innerHTML = html;
        document.getElementById('storeSubtotal').innerText = 'S/ ' + total.toFixed(2);
        document.getElementById('storeTotal').innerText = 'S/ ' + total.toFixed(2);
        badgeCount.innerText = totalItems;
    }

    function storeToggleAddress(isDelivery) {
        var addr = document.getElementById('storeAddressGroup');
        var msg = document.getElementById('storePickupMsg');
        if (isDelivery) { addr.style.display = 'block'; msg.style.display = 'none'; }
        else { addr.style.display = 'none'; msg.style.display = 'block'; }
    }

    function storeSelectPay(method) {
        storeSelectedPay = method;
        document.querySelectorAll('.store-pay-btn').forEach(function(b) { b.classList.remove('active'); });

        document.getElementById('storePayYape').style.display = 'none';
        document.getElementById('storePayTransfer').style.display = 'none';
        document.getElementById('storePayContra').style.display = 'none';
        document.getElementById('storePayEfectivo').style.display = 'none';

        var btnMap = { yape: 'payBtnYape', transferencia: 'payBtnTransfer', efectivo: 'payBtnEfectivo', contraentrega: 'payBtnContra' };
        var detailMap = { yape: 'storePayYape', transferencia: 'storePayTransfer', efectivo: 'storePayEfectivo', contraentrega: 'storePayContra' };

        if (btnMap[method]) document.getElementById(btnMap[method]).classList.add('active');
        if (detailMap[method]) document.getElementById(detailMap[method]).style.display = 'block';

        if (method === 'contraentrega') {
            var total = storeCart.reduce(function(s, i) { return s + i.price * i.qty; }, 0);
            document.getElementById('storeContraMonto').innerText = 'S/ ' + total.toFixed(2);
        }
    }

    function storeCalcChange() {
        var received = parseFloat(document.getElementById('storeEfectivoMonto').value) || 0;
        var total = storeCart.reduce(function(s, i) { return s + i.price * i.qty; }, 0);
        var change = received - total;
        var el = document.getElementById('storeCambio');
        el.innerText = (change >= 0 && received > 0) ? 'Cambio: S/ ' + change.toFixed(2) : '';
    }

    function storeCheckout() {
        if (storeCart.length === 0) { showNotification('Tu carrito est\u00e1 vac\u00edo', 'error'); return; }
        if (!storeSelectedPay) { showNotification('Selecciona un m\u00e9todo de pago', 'error'); return; }

        var isDelivery = document.querySelector('input[name="storeModalidad"]:checked').value === 'Delivery';
        if (isDelivery && document.getElementById('storeAddress').value.trim() === '') {
            showNotification('Ingresa la direcci\u00f3n de env\u00edo', 'error');
            return;
        }

        if (storeSelectedPay === 'yape' && !document.getElementById('storeYapeCode').value.trim()) {
            showNotification('Ingresa el c\u00f3digo de Yape', 'error'); return;
        }
        if (storeSelectedPay === 'transferencia' && !document.getElementById('storeTransferCode').value.trim()) {
            showNotification('Ingresa el n\u00famero de operaci\u00f3n', 'error'); return;
        }

        var btn = document.getElementById('btnCheckout');
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
        btn.disabled = true;

        var fd = new URLSearchParams();
        fd.append('accion', 'carrito');
        fd.append('metodoPago', storeSelectedPay);

        var modalidad = document.querySelector('input[name="storeModalidad"]:checked').value;
        fd.append('modalidad', modalidad);

        if (modalidad === 'Delivery') {
            fd.append('direccion', document.getElementById('storeAddress').value);
        } else {
            fd.append('direccion', 'Recojo en Tienda Principal');
        }

        var now = new Date();
        var iso = new Date(now.getTime() - (now.getTimezoneOffset() * 60000)).toISOString();
        fd.append('fecha', iso.slice(0, 16).replace('T', ' '));

        storeCart.forEach(function(item, idx) {
            fd.append('itemId_' + idx, item.id);
            fd.append('itemQty_' + idx, item.qty);
            fd.append('itemType_' + idx, item.type);
        });
        fd.append('itemCount', storeCart.length);

        if (storeSelectedPay === 'yape') fd.append('yapeCode', document.getElementById('storeYapeCode').value);
        if (storeSelectedPay === 'transferencia') fd.append('transferCode', document.getElementById('storeTransferCode').value);

        var total = storeCart.reduce(function(s, i) { return s + i.price * i.qty; }, 0);

        fetch('OrdenClienteServlet', { method: 'POST', body: fd })
        .then(function(r) { return r.text(); })
        .then(function(res) {
            btn.innerHTML = '<i class="fas fa-lock"></i> Comprar Ahora';
            btn.disabled = false;

            if (res.trim() === 'success') {
                var details = '<strong>Total: S/ ' + total.toFixed(2) + '</strong><br>';
                details += 'M\u00e9todo: ' + storeSelectedPay.charAt(0).toUpperCase() + storeSelectedPay.slice(1) + '<br>';
                details += 'Art\u00edculos: ' + storeCart.length + '<br>';
                details += 'Entrega: ' + modalidad;
                document.getElementById('storeSuccessDetails').innerHTML = details;
                document.getElementById('storeSuccessOverlay').style.display = 'flex';
            } else {
                showNotification('Error: ' + res, 'error');
            }
        })
        .catch(function(err) {
            btn.innerHTML = '<i class="fas fa-lock"></i> Comprar Ahora';
            btn.disabled = false;
            showNotification('Error de conexi\u00f3n', 'error');
            console.error(err);
        });
    }

    function storeCloseSuccess() {
        document.getElementById('storeSuccessOverlay').style.display = 'none';
        storeCart = [];
        storeSelectedPay = null;
        storeRenderCart();
        document.querySelectorAll('.store-pay-btn').forEach(function(b) { b.classList.remove('active'); });
        document.getElementById('storePayYape').style.display = 'none';
        document.getElementById('storePayTransfer').style.display = 'none';
        document.getElementById('storePayContra').style.display = 'none';
        document.getElementById('storePayEfectivo').style.display = 'none';
    }

    function toggleCartPanel() {
        document.getElementById('storeCartPanel').scrollIntoView({ behavior: 'smooth' });
    }

    document.addEventListener('DOMContentLoaded', function() { storeLoadProducts(); });
</script>
