// Used by com.zefxis.solarwind2.graphics.ImageLoader
//
// It is the class that determines the default way images will be created from
// the parsed "images.xml"

package gamestone.graphics {

	import flash.geom.Point;
	
	import gamestone.display.MySprite;
	import gamestone.utils.StringUtil;
	
	public class ImgParser {
	
		public function ImgParser() {
		}
		
		public function getProccessedNodes(image:XML):Array {
			var id:String = image.@id;
			var file:String = image.@path;
			
			// Set slices
			var slices:Array = parseSlices(image.slices[0]);
			var hasDimensions:Boolean = hasSliceDimensions(image.slices[0]);
			
			// Set pivot
			var pivotPoint:Point = parsePivot(image.pivotPoint[0]);
			// Embeded
			var embeded:Boolean = StringUtil.parseBoolean(image.@embeded);
			
			var obj:ImgInitParams = new ImgInitParams;
			obj.id = id;
			obj.file = file;
			obj.slices = slices;
			obj.hasSliceDimensions = hasDimensions;
			obj.pivotPoint = pivotPoint;
			obj.embeded = embeded;
	
			return [obj];
		}
		
		protected function parseSlices(slices:String):Array {
			/* 	There are 2 different cases
				
				Case 1:
				<slices>3,1</slices> or <slices>3</slices>
				
				--> There are 3 horizontal slices in total and 1 vertical slice
				
				Case 2:
				<slices>#100,230</slices>
				
				--> There is an unknown number of slices, but each slice has dimensions 100*230px
			*/
				
			var arr:Array = [1, 1];
			if(slices != null){
				
				// Make sure you strip out the special "#" character, if exists
				if (slices.substr(0, 1) == "#")
					slices = slices.substr(1);
				
				var temp:Array = StringUtil.splitToNumbers(slices);
				
				if(temp[0] > 1)
					arr[0] = temp[0];
					
				if(temp.length > 1 && temp[1] > 1)
					arr[1] = temp[1];
			}
			return arr;
		}
		
		protected function hasSliceDimensions(slices:String):Boolean {
			return (slices != null) ? slices.substr(0, 1) == "#" : false;
		}
		
		protected function parsePivot(pivot:String):Point {
			return MySprite.getPointFromString(pivot);
		}
		
		
	}

}