package gamestone.utils {
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;	
	
	public class InjectionsLoader extends XMLLoader {
		
		private static var _this:InjectionsLoader;
		
		public var xmlConfiguration:XML;
		
		public function InjectionsLoader(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("EntityLoader cannot be instantiated externally. EntityLoader.getInstance() method must be used instead.");
				return null;
			}
		}
		
		public static function getInstance():InjectionsLoader {
			if (InjectionsLoader._this == null)
				InjectionsLoader._this = new InjectionsLoader(new PrivateClass());
			return InjectionsLoader._this;
		}
		
		protected override function xmlLoaded(e:Event):void {
			var xml:XML = XML(xmlLoader.data);
			xmlConfiguration = xml
			super.xmlLoaded(e);
		}
	}
}
class PrivateClass {}