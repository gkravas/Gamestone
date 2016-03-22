package gamestone.sound {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import gamestone.events.SoundsEvent;

	public class SoundItem extends EventDispatcher {
		
		private static var DEFAULT:SoundGroup = SoundItem.getDefaultSoundGroup();
		public static const FADE_TIME_STEP:int = 40;
		
		private var _id:String;
		private var _sound:MySound;
		private var _channel:SoundChannel;
		private var _volume:Number;
		private var _startingVolume:Number;
		private var _pan:Number;
		private var _allowMultiple:Boolean;
		private var _soundGroup:SoundGroup;
		private var fadingOut:Boolean, fadingIn:Boolean;
		private var playingInstances:int;
		private var _targetFadeVolume:Number, _preFadeVolume:Number;
		private var _lastPosition:Number;
		
		private static function getDefaultSoundGroup():SoundGroup { return new SoundGroup("_default_", 1, 0); }
		
		public function SoundItem(id:String, sound:MySound) {
			_id = id;
			_sound = sound;
			_volume = 1;
			_pan = 0;
			_allowMultiple = true;
			playingInstances = 0;
			fadingOut = fadingIn = false;
			_soundGroup = SoundItem.DEFAULT;
		}
		
		public function play(offset:Number = 0, loops:int = 0):Boolean {
			if (!allowMultiple && playingInstances > 0) return false;
			playingInstances++;
			_channel = _sound.play(offset, loops);
			_channel.addEventListener(Event.SOUND_COMPLETE, soundComplete, false, 0, true);
			updateVolume();
			updatePan();
			
			return true;
		}
		
		public function stop():void {
			if (_channel != null)
				playingInstances--;
			_lastPosition = _channel.position;
			_channel.stop();
			_channel = null;
		}
		
		public function resume():void {
			play(_lastPosition);
			_lastPosition = 0;
		}
		
		public function fadeOut(targetVolume:Number = 0, duration:Number = 1000):void {
			if (fadingOut)
				return;
			if (fadingIn)
				dispatchEvent(new SoundItemEvent(SoundItemEvent.FADE_IN_COMPLETE, id));
			
			var dt:Number = SoundItem.FADE_TIME_STEP;
			var dv:Number = -_volume/(duration/dt);
			
			_targetFadeVolume = targetVolume;
			_preFadeVolume = _volume;
			
			dispatchEvent(new SoundItemEvent(SoundItemEvent.FADE_OUT, _id, dv));
			fadingOut = true;
		}
		
		public function fadeIn(targetVolume:Number = 1,
							   duration:Number = 1000,
							   offset:Number = 0,
							   loops:int = 0):void {
			if (fadingIn)
				return;
			if (fadingIn)
				dispatchEvent(new SoundItemEvent(SoundItemEvent.FADE_OUT_COMPLETE, id));
			var dt:Number = SoundItem.FADE_TIME_STEP;
			var dv:Number = _volume/(duration/dt);
			
			_targetFadeVolume = targetVolume;
			
			/*
			if (!playing)
				volume = 0;*/
			
			_preFadeVolume = _volume;
			
			dispatchEvent(new SoundItemEvent(SoundItemEvent.FADE_IN, _id, dv));
			fadingIn = true;
			
			//if (!playing)
			this.play(offset, loops);
		}
		
		internal function fadeOutVolume(step:Number):void {
			volume += step;
			if (volume < 0)
				volume = 0;
			if (_volume <= _targetFadeVolume) {
				if (_targetFadeVolume == 0) {
					this.stop();
					volume = _preFadeVolume;
				}
				fadingOut = false;
				dispatchEvent(new SoundItemEvent(SoundItemEvent.FADE_OUT_COMPLETE, id));
			}
		}
		
		internal function fadeInVolume(step:Number):void {
			volume += step;
			if (volume > 1)
				volume = 1;
			if (_volume >= _targetFadeVolume) {
				fadingIn = false;
				dispatchEvent(new SoundItemEvent(SoundItemEvent.FADE_IN_COMPLETE, id));
			}
		}
		
		
		private function soundComplete(event:Event):void {
			playingInstances--;
			_channel = null;
			dispatchEvent(new SoundsEvent(SoundsEvent.PLAYBACK_COMPLETE, _id));
		}
		
		
		// Setters
		
		public function set soundTransform(v:SoundTransform):void {
			_channel.soundTransform = v;
		}
		
		public function set volume(v:Number):void {
			_volume = v;
			updateVolume();
		}
		
		public function set pan(v:Number):void {
			_pan = v;
			updatePan();
		}
		
		public function set allowMultiple(v:Boolean):void {
			_allowMultiple = v;
		}
		
		internal function updateVolume():void {
			if (_channel != null) {
				var tr:SoundTransform = _channel.soundTransform;
				tr.volume = _volume*_soundGroup.volume;
				_channel.soundTransform = tr;
			}
		}
		
		internal function updatePan():void {
			if (_channel != null) {
				var tr:SoundTransform = _channel.soundTransform;
				tr.pan = _pan + _soundGroup.pan;
				_channel.soundTransform = tr;
			}
		}
		
		
		// Getters
		
		public function get id():String { return _id; }
		
		internal function get soundTransform():SoundTransform { return _channel.soundTransform; }
		public function get volume():Number { return _volume; }
		public function get pan():Number { return _pan; }
		public function get allowMultiple():Boolean { return _allowMultiple; }
		
		internal function setStartingVolume(v:Number):void { _startingVolume = v; }
		public function get startingVolume():Number { return _startingVolume; }
		
		
		internal function set soundGroup(v:SoundGroup):void { _soundGroup = v; }
		internal function get soundGroup():SoundGroup { return _soundGroup; }
		
		public function isPlaying():Boolean { return playingInstances > 0; }
		public function isFadingOut():Boolean { return fadingOut; }
		public function isFadingIn():Boolean { return fadingIn; }
		
		public override function toString():String {
			return "[SoundItem " + _id + "]";
		}
	}
	
}


class PrivateClass {}