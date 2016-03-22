package com.pdsClient.client
{
	import com.pdsClient.protocol.SimplePDSProtocol;
	import com.pdsClient.util.HashMap;
	import com.pdsClient.util.PDSByteArray;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;

    public class SimpleClient extends EventDispatcher {

        //Currently unused
        private var reconnectKey:ByteArray;
        private var channels:HashMap;
        private var sock:Socket;
        private var host:String;
        private var port:int;
        private var username:String;
        private var passwd:String;
        private var messageFilter:MessageFilter;


        /**
         * Constructs the SimpleClient. The provided host and port
         * will be used to connect when the login() method is called
         */
        public function SimpleClient(host:String, port:int) {
        	reconnectKey = new ByteArray();
	        channels = new HashMap();
	        sock = new Socket();
	        
            this.host=host;
            this.port=port;
            sock.addEventListener(Event.CLOSE, onClose);
            sock.addEventListener(Event.CONNECT, onConnect);
            sock.addEventListener(ProgressEvent.SOCKET_DATA, onData);
            messageFilter=new MessageFilter();
            messageFilter.addEventListener(PDSClientEvent.RAW_MESSAGE, onRawMessage);
        }

        /**
         *  Reqest a login with the specified username and password.
         */
        public function login(username:String, passwd:String):void {
            sock.connect(host, port);
            this.username = username;
            this.passwd = passwd;
        }

        /**
         *  Sends a message to the specified channel.
         */
        public function channelSend(channel:ClientChannel, message:ByteArray):void {
            var buf:ByteArray=new ByteArray();
            buf.writeByte(SimplePDSProtocol.CHANNEL_MESSAGE);
            buf.writeShort(channel.rawId.length);
            buf.writeBytes(channel.rawId);
            buf.writeBytes(message);
            buf.position=0;
            sock.writeShort(buf.length);
            sock.writeBytes(buf);
            sock.flush();
        }

        /**
         * Returns a list of channels a client has currently joined.
         */
        public function getChannels():Array {
                return channels.getValues();
        }

        /**
         *  Sends message to sgs over the session connection
         */
        public function sessionSend(message:ByteArray):void {
                var buf:ByteArray=new ByteArray();
                buf.writeByte(SimplePDSProtocol.SESSION_MESSAGE);
                buf.writeBytes(message);
                sock.writeShort(buf.length);
                sock.writeBytes(buf);
                sock.flush();
        }

        public function logout(force:Boolean=false):void {
                if (force)
                {
                        sock.close();
                }
                else
                {
                        var buf:ByteArray=new ByteArray();
                        buf.writeByte(SimplePDSProtocol.LOGOUT_REQUEST);
                        sock.writeShort(buf.length);
                        sock.writeBytes(buf);
                        sock.flush();
                }
        }


        private function onClose(event:Event):void {
                dispatchEvent(new PDSClientEvent(PDSClientEvent.LOGOUT));
        }

        /**
         * Once the connection is established, we can complete the login
         */
        private function onConnect(event:Event):void {
                var buf:ByteArray=new ByteArray();
                buf.writeByte(SimplePDSProtocol.LOGIN_REQUEST);
                buf.writeByte(SimplePDSProtocol.VERSION);
                buf.writeUTF(username);
                buf.writeUTF(passwd);
                sock.writeShort(buf.length);
                sock.writeBytes(buf);
                sock.flush();
        }

        private function onData(event:ProgressEvent):void {
                trace("SimpleClient.onData(): received [" + event.bytesLoaded + "] bytes");
                var buf:PDSByteArray=new PDSByteArray();
                sock.readBytes(buf, 0, sock.bytesAvailable);
                messageFilter.receive(buf, this);
        }

        public function onRawMessage(e:PDSClientEvent):void {
                receivedMessage(e.rawMessage);
        }


        /**
         * This is the heart of the SimpleClient.  The method reads
         * the incoming data, parses the commands based on the SimplePDSProtocol byte
         * and dispatches events
         *
         */
        private function receivedMessage(message:PDSByteArray):void {
            var command:int = message.readByte();
            var e:PDSClientEvent = null;
            var buf:ByteArray = new ByteArray();
            var channel:ClientChannel;

            if (command == SimplePDSProtocol.LOGIN_SUCCESS)
            {
                //TODO reconnectkey support?
                message.readBytes(reconnectKey);
                dispatchEvent(new PDSClientEvent(PDSClientEvent.LOGIN_SUCCESS));
            }

            else if (command == SimplePDSProtocol.LOGIN_FAILURE)
            {
                e=new PDSClientEvent(PDSClientEvent.LOGIN_FAILURE);
                e.failureMessage = message.readPDSString();
                dispatchEvent(e);
            }

            else if (command == SimplePDSProtocol.LOGIN_REDIRECT)
            {
                var newHost:String = message.readPDSString();
                var newPort:int = message.readInt();
                e = new PDSClientEvent(PDSClientEvent.LOGIN_REDIRECT);
                e.host = newHost;
                e.port = newPort;
                dispatchEvent(e);
            }

            else if (command == SimplePDSProtocol.RECONNECT_SUCCESS)
            {
                //TODO reconnectkey support?
                reconnectKey = new ByteArray();
                message.readBytes(reconnectKey);
                dispatchEvent(new PDSClientEvent(PDSClientEvent.RECONNECT_SUCCESS));
            }

            else if (command == SimplePDSProtocol.RECONNECT_FAILURE)
            {
                e=new PDSClientEvent(PDSClientEvent.RECONNECT_FAILURE);
                e.failureMessage=message.readPDSString();
                dispatchEvent(e);
            }

            else if (command == SimplePDSProtocol.SESSION_MESSAGE)
            {
                message.readBytes(buf);
                e=new PDSClientEvent(PDSClientEvent.SESSION_MESSAGE);
                e.sessionMessage=buf;
                dispatchEvent(e);
            }
            else if (command == SimplePDSProtocol.LOGOUT_SUCCESS)
            {
                e=new PDSClientEvent(PDSClientEvent.LOGOUT);
                dispatchEvent(e);
            }
            else if (command == SimplePDSProtocol.CHANNEL_JOIN)
            {
                var channelName:String=message.readPDSString();
                message.readBytes(buf);
                channel=new ClientChannel(channelName, buf);
                channels.put(channel.id, channel);
                e=new PDSClientEvent(PDSClientEvent.CHANNEL_JOIN);
                e.channel=channel;
                dispatchEvent(e);
            }
            else if (command == SimplePDSProtocol.CHANNEL_MESSAGE)
            {
                //Read channelId bytes
                message.readBytes(buf, 0, message.readUnsignedShort());
                channel=channels.getValue(ClientChannel.bytesToChannelId(buf));
                buf=new ByteArray();
                message.readBytes(buf);
                e=new PDSClientEvent(PDSClientEvent.CHANNEL_MESSAGE);
                e.channel=channel;
                e.channelMessage=buf;
                dispatchEvent(e);
            }
            else if (command == SimplePDSProtocol.CHANNEL_LEAVE)
            {
                //Read channelId bytes
                message.readBytes(buf);
                channel=channels.getValue(ClientChannel.bytesToChannelId(buf));

                if (channel != null)
                {
                        channels.remove(channel.id);
                        e=new PDSClientEvent(PDSClientEvent.CHANNEL_LEAVE);
                        e.channel=channel;
                        dispatchEvent(e);
                }
            }
            else
            {
            	throw new Error("Undefined protocol command:" + command);
            }
        }
    }
}