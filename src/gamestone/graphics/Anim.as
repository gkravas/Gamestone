package gamestone.graphics {

	public class Anim {
	
		private var _id:String;
		private var _frames:Array;
		private var _durations:Array;
		
		public function Anim(id:String, frames:Array, durations:Array) {
			_id = id;
			_frames = frames;
			_durations = durations;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get frames():Array {
			return _frames;
		}
		
		public function get durations():Array {
			return _durations;
		}
	}


}