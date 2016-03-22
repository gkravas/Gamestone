package com.pdsClient.protocol {
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import gamestone.utils.XMLLoader;	
	
	public class ApplicationProtocolLoader extends XMLLoader {
				
		private static var _this:ApplicationProtocolLoader;
		
		private var messagesByID:Object;
		private var messagesByName:Object;
		
		public function ApplicationProtocolLoader(pvt:PrivateClass)
		{
			if (pvt == null)
			{
				throw new IllegalOperationError("ApplicationProtocolLoader cannot be instantiated externally. ApplicationProtocolLoader.getInstance() method must be used instead.");
				return null;
			}
			messagesByID = {};
			messagesByName = {};
		}
		
		public static function getInstance():ApplicationProtocolLoader
		{
			if (ApplicationProtocolLoader._this == null)
				ApplicationProtocolLoader._this = new ApplicationProtocolLoader(new PrivateClass());
			return ApplicationProtocolLoader._this;
		}
		
		protected override function xmlLoaded(e:Event):void
		{
			var xml:XML = XML(xmlLoader.data);
			xmlLoader = null;
			
			var messageType:XML;
			var field:XML;
			var data:XML;
			
			for each(messageType in xml.messageType) {
				var msg:ApplicationProtocolMessage = new ApplicationProtocolMessage();
				msg.id = parseInt(messageType.attribute("id"));
				msg.name = String(messageType.attribute("name"));
				for each(data in messageType.data)
					msg.addField(String(data.attribute("name")), String(data.attribute("type")));
					
				messagesByID[msg.id] = msg;
				messagesByName[msg.name] = msg;
			}
			super.xmlLoaded(e);
		}
		
		public function getMessageByID(id:int):ApplicationProtocolMessage {
			return messagesByID[id];
		}
		
		public function getMessageByName(name:String):ApplicationProtocolMessage {
			return messagesByName[name];
		}
	}
} class PrivateClass {}