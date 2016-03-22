package com.pdsClient.protocol {
	import flash.utils.ByteArray;
	
	
	public class ApplicationProtocolMessage {
		
		public static const STRING:String = "string";
		public static const INT:String = "int";
		public static const SHORT:String = "short";
		public static const LONG:String = "long";
		public static const FLOAT:String = "float";
		public static const DOUBLE:String = "double";
		public static const BOOLEAN:String = "bool";
		
		public var id:int;
		public var name:String;
		
		public var fields:Array;
		
		public function ApplicationProtocolMessage() {
			fields = [];
		}
		
		public function addField(name:String, type:String):void {
			fields.push({name:name, type:type});
		}
	}
}