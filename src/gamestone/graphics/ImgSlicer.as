package gamestone.graphics {

	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.*;
	
	import gamestone.graphics.*;
	import gamestone.utils.ArrayUtil;
	
	internal class ImgSlicer {
	
		private static var _this:ImgSlicer;
		
		private var clip:MovieClip;
		
		public function ImgSlicer() {
		}
		
		public static function getInstance():ImgSlicer {
			if (_this == null)
				_this = new ImgSlicer();
			return _this;
		}
		
		public function slice(bmp:BitmapData, columns:int = 1, rows:int = 1, hasSliceDimensions:Boolean = false):Array {
			// If hasSliceDimensions = true, it means that this bitmap should be sliced
			// based on given slice dimensions and not a given number of columns and rows.
			// Therefore, if this is the case, the parameteres passed as columns and rows
			// are the width and height of each slice respectively.
			
			// In order to continue with the slicing up of the bitmap, these values need
			// to be translated to a real number of columns and rows.
			if (hasSliceDimensions) {
				columns = bmp.width/columns;
				rows = bmp.height/rows;
			}
			var arr:Array = []; // The returning array containing the sliced bitmaps
			var slice:BitmapData;
			var point:Point = new Point(0, 0);
			
			var width:uint = bmp.width;
			var height:uint = bmp.height;

			var frameWidth:Number = width/columns;
			var frameHeight:Number = height/rows;

			var maxX:int = columns*frameWidth - 1;
			var maxY:int = rows*frameHeight - 1;

			for (var y:int=0; y<maxY; y+=frameHeight) {
				for (var x:int=0; x<maxX; x+=frameWidth) {
					slice = new BitmapData(frameWidth, frameHeight, true, 0);
					slice.copyPixels(bmp, new Rectangle(x, y, x + frameWidth, y + frameHeight), point);
					arr.push(slice);
				}
			}
			return arr;
		}
	}
}