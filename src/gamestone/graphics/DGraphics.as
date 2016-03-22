package gamestone.graphics {

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import gamestone.utils.StringUtil;
	import gamestone.utils.ArrayUtil;
	
	public class DGraphics {
		
		public static function getTransparencyMap(maskBmp:BitmapData, size:int, _areaThreshold:Number = .5):Array {
			var arr:Array = [];
			var arrX:Array = [];
			
			var rect:Rectangle = new Rectangle(0, 0, size, size);
			var p:Point = new Point(0, 0);
			
			var w:int = maskBmp.width/size, h:int = maskBmp.height/size;
			var bmp:BitmapData = new BitmapData(size, size, true, 0);
			
			var tileArea:int = rect.width*rect.height;
			var areaThreshold:int = _areaThreshold*tileArea;
			
			var solidRect:Rectangle;
			for (var y:int = 0; y<h; y++) {
				arrX = [];
				for (var x:int = 0; x<w; x++) {
					rect.x = x*size; 
					rect.y = y*size;
					bmp.copyPixels(maskBmp, rect, p);
					
					solidRect = bmp.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF);
					if (solidRect.width*solidRect.height >= areaThreshold)
						arrX.push(1);
					else
						arrX.push(0);
				}
				arr.push(arrX);
			}
			
			return arr;
		}
		
	}
}