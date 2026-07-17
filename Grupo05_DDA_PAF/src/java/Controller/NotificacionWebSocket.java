package Controller;

import jakarta.websocket.OnClose;
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

@ServerEndpoint("/notificaciones/{idCliente}")
public class NotificacionWebSocket {

    // Mapa para almacenar las sesiones por ID de cliente
    private static final ConcurrentHashMap<String, Set<Session>> clientSessions = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("idCliente") String idCliente) {
        clientSessions.computeIfAbsent(idCliente, k -> Collections.synchronizedSet(new HashSet<>())).add(session);
        System.out.println("WebSocket abierto para cliente: " + idCliente + " - Sesion: " + session.getId());
    }

    @OnMessage
    public void onMessage(String message, Session session, @PathParam("idCliente") String idCliente) {
        // En este caso, el cliente normalmente no enviara mensajes, 
        // pero podemos manejar mensajes si es necesario
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

    /**
     * Metodo estatico para enviar notificacion a un cliente especifico
     */
    public static void notificarCliente(String idCliente, String mensaje) {
        Set<Session> sessions = clientSessions.get(idCliente);
        if (sessions != null) {
            for (Session session : sessions) {
                if (session.isOpen()) {
                    try {
                        session.getBasicRemote().sendText(mensaje);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
