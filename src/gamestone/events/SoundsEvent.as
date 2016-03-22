package gamestone.events {

	import flash.events.*;
	
	import gamestone.sound.SoundItem;
	import gamestone.sound.SoundManager;
	
	public class SoundsEvent extends Event {
		
		public static const SOUND_LOADED:String = "soundLoaded";
		public static const PLAYBACK_COMPLETE:String = "playbackComplete";
		
		private var _id:String;
		private var _sound:SoundItem;
		
		public function SoundsEvent(type:String, id:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_id = id;
			_sound = SoundManager.getInstance().getSound(id);
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get sound():SoundItem {
			return _sound;
		}
		
		public override function clone():Event {
			return new SoundsEvent(type, id, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("SoundsEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}