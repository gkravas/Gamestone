package gamestone.events
{
	import flash.events.Event;
	
	public class AssetLoaderEvent extends Event
	{
		/**
		 *Dispatched when initial image loading is completed. 
		 */		
		public static const LOADER_COMPLETE:String = "loaderComplete";
		/**
		 *Dispatched when all external images are loaded. 
		 */		
		public static const ASSET_LOADING_COMPLETE:String = "assetLoadingComplete";
		
		private var _loaderName:String;
		
		public function AssetLoaderEvent(type:String, loaderName:String = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_loaderName = loaderName;
		}
		
		public function get loaderName():String
		{
			return _loaderName;
		}
		
		public override function clone():Event {
			return new AssetLoaderEvent(type, _loaderName, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("AssetLoaderEvent", "type", "bubbles", "cancelable", "eventPhase");
		}

	}
}