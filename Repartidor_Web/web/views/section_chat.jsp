
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entidades.Empleados" %>

<style>
    .chat-container {
        background: var(--white);
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-sm);
        border: 1px solid rgba(0,0,0,0.04);
        overflow: hidden;
        display: flex;
        flex-direction: column;
        height: 500px;
    }
    .chat-header-bar {
        padding: 16px 20px;
        background: var(--gray-50);
        border-bottom: 1px solid var(--gray-200);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .chat-header-bar h3 { margin: 0; font-size: 16px; }
    .chat-online-dot { width: 8px; height: 8px; background: #22c55e; border-radius: 50%; display: inline-block; margin-right: 6px; animation: pulse 2s infinite; }
    @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
    
    .chat-messages {
        flex: 1;
        overflow-y: auto;
        padding: 16px 20px;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .chat-msg {
        max-width: 75%;
        padding: 10px 16px;
        border-radius: 16px;
        font-size: 14px;
        line-height: 1.5;
        word-wrap: break-word;
    }
    .chat-msg-mine {
        align-self: flex-end;
        background: #0f766e;
        color: white;
        border-bottom-right-radius: 4px;
    }
    .chat-msg-other {
        align-self: flex-start;
        background: var(--gray-100);
        color: var(--dark);
        border-bottom-left-radius: 4px;
    }
    .chat-msg-system {
        align-self: center;
        background: transparent;
        color: var(--gray-500);
        font-size: 12px;
        font-style: italic;
    }
    .chat-msg-meta {
        font-size: 11px;
        margin-top: 4px;
        opacity: 0.7;
    }
    .chat-msg-sender {
        font-size: 11px;
        font-weight: 700;
        margin-bottom: 2px;
    }
    .chat-msg-sender-admin { color: #dc2626; }
    .chat-msg-sender-empleado { color: #2563eb; }
    .chat-msg-sender-repartidor { color: #0f766e; }
    
    .chat-input-bar {
        padding: 16px 20px;
        border-top: 1px solid var(--gray-200);
        display: flex;
        gap: 10px;
    }
    .chat-input-bar input {
        flex: 1;
        padding: 10px 16px;
        border: 1.5px solid var(--gray-300);
        border-radius: 24px;
        font-family: var(--font-body);
        font-size: 14px;
        outline: none;
        transition: border-color 0.2s;
    }
    .chat-input-bar input:focus { border-color: #0f766e; }
    .chat-send-btn {
        width: 42px; height: 42px;
        border: none;
        background: #0f766e;
        color: white;
        border-radius: 50%;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s;
    }
    .chat-send-btn:hover { background: #134e4a; transform: scale(1.05); }
    
    @media (max-width: 768px) {
        .chat-container { height: calc(100vh - 220px); }
        .chat-msg { max-width: 85%; }
    }
</style>

<div class="chat-container">
    <div class="chat-header-bar">
        <h3><span class="chat-online-dot"></span> Chat General</h3>
        <span style="font-size: 12px; color: var(--gray-500);">Todos los roles</span>
    </div>
    <div class="chat-messages" id="chatMessages">
        <div class="chat-msg chat-msg-system">Bienvenido al chat interno de New One</div>
    </div>
    <div class="chat-input-bar">
        <input type="text" id="chatInput" placeholder="Escribe un mensaje..." onkeypress="if(event.key==='Enter')sendChatMsg()">
        <button class="chat-send-btn" onclick="sendChatMsg()"><i class="fas fa-paper-plane"></i></button>
    </div>
</div>

<script>
    var chatInitialized = false;
    var chatInterval = null;
    
    <% Empleados chatUser = (Empleados) session.getAttribute("usuario"); %>
    var currentCode = '<%= chatUser != null ? chatUser.getCodigoEmpleado() : "admin" %>';
    var currentRol = '<%= session.getAttribute("rol") != null ? session.getAttribute("rol") : "admin" %>';
    
    function initChat() {
        if (chatInitialized) { loadChatMessages(); return; }
        chatInitialized = true;
        loadChatMessages();
        chatInterval = setInterval(loadChatMessages, 3000);
    }
    
    function loadChatMessages() {
        
        fetch('/AdminEmpleado_Web/ComunicacionServlet').then(function(r){ return r.json(); }).then(function(msgs){
            var container = document.getElementById('chatMessages');
            if (!container) return;
            var html = '<div class="chat-msg chat-msg-system">Bienvenido al chat interno de New One</div>';
            
            msgs.forEach(function(m){
                var isMine = (m.remitente === currentCode);
                var senderClass = 'chat-msg-sender-' + m.rol;
                
                html += '<div class="chat-msg ' + (isMine ? 'chat-msg-mine' : 'chat-msg-other') + '">';
                html += '<div class="chat-msg-sender ' + senderClass + '">' + m.rol.toUpperCase() + ' - ' + m.remitente + '</div>';
                html += '<div>' + m.mensaje + '</div>';
                html += '<div class="chat-msg-meta">' + m.fecha + '</div>';
                html += '</div>';
            });
            
            container.innerHTML = html;
            container.scrollTop = container.scrollHeight;
        });
    }
    
    function sendChatMsg() {
        var input = document.getElementById('chatInput');
        var msg = input.value.trim();
        if (!msg) return;
        
        var fd = new URLSearchParams();
        fd.append('mensaje', msg);
        fd.append('destino', 'todos');
        
        fd.append('remitente', currentCode);
        fd.append('rol', currentRol);
        
        fetch('/AdminEmpleado_Web/ComunicacionServlet', { method: 'POST', body: fd }).then(function(r){ return r.text(); }).then(function(d){
            if (d.trim() === 'success') {
                input.value = '';
                loadChatMessages();
            }
        });
    }
</script>
