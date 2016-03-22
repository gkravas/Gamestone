package com.pdsClient.util
{
	import com.pdsClient.util.PDSByteArray;
	
	public class XMLPacketier
	{
		public function XMLPacketier()
		{
		}
		
		public static function createXMLSGSPacket(args:Object, properties:Array):PDSByteArray {
			var ba:PDSByteArray = new PDSByteArray();
			var msg:String = "<msg>";
			for each(var property:String in properties) {
				msg += createXMLChild(property, args[property]);
			}
			msg += "</msg>";
			trace("-->XML Message :" + msg.toString());
			ba.writeUTF(msg);
			//ba.compress(CompressionAlgorithm.DEFLATE);
			return ba;
		}
		
		public static function createXMLChild(name:String, value:String):String {
			return "<" + name + ">" + value + "</" + name + ">";
		}
	}
}