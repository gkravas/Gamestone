package gamestone.graphics {

	import gamestone.utils.NumberUtil;
	
	public class RGB {
		
		private var _red:int;
		private var _green:int;
		private var _blue:int;
		private var _alpha:int;
		private var _hex:uint;
		
		public function RGB(r:int = 0xFF, g:int = 0xFF, b:int = 0xFF, a:int = 0xFF) {
			_red = r;
			_green = g;
			_blue = b;
			_alpha = a;
		}
		
		public function setHex(hex:int):void {
			//_hex = hex;
			var rgb:RGB = hex2rgb(hex);
			_red = rgb.red;
			_green = rgb.green;
			_blue = rgb.blue;
		}
		
		public function getHex():int {
			return _red << 16 | _green << 8 | _blue;
		}
		
		public static function hex2rgb(hex:int):RGB {
		   var r:int = hex >> 16;
		   var temp:int = hex ^ r << 16;
		   var g:int = temp >> 8;
		   var b:int = temp ^ g << 8;
		
		   var rgb:RGB = new RGB(r, g, b);
		   return rgb;
		}
		
		public static function getRandom():RGB {
			return new RGB(NumberUtil.randomInt(0, 0xFF), NumberUtil.randomInt(0, 0xFF), NumberUtil.randomInt(0, 0xFF));
		}
		
		// Setters
		public function set red(n:int):void {
			_red = n;
		}
		
		public function set green(n:int):void {
			_green = n;
		}
		
		public function set blue(n:int):void {
			_blue = n;
		}
		
		public function set alpha(n:int):void {
			_alpha = n;
		}
		
		
		// Getters
		public function get red():int {
			return _red;
		}
		
		public function get green():int {
			return _green;
		}
		
		public function get blue():int {
			return _blue;
		}
		
		public function get alpha():int {
			return _alpha;
		}
		
		public function toString():String {
			return "[RGB r:" + _red + " g: " + _green + " b: " + _blue + "]";
		}
		
	}
}