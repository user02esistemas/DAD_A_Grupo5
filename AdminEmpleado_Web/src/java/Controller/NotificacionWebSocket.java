package Controller;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedDeque;

@ServerEndpoint("/notificaciones/{idCliente}")
public class NotificacionWebSocket {

    private static final ConcurrentHashMap<String, Set<Session>> clientSessions = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, ConcurrentLinkedDeque<String>> notificacionesPendientes = new ConcurrentHashMap<>();
    private static final int MAX_NOTIFICACIONES_HISTORIAL = 50;

    @OnOpen
    public void onOpen(Session session, @PathParam("idCliente") String idCliente) {
        clientSessions.computeIfAbsent(idCliente, k -> Collections.synchronizedSet(new HashSet<>())).add(session);
        System.out.println("WebSocket abierto para cliente: " + idCliente + " - Sesion: " + session.getId());

        ConcurrentLinkedDeque<String> pendientes = notificacionesPendientes.get(idCliente);
        if (pendientes != null && !pendientes.isEmpty()) {
            try {
                StringBuilder batch = new StringBuilder("[");
                boolean first = true;
                while (!pendientes.isEmpty()) {
                    String notif = pendientes.pollFirst();
                    if (!first) batch.append(",");
                    batch.append(notif);
                    first = false;
                }
                batch.append("]");
                synchronized (session) {
                    if (session.isOpen()) {
                        session.getBasicRemote().sendText(batch.toString());
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        try {
            String connectMsg = "{\"tipo\":\"conexion\",\"mensaje\":\"Conectado\",\"timestamp\":" + System.currentTimeMillis() + "}";
            synchronized (session) {
                if (session.isOpen()) {
                    session.getBasicRemote().sendText(connectMsg);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @OnMessage
    public void onMessage(String message, Session session, @PathParam("idCliente") String idCliente) {
        System.out.println("Mensaje recibido de " + idCliente + ": " + message);
    }

    @OnClose
    public void onClose(Session session, @PathParam("idCliente") String idCliente) {
        Set<Session> sessions = clientSessions.get(idCliente);
        if (sessions != null) {
            sessions.remove(session);
            if (sessions.isEmpty()) {
                clientSessions.remove(idCliente);
            }
        }
        System.out.println("WebSocket cerrado para cliente: " + idCliente + " - Sesion: " + session.getId());
    }

    @OnError
    public void onError(Session session, Throwable error, @PathParam("idCliente") String idCliente) {
        System.err.println("Error en WebSocket para cliente " + idCliente + ": " + error.getMessage());
        Set<Session> sessions = clientSessions.get(idCliente);
        if (sessions != null) {
            sessions.remove(session);
        }
    }

    /**
     * Envia notificacion de cambio de estado de pedido a un cliente.
     */
    public static void notificarCliente(String idCliente, String mensaje) {
        notificarCliente(idCliente, "pedido_estado", mensaje, null);
    }

    /**
     * Envia notificacion con tipo especifico a un cliente.
     */
    public static void notificarCliente(String idCliente, String tipo, String mensaje, Integer idPedido) {
        String jsonNotif = construirJsonNotificacion(tipo, mensaje, idPedido);
        Set<Session> sessions = clientSessions.get(idCliente);

        if (sessions != null && !sessions.isEmpty()) {
            for (Session session : sessions) {
                if (session.isOpen()) {
                    try {
                        synchronized (session) {
                            session.getBasicRemote().sendText(jsonNotif);
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        } else {
            ConcurrentLinkedDeque<String> pendientes = notificacionesPendientes
                    .computeIfAbsent(idCliente, k -> new ConcurrentLinkedDeque<>());
            pendientes.addLast(jsonNotif);
            while (pendientes.size() > MAX_NOTIFICACIONES_HISTORIAL) {
                pendientes.pollFirst();
            }
        }
    }

    /**
     * Envia notificacion de chat a un cliente.
     */
    public static void notificarChat(String idCliente, String remitente, String mensaje) {
        String json = "{\"tipo\":\"chat\",\"mensaje\":\"" + escapeJson(mensaje)
                + "\",\"remitente\":\"" + escapeJson(remitente)
                + "\",\"timestamp\":" + System.currentTimeMillis() + "}";
        notificarClienteRaw(idCliente, json);
    }

    /**
     * Verifica si un cliente tiene sesiones activas.
     */
    public static boolean estaConectado(String idCliente) {
        Set<Session> sessions = clientSessions.get(idCliente);
        return sessions != null && !sessions.isEmpty();
    }

    /**
     * Obtiene el numero de sesiones activas de un cliente.
     */
    public static int contarSesiones(String idCliente) {
        Set<Session> sessions = clientSessions.get(idCliente);
        return sessions != null ? sessions.size() : 0;
    }

    private static void notificarClienteRaw(String idCliente, String json) {
        Set<Session> sessions = clientSessions.get(idCliente);
        if (sessions != null && !sessions.isEmpty()) {
            for (Session session : sessions) {
                if (session.isOpen()) {
                    try {
                        synchronized (session) {
                            session.getBasicRemote().sendText(json);
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        } else {
            ConcurrentLinkedDeque<String> pendientes = notificacionesPendientes
                    .computeIfAbsent(idCliente, k -> new ConcurrentLinkedDeque<>());
            pendientes.addLast(json);
            while (pendientes.size() > MAX_NOTIFICACIONES_HISTORIAL) {
                pendientes.pollFirst();
            }
        }
    }

    private static String construirJsonNotificacion(String tipo, String mensaje, Integer idPedido) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"tipo\":\"").append(escapeJson(tipo)).append("\"");
        sb.append(",\"mensaje\":\"").append(escapeJson(mensaje)).append("\"");
        sb.append(",\"timestamp\":").append(System.currentTimeMillis());
        if (idPedido != null) {
            sb.append(",\"idPedido\":").append(idPedido);
        }
        switch (tipo) {
            case "pedido_estado":
                sb.append(",\"icono\":\"fa-truck\"");
                sb.append(",\"color\":\"info\"");
                break;
            case "pedido_entregado":
                sb.append(",\"icono\":\"fa-check-circle\"");
                sb.append(",\"color\":\"success\"");
                break;
            case "pedido_cancelado":
                sb.append(",\"icono\":\"fa-times-circle\"");
                sb.append(",\"color\":\"danger\"");
                break;
            case "chat":
                sb.append(",\"icono\":\"fa-comment\"");
                sb.append(",\"color\":\"aqua\"");
                break;
            case "sistema":
                sb.append(",\"icono\":\"fa-bell\"");
                sb.append(",\"color\":\"warning\"");
                break;
            default:
                sb.append(",\"icono\":\"fa-bell\"");
                sb.append(",\"color\":\"aqua\"");
                break;
        }
        sb.append("}");
        return sb.toString();
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
