// Abstract class
// Should only be used for subclassing, for custom features in manipulating images loaded ftom ImageLoader
// Actually, it can be used as is, but it creates unnecessary overhead.

package gamestone.graphics {
	
	import flash.display.BitmapData;
	
	public class ImgManipulator {
	
		public function ImgManipulator() {
		}
		
		public function getProccessedBitmap(id:String, info:BitmapFileInfo):BitmapData {
			return info.bitmap;
		}
		
		public function toString():String {
			return "[ImgManipulator]";
		}
		
		
		
		
	}
	
}