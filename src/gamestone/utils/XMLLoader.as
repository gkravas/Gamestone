package gamestone.utils {
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;

	public class XMLLoader extends AbstractLoader {
		
		protected var xmlLoader:URLLoader;

		public function XMLLoader() {
			
		}
		
		public override function load(file:String):void {
			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
			xmlLoader.load(new URLRequest(file));
		}
		
		private function ioError(event:IOErrorEvent):void {
			throw new Error("XMLLoader IOError, file: " + event.type + "\n" + event.text);
		}
		
		protected function xmlLoaded(e:Event):void {
			xmlLoader = null;
			dispatchCompleteEvent();
		}
	
	
	
	}
	
}