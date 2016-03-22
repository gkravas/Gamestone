package gamestone.graphics {

	import flash.geom.Point;
	
	public class AnimParams extends Object {

		private var _bitmaps:Array;
		private var _durations:Array;
		private var _pivot:Point;
		
		public function AnimParams(bitmaps:Array, durations:Array, pivot:Point) {
			_bitmaps = bitmaps;
			_durations = durations;
			_pivot = pivot;
		}
		
		public function get bitmaps():Array {
			return _bitmaps;
		}
		
		public function get durations():Array {
			return _durations;
		}
		
		public function get pivot():Point {
			return _pivot;
		}
		
		
		
		
	}
	
	
}