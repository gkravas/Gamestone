package gamestone.display {

	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	
	import gamestone.display.MySprite;
	import gamestone.graphics.AnimParams;
	import gamestone.actions.ActionManager;
	import gamestone.utils.ArrayUtil;
	
	public class SpriteAnim extends MySprite {

		private var bitmap:Bitmap;
		private var bitmaps:Array;
		private var durations:Array;
		
		// Caching system.
		// This array contains all colored BitmapData objects
		// that have the current colorTransform object applied on them.
		// Used for faster rendering
		private var coloredBitmaps:Array;
		private var colored:Boolean;
		private var colorTransform:ColorTransform;
		
		// If set to true, the SpriteAnim handles the animation by itself
		// if not, it means that it's been handled by an AnimatedSprite object
		private var _autonomous:Boolean;
		
		private var _smoothing:Boolean = false;
		private var loop:Boolean;
		private var direction:int;
		private var frame:int;
		private var totalFrames:uint;
		private var actionID:int;
		private var actionManager:ActionManager;
		private var _actionGroup:String;
		
		public var speedMultiplier:Number;
		
		public function SpriteAnim(name:String, params:AnimParams) {
			this.name = name;
			
			_autonomous = true;
			actionID = -1;
			speedMultiplier = 1;
			frame = 0;
			loop = true;
			totalFrames = params.bitmaps.length;
			direction = 1;
			visible = true;
			coloredBitmaps = [];
			
			bitmap = new Bitmap();
			_smoothing = false;
			_actionGroup = ActionManager.GAMEPLAY;
			addChild(bitmap);
			parseAnimParams(params);
			update();
			
			actionManager = ActionManager.getInstance();
		}
		
		protected function parseAnimParams(params:AnimParams):void {
			bitmaps = params.bitmaps;
			
			var d:Array = params.durations;
			if (d.length > 1)
				durations = d;
			else
				durations = ArrayUtil.createArray(totalFrames, d[0]);
			setPivot(params.pivot.x, params.pivot.y);
		}
		
		public function play(startFrame:int = 0):void {
			frame = startFrame;
			
			if (_autonomous && !isNaN(actionID))
				this.stop();
			
			update();
			
			if (_autonomous)
				prepareNextFrame();
		}
		
		public function stop():void {
			actionManager.removeAction(actionID);
			actionID = NaN;
		}
		
		public function playNext():void {
			playNextFrame(null);
		}
		
		public function nextFrame():void {
			if (frame == totalFrames - 1 && !loop) {
				endAnim();
				return;
			}
			++frame;
			if (frame == totalFrames)
				frame = 0;
			
			update();
		}
		
		private function endAnim():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function update():void {
			bitmap.bitmapData = getCurrentBitmapColored();
			bitmap.smoothing = _smoothing;
		}
		
		public function show():void {
			visible = true;
		}
		
		public function hide():void {
			visible = false;
		}
		
		public function previousFrame():void {
			if (frame == 0 && !loop)
				return;
			--frame;
			if (frame == -1)
				frame = totalFrames - 1;
			update();
		}
		
		public function goto(f:uint, forceStop:Boolean = false):void {
			// Make sure the number is in bounds
			if (f > totalFrames)
				f = totalFrames - 1;
			else if (f < 0)
				f = 0;
			frame = f;
			update();
			if (forceStop)
				this.stop();
		}
		
		public function getCurrentFrame():uint {
			return frame;
		}
		
		public function resetFrame():void {
			frame = 0;
		}
		
		public function set smoothing(v:Boolean):void {
			_smoothing = v;
			update();
		}
		public function get smoothing():Boolean { return _smoothing; }
		
		private function prepareNextFrame():void {
			actionID = actionManager.addAction(_actionGroup, playNextFrame, getFrameDuration());
		}
		
		private function playNextFrame(e:Event):void {
			if (direction == 1)
				this.nextFrame();
			else
				this.previousFrame();
				
			if (_autonomous)
				prepareNextFrame();
		}
		
		public function setLoop(v:Boolean):void {
			loop = v;
		}
		
		public function setDirection(n:int):void {
			direction = (n >= 0) ? 1 : -1;
		}
		
		override public function setMyColorTransform(colorTransform:ColorTransform, level:int = 0, id:String = null):void {
			// Clear all colored images from cache
			coloredBitmaps = [];
			// Set the new colorTransform
			this.colorTransform = colorTransform;
			colored = true;
			update();
		}
		
		public function unsetColorTransform():void {
			// Clear all colored images from cache
			coloredBitmaps = [];
			this.colorTransform = null;
			colored = false;
			update();
		}
		
		public function getCurrentBitmap():BitmapData {
			return bitmaps[frame];
		}
		
		public function getBitmap(n:int = -1):BitmapData {
			if (n == -1)
				n = frame;
			if (bitmaps[n] != null)
				return bitmaps[n];
			else {
				trace("Warning: Frame " + n + "does not exist in " + this);
				return null;
			}
		}
		
		public function getCurrentBitmapColored():BitmapData {
			if (this.colorTransform == null)
				return bitmaps[frame];
			// Cache all colored bitmaps for fast future access
			try {
				var coloredBitmap:BitmapData = coloredBitmaps[frame];
			} catch (error:TypeError) {
				trace("Error: #############");
				return null;
			}
			if (coloredBitmap == null && colored) {
				try {
					var bmp:BitmapData = BitmapData(bitmaps[frame]).clone();
				} catch(error:TypeError) {
					trace("TypeError: There is no frame " + frame + " in 'bitmaps' array to clone in " + this);
					trace("bitmaps: " + bitmaps);
					trace("bitmaps[frame]: " + bitmaps[frame]);
					throw(error);
					return null;
				} catch(error:ArgumentError) {
					trace("ArgumentError: There is no frame " + frame + " in 'bitmaps' array to clone in " + this);
					trace("bitmaps: " + bitmaps);
					trace("bitmaps[frame]: " + bitmaps[frame]);
					trace("Error was ---> " + error);
					throw(error);
					return null;
				}
				bmp.colorTransform(bmp.rect, colorTransform);
				coloredBitmaps[frame] = bmp;
			}
			return coloredBitmaps[frame];
		}
		
		internal function getFrameDuration():Number {
			return durations[frame]/speedMultiplier;
		}
		
		public function isPlaying():Boolean { return actionID > -1; }
		
		public function getDurations():Array {
			return durations;
		}
		
		public function isAutonomous():Boolean { return _autonomous; }
		
		public function setActionGroup(v:String):void {
			_actionGroup = v;
		}
		
		
		// Internal functions
		// Only objects of the same package can have acces to them
		// (they are actually called by an AnimatedSprite class object)
		internal function set autonomous(v:Boolean):void { 
			_autonomous = v;
		}
		
		public override function destroy():void {
			super.destroy();
			this.stop();
			
			var b:BitmapData;
			for each (b in coloredBitmaps)
				b.dispose();
			coloredBitmaps = null;
			bitmaps = null;
		}
		
		public override function toString():String {
			return "[SpriteAnim " + name + "]";
		}
		
		
		
		
		
		
	}
	
	
}