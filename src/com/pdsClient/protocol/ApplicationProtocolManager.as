package com.pdsClient.protocol
{
	import com.pdsClient.util.PDSByteArray;
	
	import flash.errors.IllegalOperationError;
	
	public class ApplicationProtocolManager
	{
		private static var _this:ApplicationProtocolManager;
		private static var apLoader:ApplicationProtocolLoader;
		
		public function ApplicationProtocolManager(pvt:PrivateClass)
		{
			if (pvt == null)
			{
				throw new IllegalOperationError("ApplicationProtocol cannot be instantiated externally. ApplicationProtocol.getInstance() method must be used instead.");
				return null;
			}
			apLoader = ApplicationProtocolLoader.getInstance();
		}
		
		public static function getInstance():ApplicationProtocolManager
		{
			if (ApplicationProtocolManager._this == null)
				ApplicationProtocolManager._this = new ApplicationProtocolManager(new PrivateClass());
			return ApplicationProtocolManager._this;
		}
		
		public function parseMessage(message:PDSByteArray): Object {
			var o:Object;
			var apMSG:ApplicationProtocolMessage = apLoader.getMessageByID(message.readInt());
			o.id = apMSG.id;
			o.name = apMSG.name;
			
			var field:Object;
			for each(field in apMSG.fields)
				o[field.name] = getField(field.type, message);
			return o;
		}
		
		public function createMessage(id:int, data:Array):PDSByteArray {
			var message:PDSByteArray = new PDSByteArray;
			var apMSG:ApplicationProtocolMessage = apLoader.getMessageByID(id);
			
			addField(ApplicationProtocolMessage.INT, id, message);
			
			var field:Object;
			var i:int = 0;
			for each(field in apMSG.fields) {
				addField(field.type, data[i], message);
				i++;
			}
			return message;
		}
		
		protected function addField(type:String, data:*, message:PDSByteArray):void {
			switch (type) {
				case ApplicationProtocolMessage.STRING:
					message.writeUTF(data);
				break;
				case ApplicationProtocolMessage.INT:
					message.writeInt(data);
				break;
				case ApplicationProtocolMessage.FLOAT:
					message.writeFloat(data);
				break;
				case ApplicationProtocolMessage.DOUBLE:
					message.writeDouble(data);
				break;
				case ApplicationProtocolMessage.LONG:
					message.writeUnsignedInt(data);
				break;
				case ApplicationProtocolMessage.SHORT:
					message.writeShort(data);
				break;
				case ApplicationProtocolMessage.BOOLEAN:
					message.writeBoolean(data);
				break;
			}
		}
		
		protected function getField(type:String, message:PDSByteArray):* {
			var data:*;
			switch (type) {
				case ApplicationProtocolMessage.STRING:
					data = message.readUTF();
				break;
				case ApplicationProtocolMessage.INT:
					data = message.readInt();
				break;
				case ApplicationProtocolMessage.FLOAT:
					data = message.readFloat();
				break;
				case ApplicationProtocolMessage.DOUBLE:
					data = message.readDouble();
				break;
				case ApplicationProtocolMessage.LONG:
					data = message.readLong();
				break;
				case ApplicationProtocolMessage.SHORT:
					data = message.readShort();
				break;
				case ApplicationProtocolMessage.BOOLEAN:
					data = message.readBoolean();
				break;
			}
			return data;
		}
	}
} class PrivateClass {}