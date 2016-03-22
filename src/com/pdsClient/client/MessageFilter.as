package com.pdsClient.client
{
	import com.pdsClient.util.PDSByteArray;
	
	import flash.events.EventDispatcher;

    public class MessageFilter extends EventDispatcher {
        private var messageBuffer:PDSByteArray;

        public function MessageFilter() {
            messageBuffer=new PDSByteArray();
        }

        public function receive(buf:PDSByteArray, client:SimpleClient):void
        {
            //Stuff any new bytes into the buffer
            messageBuffer.writeBytes(buf, 0, buf.length);
            messageBuffer.position=0;

            while (messageBuffer.bytesAvailable > 2)
        	{
                var payloadLength:int=messageBuffer.readShort();

                if (messageBuffer.bytesAvailable >= payloadLength)
                {
                        var newMessage:PDSByteArray=new PDSByteArray();
                        messageBuffer.readBytes(newMessage, 0, payloadLength);
                        var event:PDSClientEvent=new PDSClientEvent(PDSClientEvent.RAW_MESSAGE);
                        event.rawMessage=newMessage;
                        dispatchEvent(event);
                }
                else
                {
                        //Roll back the length we read
                        messageBuffer.position-=2;
                        break;
                }
            }

            var newBuffer:PDSByteArray=new PDSByteArray();
            newBuffer.writeBytes(messageBuffer, messageBuffer.position, messageBuffer.bytesAvailable);
            messageBuffer=newBuffer;
        }
    }
}