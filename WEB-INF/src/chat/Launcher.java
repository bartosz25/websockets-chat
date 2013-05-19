package chat;

import org.eclipse.jetty.server.Server;
import java.net.InetSocketAddress;
import org.eclipse.jetty.server.handler.DefaultHandler;

public class Launcher 
{ 
	public static void main(String[] args) {
        System.out.println("Before server starting");
		try {
		    InetSocketAddress address = new InetSocketAddress("127.0.0.1", 12); 
			// 1) Create a Jetty server with the 8081 port.
			// Server server = new Server(8081);
			Server server = new Server(address);
			// 2) Register ChatWebSocketHandler in the Jetty server instance.
			ChatWebSocketHandler chatWebSocketHandler = new ChatWebSocketHandler();
			chatWebSocketHandler.setHandler(new DefaultHandler());
			server.setHandler(chatWebSocketHandler);
			server.start();
			System.out.println("Server started");
			// Jetty  server is stopped when the Thread is interruped.
			server.join();
			System.out.println("Server joint");
		} catch (Throwable e) {
            System.out.println("An error occured");
			e.printStackTrace();
		}
	}  
    
}