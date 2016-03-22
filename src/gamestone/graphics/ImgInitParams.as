package gamestone.graphics {

	import flash.geom.Point;
	
	import gamestone.display.MySprite;
	
	public class ImgInitParams{
	
		public var id:String;
		public var file:String;
		public var slices:Array;
		public var hasSliceDimensions:Boolean;
		public var pivotPoint:Point;
		
		public var startLoading:Boolean = true;
		public var groups:Array;
		
		public var className:String;
		public var embeded:Boolean;
		
		public function ImgInitParams() {
			hasSliceDimensions = false;
			slices = [1, 1];
			pivotPoint = MySprite.POINT_0;
		}
			
	}

}