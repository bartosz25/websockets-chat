<html>

<head>

<title>Chat Client</title>

<link rel="stylesheet" type="text/css" href="css/style.css"
    media="screen" />


<script type="text/javascript" src="scripts/jquery-1.7.1.js"></script>


<script type="text/javascript">
    var ENTER_KEY = '13';
    var TOKEN_DELIM = "::::";
    
    

    
    function buildWebSocketURL() {
        var url = document.URL;
        var parts = url.split('/');
        var scheme = parts[0];
        var hostPort = parts[2];
        var wssScheme = null;
        
        
        if (scheme=="http:") {
            wssScheme="ws:";
        } else if (scheme=="https:") {
            wssScheme="wss:";
        }
        
        wssUrl = wssScheme + "//" + hostPort  + "/websockets/chat/chat";
        
        return wssUrl;
        
    }
    

    var chatUserSession = {
                version : "1.0",
                webSocketProtocol : "caucho-example-chat-protocol",
                webSocketURL : buildWebSocketURL(),
                webSocket : null,//WebSocket
                userName : null
    };

    function chat_sendMessage(message) {
        $("#chatHistory").prepend("<p style='color:green'> ME : " + message + "</p>");

        chatUserSession.webSocket.send("send message" + TOKEN_DELIM
                + chatUserSession.userName + TOKEN_DELIM + message);
    }

    function chat_joinChat() {
        chatUserSession.webSocket.send("add client" + TOKEN_DELIM
                + chatUserSession.userName);
    }

    function chat_leaveChat() {
        chatUserSession.status(chatUserSession.userName + " is leaving chat");
        chatUserSession.webSocket.send("remove client" + TOKEN_DELIM
                + chatUserSession.userName);
    }

    function chat_openWebSocket() {
        chatUserSession.webSocket = new WebSocket(chatUserSession.webSocketURL,
                chatUserSession.webSocketProtocol);
        var socket = chatUserSession.webSocket;

        socket.onmessage = function(msg) {
            chatUserSession.onMessage(msg);
        }

        socket.onerror = function(errorEvent) {
            chatUserSession.onError(errorEvent);
        }

        socket.onopen = function() {
            chatUserSession.onOpen();
        }
        socket.onclose = function(closeEvent) {
            chatUserSession.onClose(closeEvent);
        }

    }

    function chat_onMessage(msgEvent) {
        chatUserSession.status("New Message :" + msgEvent.data);

        $("#chatHistory").prepend("<p style='color:blue'>" + msgEvent.data + "</p>");
    }

    function chat_Login() {

        chatUserSession.userName = $("#userName").val();
        $("#loginDiv").hide(500);
        $('#header').text(
                "Chat Client (logging in...) : " + chatUserSession.userName);

        chatUserSession.status(chatUserSession.userName + " is logging in...");
        chatUserSession.open();

    }

    function chat_onOpen() {
        chatUserSession.joinChat();
        chatUserSession.status("Chat Client (logged in) : " + chatUserSession.userName);
          $('#header').text(
                    "Chat Client (logged in...) : " + chatUserSession.userName);

        $("#inputArea").show(500);
        $("#statusBar").show(500);
        $("#chatInput").focus();
    }
    
    function chat_Status(message) {
        $('#statusBarPara1').text(message);
        $("#statusBar").show(500);
        
    }

    function chat_onClose(closeEvent) {
        $("#loginDiv").show(500);
        $('#header').text(
                "Chat Client (not connected) : " + chatUserSession.userName);
        $('#statusBarPara1').text(chatUserSession.userName + " not logged in. " + 
                ":: Reason: " + closeEvent.reason + 
                " Code: " + closeEvent.code);

        $("#inputArea").hide(500);
        $("#statusBar").show(500);

        $("#userName").val(chatUserSession.userName);
        $("#userName").focus();
    }

    function chat_onError(msg) {
        $('#statusBarPara1').text(" Websocket error :" + JSON.stringfy(msg));
        $("#statusBar").show(500);
    }

    chatUserSession.open = chat_openWebSocket;
    chatUserSession.onMessage = chat_onMessage;
    chatUserSession.onOpen = chat_onOpen;
    chatUserSession.login = chat_Login;
    chatUserSession.onClose = chat_onClose;
    chatUserSession.onError = chat_onError;
    chatUserSession.joinChat = chat_joinChat;
    chatUserSession.sendMessage = chat_sendMessage;
    chatUserSession.leaveChat = chat_leaveChat;
    chatUserSession.status = chat_Status;

    $(document).ready(function() {

        $("#inputArea").hide();
        $("#userName").focus();
        
        

        $("#statusBar").click(function() {
            $("#statusBar").hide(300);
        });

        $("#chatInput").keypress(function(event) {

            var keycode = (event.keyCode ? event.keyCode : event.which);
            if (keycode == ENTER_KEY) {
                var textMessage = $("#chatInput").val();

                if (textMessage=="bye!") {
                    chatUserSession.leaveChat();
                } else {
                    $("#chatInput").val("");
                    $("#hint").hide(500);
                    chatUserSession.sendMessage(textMessage);
                }
            }
            event.stopPropagation();
        });

        $("#login").click(function(event) {
            chatUserSession.login();
            event.stopPropagation();
        });

        $("#userName").keypress(function(event) {
            var keycode = (event.keyCode ? event.keyCode : event.which);
            if (keycode == ENTER_KEY) {
                chatUserSession.login()
                event.stopPropagation();
            }
        });
    });
</script>

</head>

<body>

    <h1 id="header">Chat Client</h1>


    <div id="statusBar">
        <p id="statusBarPara1">Welcome to Chat App, Click to hide</p>
    </div>

    <div id="loginDiv">
        User name   <input id="userName" type="text" /> <input
            id="login" type="submit" value="Login" />
    </div>


    <div id="inputArea">
        <p id="hint">Type your message here and then hit return (entering in 'bye!' logs out)</p>
        <input id="chatInput" type="text" value="" />
    </div>

    <div id="chatHistoryDiv">
        <p id="chatHistory"></p>
    </div>


</body>

</html>