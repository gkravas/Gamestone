package gamestone.sound {
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import gamestone.events.LoaderEvent;
	import gamestone.events.SoundsEvent;
	import gamestone.utils.IEmbededAssets;
	import gamestone.utils.StringUtil;
	import gamestone.utils.XMLLoader;
	
	import mx.core.SoundAsset;
	
	public class SoundLoader extends XMLLoader{
		
		public static var embededAssets:IEmbededAssets;
		
		private static var _this:SoundLoader;
		private static var _basePath:String;
		private static var _defaultPath:String;
		private var totalSounds:int;
		private var loadedSounds:int;
		private var soundManager:SoundManager;
		
		public function SoundLoader(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("SoundLoader cannot be instantiated externally. CustomerColorLoader.getInstance() method must be used instead.");
				return null;
			}
			_defaultPath = "";
			_basePath = "";
			soundManager = SoundManager.getInstance();
		}
		
		public static function getInstance():SoundLoader {
			if (SoundLoader._this == null)
				SoundLoader._this = new SoundLoader(new PrivateClass());
			return SoundLoader._this;
		}
		
		protected override function xmlLoaded(e:Event):void {
			totalSounds = 0;
			loadedSounds = 0;
		
			soundManager.addEventListener(SoundsEvent.SOUND_LOADED, soundLoaded, false, 0, true);
			soundManager.addEventListener(IOErrorEvent.IO_ERROR, soundLoadError, false, 0, true);
			
			var sound:XML, sItem:SoundItem, sID:String, volume:Number;
			var xml:XML = XML(xmlLoader.data);
			
			var defaultGroup:String = xml.@defaultGroup;
			var defaultPath:String = xml.@defaultPath;
			if (defaultPath == "null")
				defaultPath = "";
			
			xmlLoader = null;
			
			var soundPath:String, group:String, volStr:String, embeded:Boolean;
			totalSounds = xml.sound.length();
			for each(sound in xml.sound) {
				
				sID = sound.@id;
				volStr = sound.@volume;
				if (volStr == null || volStr == "")
					volStr = "100";
				volume = Number(volStr)/100;
				
				soundPath = sound.@path;
				if (soundPath == null || soundPath == "")
					soundPath = defaultPath;
				
				group = sound.@group;
				if (group == null || group == "")
					group = defaultGroup;
				embeded = StringUtil.parseBoolean(sound.@embeded);
				if (!embeded)
					sItem = soundManager.load(sID, _basePath + soundPath + sID + ".mp3", 1, volume);
				else
					sItem = soundManager.addEmbededSound(sID, embededAssets.getAsset(sID) as SoundAsset, 1, volume);
				
				addToSoundGroup(group, sID);
				sItem.volume = volume;
				sItem.setStartingVolume(volume);
				sItem.allowMultiple = StringUtil.parseBoolean(sound.@multiple);
			}
		}
		
		private function addToSoundGroup(groupID:String, soundID:String):void {
			// will only add if group does not exist
			soundManager.addGroup(groupID);
			soundManager.addToSoundGroup(groupID, soundID);
		}
		
		public function set basePath(path:String):void {
			_basePath = path;
		}
		
		private function soundLoaded(event:SoundsEvent):void {
			loadedSounds++;
			checkProgress();
		}
		
		private function soundLoadError(event:IOErrorEvent):void {
			totalSounds--;
			checkProgress();
		}
		
		private function checkProgress():void {
			dispatchEvent(new LoaderEvent(LoaderEvent.ASSET_LOADED, loadedSounds, totalSounds));
			if(loadedSounds == totalSounds)
				super.xmlLoaded(new Event(Event.COMPLETE));
		}
	}
}

class PrivateClass {}