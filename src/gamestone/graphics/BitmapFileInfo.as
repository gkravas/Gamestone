// Used by com.zefxis.solarwind2.graphics.ImageLoader
//
// It is the class that determines the default way images will be created from
// the parsed "images.xml"

package gamestone.graphics {

	import flash.geom.Point;
	import flash.display.BitmapData;
	import gamestone.utils.StringUtil;
	
	
	public class BitmapFileInfo {
	
		private var _className:String;
		private var _columns:uint;
		private var _rows:uint;
		private var _hasSliceDimensions:Boolean;
		private var _pivot:Point;
		private var _bitmap:BitmapData;
		private var _bitmaps:Array;	// An array with all BitmapData slices 
		
		public function BitmapFileInfo(className:String, columns:int, rows:int, pivot:Point, hasSliceDimensions:Boolean = false) {
			_className = className;
			_columns = columns;
			_rows = rows;
			_hasSliceDimensions = hasSliceDimensions;
			_pivot = pivot;
		}
		
		public function get className():String { return _className; }
		public function get columns():uint { return _columns; }
		public function get rows():uint { return _rows; }
		public function get hasSliceDimensions():Boolean { return _hasSliceDimensions; }
		public function get pivot():Point { return _pivot; }
		public function get bitmap():BitmapData { return _bitmap; }
		public function get bitmaps():Array { return _bitmaps; }
		
		public function get sliceWidth():int {
			return _hasSliceDimensions ? _columns : _bitmap.width/_columns;
		}
		
		public function get sliceHeight():int {
			return _hasSliceDimensions ? _rows: _bitmap.height/_rows;
		}
		
		public function set bitmap(b:BitmapData):void { 
			_bitmap = b;
			if (_columns == 1 && _rows == 1)
				_bitmaps = [b];
		}
		
		public function set bitmaps(b:Array):void { _bitmaps = b; }
		
		
		public function getBitmapArray(arrFrames:Array = null):Array {
			if (arrFrames == null)
				return _bitmaps;
			
			var arr:Array = [];
			var l:int = arrFrames.length;
			for (var i:int=0; i<l; i++)
				arr.push(_bitmaps[arrFrames[i]]);
			
			return arr;
		}
		
		public function dispose():void {
			_bitmap.dispose();
			var b:BitmapData;
			for each (b in _bitmaps)
				b.dispose();
		}
		
		
		
	}

}