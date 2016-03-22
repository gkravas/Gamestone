
package gamestone.display {

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import gamestone.graphics.RGB;
	import gamestone.utils.PivotRotate;
	import gamestone.utils.StringUtil;
	
	import mx.core.UIComponent;
	
	public class MySprite extends UIComponent {
	
		public static const POINT_0:Point = new Point(0, 0);
		
		protected var _pivotX:Number, _pivotY:Number;
		protected var _startPivotX:Number, _startPivotY:Number;
		protected var _sizeX:Number, _sizeY:Number;
		protected var _flippedHor:Boolean, _flippedVert:Boolean;
		protected var _blinker:Blinker;
		protected var _pivotRotation:PivotRotate;
		
		public function MySprite() {
			super();
			pivotX = pivotY = 0;
			_startPivotX = _startPivotY = 0;
			_sizeX = _sizeY = 1;
			_flippedHor = _flippedVert = false;
			_pivotRotation =  new PivotRotate(this, new Point());
		}
		
		
		// Setters
		public function setPivot(x:Number, y:Number):void {
			super.x = super.x + _pivotX;
			super.y = super.y + _pivotY;
			_pivotX = _startPivotX = x;
			_pivotY = _startPivotY = y;
			// Will force redrawing with the new pivot
			this.x = super.x;
			this.y = super.y;
		}
		public function setTransformPoint(x:Number, y:Number):void {
			this.transformX = x;
			this.transformY =y;
		}
		public function setPivotCenter():void {
			setPivot(Math.floor(width/2), Math.floor(height/2));
		}
		public function setTransformCenter():void {
			setTransformPoint(Math.floor(width/2), Math.floor(height/2));
		}
		
		public override function set x(v:Number):void { super.x = v - pivotX; }
		public override function set y(v:Number):void { super.y = v - pivotY; }
		
		public function setPosition(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
		}
		
		public function set pivotX(v:Number):void {
			_pivotX = _startPivotX = v;
			//this.x = super.x;
			//transformX = v;
		}
		
		public function set pivotY(v:Number):void {
			_pivotY = _startPivotY = v;
			//this.y = super.y;
			//transformY = v;
		}
		
		/*public override function set scaleX(v:Number):void {
			super.scaleX = v;
			super.x = super.x + _pivotX;
			_pivotX = scaleX*_startPivotX;
			this.x = super.x;
			
			_sizeX = (scaleX > 0) ? scaleX : -scaleX;
		}
		
		public override function set scaleY(v:Number):void {
			super.scaleY = v;
			super.y = super.y + _pivotY;
			_pivotY = scaleY*_startPivotY;
			this.y = super.y;
			
			_sizeY = (scaleY > 0) ? scaleY : -scaleY;
		}*/
		public function setPivotRotationCenter():void {
			setPivotRotation(Math.floor(width/2), Math.floor(height/2));
		}
		public function setPivotRotation(x:int, y:int):void {
			_pivotRotation.pivotPoint = new Point(x, y);
		}
		public function set pivotRotation(value:Number):void {
			_pivotRotation.rotation = value;
		}
		public function get pivotRotation():Number {
			return _pivotRotation.rotation;
		}
		
		public function set blinker(b:Blinker):void {
			if (_blinker != null)
				_blinker.destroy();
			_blinker = b;
		}
		
		
		public function sortChildren():void {
			var arr:Array = []
			for (var i:int=numChildren-1; i>=0; --i)
				arr.push(getChildAt(i));
			
			arr.sortOn("y", Array.NUMERIC);
			i = arr.length;
			while(i--) {
				if (getChildAt(i) != arr[i])
					setChildIndex(arr[i], i);
			}
		}
		
		public function setFlipHorizontal(flip:Boolean):void {
			if(flip == _flippedHor) return;
			scaleX = _sizeX * (flip ? -1 : 1);
			_flippedHor = flip;
		}
		
		public function flipHorizontal():void {
			setFlipHorizontal(!_flippedHor);
		}
		
		public function setFlipVertical(flip:Boolean):void {
			if(flip == _flippedVert) return;
			scaleY = _sizeY * (flip ? -1 : 1);
			_flippedVert = flip;
		}
		
		public function flipVertical():void {
			setFlipVertical(!_flippedVert);
		}
		
		public function set sizeX(v:Number):void {
			_sizeX = v;
			var sign:int = (scaleX > 0) ? 1 : -1;
			scaleX = sign * _sizeX;
		}
		
		public function set sizeY(v:Number):void {
			_sizeY = v;
			var sign:int = (scaleY > 0) ? 1 : -1;
			scaleY = sign * _sizeY;
		}
		
		public function bringChildToFront(child:DisplayObject):void {
			var n:int = numChildren - 1;
			setChildIndex(child, n);
		}
		
		public function getFlipHorizontal():Boolean { return _flippedHor; }
		public function getFlipVertical():Boolean { return _flippedVert; }
		
		public function setMyColorTransform(colorTransform:ColorTransform, level:int = 0, id:String = null):void {
			this.transform.colorTransform = colorTransform;
		}
		
		
		// Getters
		public override function get x():Number { return super.x + pivotX; }
		public override function get y():Number { return super.y + pivotY; }
		public function get absoluteX():Number { return super.x; }
		public function get absoluteY():Number { return super.y; }
		public function get pivotX():Number { return _pivotX; }
		public function get pivotY():Number { return _pivotY; }
		public function get blinker():Blinker { return _blinker; }
		public function get sizeX():Number { return _sizeX; }
		public function get sizeY():Number { return _sizeY; }
		
		
		
		
		// STATIC
		public static function getPointFromString(str:String):Point {
			var pivotPoint:Point = new Point(0, 0);
			if(str != null){
				var temp:Array = StringUtil.splitToNumbers(str);
				if (temp[0] > 1)
					pivotPoint.x = temp[0];
				if (temp.length > 1 && temp[1] > 1)
					pivotPoint.y = temp[1];
			}
			return pivotPoint;
		}
		
		public static function getColorTransformFromRGB(multiplier:RGB, offset:RGB):ColorTransform {
			return new ColorTransform(multiplier.red/255, multiplier.green/255, multiplier.blue/255, multiplier.alpha/255,
							   offset.red, offset.green, offset.blue, offset.alpha);
		}
		
		public static function getBitmap(obj:DisplayObject):BitmapData {
			var bmp:BitmapData = new BitmapData(obj.width, obj.height, true, 0);
			bmp.draw(obj);
			return bmp;
		}
		
		public static function getPixelAlpha(bmp:BitmapData, point:Point):uint {
			var pixelValue:uint = bmp.getPixel32(point.x, point.y);
			var alpha:uint = pixelValue >> 24 & 0xFF;
			return alpha;
		}
		
		public function destroy():void {
			if(_blinker != null) _blinker.destroy();
		}
		
		public function safeRemoveChild(child:DisplayObject):void {
			if (child != null && contains(child))
				removeChild(child);
		}
		
		public function safeRemoveChildAt(n:int):void {
			if (n < numChildren)
				removeChildAt(n);
		}
		public function sendToTop():void {
			parent.setChildIndex(this, parent.numChildren - 1);
		}
		/*public override function localToGlobal():Point {
			return super.localToGlobal(new Point(x, y));
		}*/
		
	}

}