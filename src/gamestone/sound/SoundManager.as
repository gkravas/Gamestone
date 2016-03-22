package gamestone.sound {
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import gamestone.events.SoundsEvent;
	import gamestone.utils.ArrayUtil;
	
	import mx.core.SoundAsset;

	public final class SoundManager extends EventDispatcher {
		
		private static var _this:SoundManager;
		
		private var sounds:Object;
		private var _playLists:Object;
		private var groups:Object;
		
		private var soundTransform:SoundTransform;
		private var _fadeOutTime:int;
		private var _fadeInTime:int;
		
		private var timer:Timer;
		//private var interval:Number;
		
		//private var monitoringSounds:Object;
		private var fadingInSounds:Array, fadingOutSounds:Array;
		
		public function SoundManager(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("SoundManager cannot be instantiated externally. SoundManager.getInstance() must be used instead.");
				return null;
			}
			init();
		}
		
		public static function getInstance():SoundManager {
			if (SoundManager._this == null)
				SoundManager._this = new SoundManager(new PrivateClass());
			return SoundManager._this;
		}
		
		private function init():void {
			sounds = {};
			groups = {};
			_fadeOutTime = 5000;
			_fadeInTime = 4000;
			soundTransform = new SoundTransform(1, 0);
			SoundMixer.soundTransform = soundTransform;
			
			fadingInSounds = [];
			fadingOutSounds = [];
			timer = new Timer(SoundItem.FADE_TIME_STEP);
			timer.addEventListener(TimerEvent.TIMER, repeat, false, 0, true);
			timer.start();
			//ActionManager.getInstance().addAction(ActionManager.SOUND, repeat, SoundItem.FADE_TIME_STEP, -1);
		}
		
		public function load(id:String, file:String, loops:int = 1, volume:Number = 1, autoPlay:Boolean = false):SoundItem {
			if (sounds[id] != null) {
			}
			
			var s:MySound = new MySound(id);
			s.load(new URLRequest(file));
			s.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadError, false, 0, true);
			s.addEventListener(Event.COMPLETE, onSoundLoaded, false, 0, true);
			s.loops = loops;
			s.autoPlay = autoPlay;
			s.volume = volume;
			
			var sound:SoundItem = sounds [id] = new SoundItem(id, s);
			
			sound.addEventListener(SoundItemEvent.FADE_OUT, fadeOutSound, false, 0, true);
			sound.addEventListener(SoundItemEvent.FADE_IN, fadeInSound, false, 0, true);
			sound.addEventListener(SoundItemEvent.FADE_OUT_COMPLETE, fadeOutSoundComplete, false, 0, true);
			sound.addEventListener(SoundItemEvent.FADE_IN_COMPLETE, fadeInSoundComplete, false, 0, true);
			
			//sound.setFadeOutTime(_fadeOutTime);
			//sound.setFadeInTime(_fadeInTime);
			return sound;
		}
		
		public function addEmbededSound(id:String, soundAsset:SoundAsset, loops:int = 1, volume:Number = 1, autoPlay:Boolean = false):SoundItem {
			if (sounds[id] != null) {
			}
			
			var s:MySound = MySound.MySoundFromEmbeded(id, soundAsset);
			
			s.loops = loops;
			s.autoPlay = autoPlay;
			s.volume = volume;
			
			var sound:SoundItem = sounds [id] = new SoundItem(id, s);
			
			sound.addEventListener(SoundItemEvent.FADE_OUT, fadeOutSound, false, 0, true);
			sound.addEventListener(SoundItemEvent.FADE_IN, fadeInSound, false, 0, true);
			sound.addEventListener(SoundItemEvent.FADE_OUT_COMPLETE, fadeOutSoundComplete, false, 0, true);
			sound.addEventListener(SoundItemEvent.FADE_IN_COMPLETE, fadeInSoundComplete, false, 0, true);
			
			embededSoundAdded(s);
			//sound.setFadeOutTime(_fadeOutTime);
			//sound.setFadeInTime(_fadeInTime);
			return sound;
		}
		
		public function loadAndPlay(id:String, file:String, loops:int = 0, volume:Number = 1):SoundItem {
			return load(id, file, loops, volume, true);
		}
		
		public function playSound(id:String, offset:Number = 0, loops:int = 1):Boolean {
			var sound:SoundItem = sounds[id] as SoundItem;
			try {
				return sound.play(offset, loops);
			} catch(error:TypeError) {
				trace("Sound with id=" + id + " does not exist in SoundManager.playSound.");
				return false;
			}
			
			return false;
		}
		
		public function stopSound(id:String, fadeOut:Boolean):void {
			var sound:SoundItem = sounds[id] as SoundItem;
			try {
				if (fadeOut)
					sound.fadeOut();
				else
					sound.stop();
			} catch(error:TypeError) {
				trace("Sound with id=" + id + " does not exist in SoundManager.stopSound.");
			}
		}
		
		public function addGroup(id:String):void {
			if (groups[id] == null)
				groups[id] = new SoundGroup(id);
		}
		
		public function addToSoundGroup(groupID:String, soundID:String):void {
			var group:SoundGroup = groups[groupID] as SoundGroup;
			var sound:SoundItem = getSound(soundID);
			var err:Boolean = false;
			if (sound == null) {
				trace("Error: SoundManager.addToSoundGroup(), sound with id=" + soundID + " does not exist.");
				err = true;
			}
			if (group == null) {
				trace("Error: SoundManager.addToSoundGroup(), group with id=" + groupID + " does not exist.");
				err = true;
			}
			if (err)
				return;
			
			sound.soundGroup = group;
		}
		
		public function setSoundGroupVolume(groupID:String, vol:Number):void {
			var group:SoundGroup = groups[groupID] as SoundGroup;
			if (group != null) {
				group.volume = vol;
				var arr:Array = getSoundsByGroup(groupID);
				var sound:SoundItem;
				for each (sound in arr)
					sound.updateVolume();
			}
			else
				trace("Error: SoundGroup with id=" + groupID + " does not exist. setSoundGroupVolume() failed.");
		}
		
		public function setSoundGroupPan(groupID:String, pan:Number):void {
			var group:SoundGroup = groups[groupID] as SoundGroup;
			if (group != null)
				group.pan = pan;
			else
				trace("Error: SoundGroup with id=" + groupID + " does not exist. setSoundGroupPan() failed.");
		}
		
		public function getSoundsByGroup(groupID:String):Array {
			var group:SoundGroup = groups[groupID] as SoundGroup;
			var arr:Array = [], sound:SoundItem;
			for each(sound in sounds) {
				if (sound.soundGroup == group)
					arr.push(sound);
			}
			
			return arr;
		}
		
		public function getSoundIDsByGroup(groupID:String):Array {
			var group:SoundGroup = groups[groupID] as SoundGroup;
			var arr:Array = [], sound:SoundItem;
			for each(sound in sounds) {
				if (sound.soundGroup == group)
					arr.push(sound.id);
			}
			
			return arr;
		}
		
		
		private function repeat(event:Event):void {
			var obj:Object;
			for each(obj in fadingInSounds)
				SoundItem(sounds[obj.id]).fadeInVolume(obj.step);
			for each(obj in fadingOutSounds)
				SoundItem(sounds[obj.id]).fadeOutVolume(obj.step);
		}
		
		
		// EVENTS ----------------------------------------------
		
		private function onSoundLoadError(event:IOErrorEvent):void {
			trace(event.text);
			dispatchEvent(event);
		}
		
		private function onSoundLoaded(event:Event):void {
			var s:MySound = MySound(event.target);
			var sound:SoundItem = sounds[s.id];
			if (s.autoPlay)
				sound.play(0, s.loops);
			dispatchEvent(new SoundsEvent(SoundsEvent.SOUND_LOADED, s.id));
		}
		
		private function embededSoundAdded(s:MySound):void {
			var sound:SoundItem = sounds[s.id];
			if (s.autoPlay)
				sound.play(0, s.loops);
			dispatchEvent(new SoundsEvent(SoundsEvent.SOUND_LOADED, s.id));
		}
		
		private function fadeOutSound(event:SoundItemEvent):void {
			fadingOutSounds.push({id:event.id, step:event.volumeStep});
		}
		
		private function fadeInSound(event:SoundItemEvent):void {
			fadingInSounds.push({id:event.id, step:event.volumeStep});
		}
		
		private function fadeOutSoundComplete(event:SoundItemEvent):void {
			var sound:Object;
			for each(sound in fadingOutSounds) {
				if (sound.id == event.id) {
					fadingOutSounds = ArrayUtil.remove(fadingOutSounds, sound);
					return;
				}
			}
		}
		
		private function fadeInSoundComplete(event:SoundItemEvent):void {
			var sound:Object;
			for each(sound in fadingInSounds) {
				if (sound.id == event.id) {
					fadingInSounds = ArrayUtil.remove(fadingInSounds, sound);
					return;
				}
			}
		}
		
		
		
		public function set volume(v:Number):void { soundTransform.volume = v; }		
		public function set pan(v:Number):void { soundTransform.pan = v; }
		
		public function get volume():Number { return soundTransform.volume; }		
		public function get pan():Number { return soundTransform.pan; }
	
	
		public function getSound(id:String):SoundItem {
			return sounds[id] as SoundItem;
		}
	}
	
}


class PrivateClass {}