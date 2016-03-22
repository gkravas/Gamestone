package gamestone.utils {
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import gamestone.events.AssetLoaderEvent;
	import gamestone.graphics.AnimLoader;
	import gamestone.graphics.ImgLoader;
	import gamestone.localization.LocalizationDictionary;
	import gamestone.sound.SoundLoader;

	public class AssetLoader extends EventDispatcher {
				
		public static const DICTIONARY:String = "dictionary";
		public static const IMAGES:String = "images";
		public static const ANIMATIONS:String = "animations";
		public static const SOUNDS:String = "sounds";
		public static const NETWORK:String = "network";
		
		private static var _this:AssetLoader;
		private static var _embededModule:AssetLoader;
		
		private var currentLoader:uint;
		private var loaders:Array;
		private var files:Array;
		
		public function AssetLoader(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("AssetLoader cannot be instantiated externally. getInstance() method must be used instead.");
				return null;
			}
			loaders = [];
			files = [];
			currentLoader = 0;
		}
		
		public static function getInstance():AssetLoader {
			if (AssetLoader._this == null)
				AssetLoader._this = new AssetLoader(new PrivateClass);
			return AssetLoader._this;
		}
		
		public function addLoader(loader:AbstractLoader, file:String):void {
			storeLoaderObj(loader, file);
		}
		
		public function enableLoader(type:String, file:String):AbstractLoader {
			var loader:AbstractLoader;
			switch (type) {
				
				case AssetLoader.DICTIONARY:
				loader = LocalizationDictionary.getInstance();
				break;
				
				case AssetLoader.IMAGES:
				loader = ImgLoader.getInstance();
				break;
				
				case AssetLoader.ANIMATIONS:
				loader = AnimLoader.getInstance();
				break;
				
				case AssetLoader.SOUNDS:
				loader = SoundLoader.getInstance();
				break;
			}
			storeLoaderObj(loader, file);
			return loader;
		}
		
		public function load():void {
			loadNext();
		}
		
		private function storeLoaderObj(loader:AbstractLoader, file:String):void {
			loader.addEventListener(Event.COMPLETE, loaderDone, false, 0, true);
			loaders.push(loader);
			files.push(file);
		}
		
		private function loadNext():void {
			var loader:AbstractLoader = AbstractLoader(loaders[currentLoader]);
			loader.load(files[currentLoader]);
		}
		
		private function loaderDone(event:Event):void {
			DebugX.MyTrace(event.currentTarget.name);
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.LOADER_COMPLETE, (event.currentTarget as AbstractLoader).name));
			if (++currentLoader == loaders.length)
				assetsLoaded()
			else
				loadNext();
		}
		
		private function assetsLoaded():void {
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.ASSET_LOADING_COMPLETE));
		}
	
	
	
	}
	
}

class PrivateClass {}