package gamestone.sound {
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import mx.core.SoundAsset;
	
	public class MySound extends Sound {
		
		private var _id:String;
		private var _soundAsset:SoundAsset;
		public var autoPlay:Boolean;
		public var volume:Number;
		public var pan:Number;
		public var loops:int;
		
		public function MySound(id:String, stream:URLRequest = null, context:SoundLoaderContext = null) {
			//super(stream, context);
			_id = id;
		}
		
		public static function MySoundFromEmbeded(id:String, sound:SoundAsset):MySound {
			var s:MySound = new MySound(id);
			s._soundAsset = sound
			return s;
		}
		public override function play(offset:Number = 0, loops:int = 0, soundTransform:SoundTransform = null):SoundChannel {
			try {
				if (_soundAsset == null)
					return super.play(offset, loops, soundTransform);
				else
					return _soundAsset.play(offset, loops, soundTransform);
			} catch (error:ArgumentError) {
				trace("Invalid sound with id=" + _id);
				return null;
			}
			return null;
		}
		
		private function soundComplete(event:Event):void {
			trace("sound " + _id + " complete");
		}
		
		public function get id():String { return _id; }
		
	}
	
}


class PrivateClass {}