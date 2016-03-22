package gamestone.events
{
	import flash.events.Event;
	
	public class LoaderEvent extends Event
	{
		/**
		 *Dispatched when initial image loading is completed. 
		 */		
		public static const ASSET_LOADED:String = "assetLoaded";
		/**
		 *Dispatched when all external images are loaded. 
		 */		
		public static const EXTERNAL_ASSETS_COMPLETE:String = "externalAssetsComplete";
		
		private var _current:int;
		private var _total:int;
		
		public function LoaderEvent(type:String, current:int = 0, total:int = 0, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_current = current;
			_total = total;
		}
		
		public function get current():int
		{
			return _current;
		}
		
		public function get total():int
		{
			return _total;
		}
		
		public override function clone():Event {
			return new LoaderEvent(type, _current, _total, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("LoaderEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}