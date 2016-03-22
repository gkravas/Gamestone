package gamestone.events {
	
	import flash.events.Event;
	
	public class PackageManagerEvent extends Event
	{
		/**
		 *Being dispatched during progress of loading 
		 */		
		public static const PROGRESS:String = "progress";
		
		private var _progress:Number;
		
		public function PackageManagerEvent(type:String, _progress:Number = 0, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_progress = progress;
		}
		
		public function get progress():Number
		{
			return _progress;
		}
		
		public override function clone():Event {
			return new PackageManagerEvent(type, _progress, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("PackageManagerEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}