package chat;

import java.io.IOException;
import java.util.Map;
import java.util.HashMap;
import java.util.concurrent.CopyOnWriteArraySet;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.eclipse.jetty.server.Request;

import org.eclipse.jetty.websocket.WebSocket;
import org.eclipse.jetty.websocket.WebSocketHandler;

/**
 * Normal user : only "j" paremeter is admitted. 
 * Administrator : "j" and "a" parameters are admitted. "A" represents an unique administrator
 * key.
 * 
 * 
 * 
 */
/**
 * TODOS : 
 * - faire en sorte que l'administrateur reçoive tous les messages qui lui sont adressés
 * - faire en sorte que dans le cas d'une déconnexion de l'administrateur, tous ses destinataires soient déconnectés aussi
 * - échanger les messages avec le navigateur en JSON
 */
public class ChatWebSocketHandler extends WebSocketHandler
{
    // separator included to message : allow to get the receiver
    private final String separator = "---LOGIN---";
    private final Map<String, ChatWebSocket> webSockets = new HashMap<String, ChatWebSocket>();
    public ChatWebSocketHandler()
    {
        System.out.println("Creating ChatWebSocketHandler");
    }

    public WebSocket doWebSocketConnect(HttpServletRequest request, String protocol)
    {
        System.out.println("REQ " + request.getParameter("j"));
        System.out.println("Doing websocketConnect" + protocol);
        return new ChatWebSocket((String)request.getParameter("j"), request.getParameter("904KFLO_201K4"));
    }

    private class ChatWebSocket implements WebSocket.OnTextMessage
    {
        private Connection connection;
        private String key;
        private boolean isAdmin;
        
        public ChatWebSocket(String key, String adminKey)
        {
            System.out.println("Creating ChatWebSocket");
            setKey(key);
        }

        public void onOpen(Connection connection)
        {
            System.out.println("Client ["+key+"] tried to open a connection");
            // Client (Browser) WebSockets has opened a connection.
            // 1) Store the opened connection
            this.connection = connection;
            // 2) Add ChatWebSocket in the global list of ChatWebSocket
            // instances instance.
            // webSockets.add(this);
            webSockets.put(getKey(), this);
        }

        public void onMessage(String message)
        {
            System.out.println("Someone ["+key+"] send a message " + message);
            // ChatWebSocket instance of message receiver
            // this represents instance of sender
            ChatWebSocket receiverWebSocket = null;
            try
            {
                String[] parts = message.split(separator);
                receiverWebSocket = webSockets.get(parts[0]);
                // construct final message (without receiver informations)
                int startIndex = parts[0].length() + separator.length();
                message = getKey()+"--FROM--"+message.substring(startIndex);
                // send a message to the current client WebSocket.
                this.connection.sendMessage(message);
                if(receiverWebSocket != null)
                {
                    System.out.println("Found message receiver " + parts[0]);
                    // send a message to the current client WebSocket.
                    receiverWebSocket.getConnection().sendMessage(message);
                }
                System.out.println("Sending a message " + message);
            }
            catch(IOException x)
            {
                // Error was detected, close the ChatWebSocket client side
                this.connection.disconnect();
                if(receiverWebSocket != null && getIsAdmin())
                {
                    receiverWebSocket.getConnection().disconnect();
                }
            }
        }

        public void onClose(int closeCode, String message)
        {
            System.out.println("Someone ["+key+"] closed a connection " + message);
            // Remove ChatWebSocket in the global list of ChatWebSocket instance.
            webSockets.remove(getKey());
        }
        
        public void setKey(String key)
        {
            this.key = key;
        }
        
        public String getKey()
        {
            return key;
        }
        
        public void setIsAdmin(String adminKey)
        {
            isAdmin = (adminKey != null);
        }
        
        public boolean getIsAdmin()
        {
            return isAdmin;
        }
        
        public Connection getConnection()
        {
            return connection;
        }
    }
}