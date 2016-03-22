package gamestone.sound {

	import flash.events.*;
	
	internal class SoundItemEvent extends Event {
		
		public static const FADE_OUT:String = "fadeIn";
		public static const FADE_IN:String = "fadeOut";
		public static const FADE_IN_COMPLETE:String = "fadeInComplete";
		public static const FADE_OUT_COMPLETE:String = "fadeOutComplete";
		
		private var _id:String;
		private var _volumeStep:Number;
		
		public function SoundItemEvent(type:String,
									   id:String,
									   volumeStep:Number = 0,
									   bubbles:Boolean = false,
									   cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_id = id;
			_volumeStep = volumeStep;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get volumeStep():Number {
			return _volumeStep;
		}
		
		public override function clone():Event {
			return new SoundItemEvent(type, id, volumeStep, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("SoundItemEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}