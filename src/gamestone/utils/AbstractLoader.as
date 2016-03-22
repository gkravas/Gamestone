package gamestone.utils {
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	public class AbstractLoader extends EventDispatcher {
		
		protected static const _name:String = "AbstractLoader";
		 
		public function AbstractLoader() {
		}
		
		public function load(file:String):void {
			throw new IllegalOperationError("AbstractLoader cannot be instantiated, only subclassed.");
		}
		
		public function get name():String {
			return ArrayUtil.getLastElement(getQualifiedClassName(this).split(".")) as String;
		}
		
		protected function dispatchCompleteEvent():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
	
	
	
	}
	
}