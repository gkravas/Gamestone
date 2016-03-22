package gamestone.sound {
	
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundLoaderContext;
	import flash.events.Event;
	
	public class SoundGroup {
		
		private var _id:String;
		private var soundTransform:SoundTransform;
		
		public function SoundGroup(id:String, vol:Number = 1, panning:Number = 0) {
			_id = id;
			soundTransform = new SoundTransform(vol, panning);
		}
		
		public function get id():String { return _id; }
		
		public function get volume():Number { return soundTransform.volume; }
		public function get pan():Number { return soundTransform.pan; }
		
		public function set volume(v:Number):void { soundTransform.volume = v; }
		public function set pan(v:Number):void { soundTransform.pan = v; }
		
	}
	
}


class PrivateClass {}