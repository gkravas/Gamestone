package gamestone.display {

	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import gamestone.actions.ActionManager;
	import gamestone.display.MySprite;
	import gamestone.graphics.AnimParams;
	import gamestone.events.SpriteGroupEvent;
	
	public class SpriteGroup extends MySprite {

		public static const LEVEL_SPRITE_GROUP:int = 0;
		public static const LEVEL_ANIMATED_SPRITE:int = 1;
		public static const LEVEL_SPRITE_ANIM:int = 2;
		
		private var spriteOrder:Array;
		private var sprites:Object;
		private var currentAnimID:String;
		private var currentSprite:AnimatedSprite;
		private var totalSprites:int;
		private var bitmap:Bitmap;
		private var bmp:BitmapData;
		private var _smoothing:Boolean;
		
		private var bitmaps:Object;
		
		private var speed:int;
		
		private var actionManager:ActionManager;
		private var actionID:Number;
		private var _actionGroup:String;
		private var _onChangeFrameEvent:Boolean;	// Determins if an event will be dispatched for every frame change
		
		
		public function SpriteGroup(name:String) {
			this.name = name;
			init();
		}
		
		private function init():void {
			currentSprite = null;
			totalSprites = 0;
			speed = 1;
			sprites = {};
			spriteOrder = [];
			bitmap = new Bitmap();
			_smoothing = false;
			_actionGroup = ActionManager.GAMEPLAY;
			_onChangeFrameEvent = false;
			addChild(bitmap);
			actionManager = ActionManager.getInstance();
		}
		
		public function addSprite(name:String, depth:int = -1):void {
			var sprite:AnimatedSprite = new AnimatedSprite(name);
			this.stop();
			
			if (sprites[name] == null)
				totalSprites++;
			
			sprites[name] = sprite;
			sprite.autonomous = false;
			
			if (currentSprite == null)
				currentSprite = sprite;
			
			if(depth == -1)
				spriteOrder.push(sprite);
			else
				spriteOrder.splice(depth, 0, sprite);
		}
		
		public function spriteExists(name:String):Boolean {
			return (sprites[name] != null);
		}
		
		public function addAnim(spriteID:String, animID:String, bitmaps:Array, durations:Array, pivot:Point):void {
			var sprite:AnimatedSprite = AnimatedSprite(sprites[spriteID]);
			if (sprite == null) {
				throw new Error("SpriteGroup " + name + " addAnim(): spriteID: " + spriteID + "does not exist.");
				return;
			}
			sprite.addAnim(animID, bitmaps, durations, pivot);
		}
		
		public function removeSprite(name:String):void {
			var animatedSprite:AnimatedSprite = sprites[name];
			if(animatedSprite == null) {
				trace("WARNING: SpriteGroup: AnimatedSprite with name = " + name + " doesn't exists");
				return;
			}
			spriteOrder.splice(spriteOrder.indexOf(animatedSprite), 1);
			animatedSprite.destroy();
			delete sprites[name];
			renderFrame();
		}
		
		public function play(id:String = null):void {
			if (id == null)
				id = currentAnimID;
			this.stop();
			
			setAnim(id);
			renderFrame();
			prepareNextFrame();
		}
		
		public function stop():void {
			actionManager.removeAction(actionID);
		}
		
		public function setSpeed(n:Number):void {
			speed = n;
		}
		
		private function setAnim(id:String):void {
			currentAnimID = id;
			var sprite:AnimatedSprite;
			for each(sprite in sprites)
				sprite.setAnim(id);
			/*
			var pivot:Object = currentSprite.getPivot();
			setPivot(pivot.x, pivot.y);*/
		}
		
		private function renderFrame():void {
			var bitmaps:Array = [];
			var sprite:AnimatedSprite;
			for each (sprite in spriteOrder) {
				try {
					bitmaps.push(sprite.getBitmap());
				} catch (error:TypeError) {
					trace(this + " renderNextFrame() error in sprite.getBitmap(), sprite=" + sprite);
					trace(error);
				} catch (error:ArgumentError) {
					trace(this + " renderNextFrame() error in sprite.getBitmap(), sprite=" + sprite);
					trace(error);
				}
			}
			render(bitmaps);
		}
		
		private function renderNextFrame():void {
			var bitmaps:Array = [];
			var sprite:AnimatedSprite;
			for each (sprite in spriteOrder) {
				sprite.nextFrame();
				try {
					bitmaps.push(sprite.getBitmap());
				} catch (error:TypeError) {
					trace(this + " renderNextFrame() error in sprite.getBitmap(), sprite=" + sprite);
					trace(error);
				} catch (error:ArgumentError) {
					trace(this + " renderNextFrame() error in sprite.getBitmap(), sprite=" + sprite);
					trace(error);
				}
			}
			render(bitmaps);
		}
		
		private function render(bitmaps:Array):void {
			if (bmp != null)
				bmp.dispose();
			var temp:BitmapData, rect:Rectangle;
			var point:Point = new Point(0, 0);
			
			try {
				var bmp1:BitmapData = bitmaps.shift();
			} catch(error:TypeError) {
				trace("Error in .render() in " + this + ". The provided 'bitmaps' array is null. Current anim: " + currentAnimID);
				return;
			}
			try {
				bmp = bmp1.clone();
				bmp.lock();
			} catch (error:TypeError) {
				trace("bitmap: " + bmp1);
				trace("TypeError: The first bitmap in .render() in " + this + " is null. Cannot clone. Current anim:" + currentAnimID);
				trace("bitmaps:"+bitmaps);
				trace(error);
				return;
			} catch (error:ArgumentError) {
				trace("bitmap: " + bmp1, bmp1.width, bmp1.height);
				trace("ArgumentError in " + this + ". Cannot clone. Current anim:" + currentAnimID);
				trace("bitmaps:"+bitmaps);
				trace(error);
				return;
			}
			rect = new Rectangle(0, 0, bmp1.width, bmp1.height);
			
			for each (temp in bitmaps){
				if(temp == null) continue;
				bmp.copyPixels(temp, rect, point, temp, point, true);
			}
			bmp.unlock();
			bitmap.bitmapData = bmp;
			bitmap.smoothing = _smoothing;
		}
		
		private function prepareNextFrame():void {
			actionID = actionManager.addAction(_actionGroup, playNextFrame, getFrameDuration());
		}
		
		private function playNextFrame(e:Event):void {
			renderNextFrame();
			prepareNextFrame();
			if (_onChangeFrameEvent)
				dispatchEvent(new SpriteGroupEvent(SpriteGroupEvent.NEXT_FRAME));
		}
		
		private function getFrameDuration():Number {
			return currentSprite.getFrameDuration()/speed;
		}
		
		public function hideSprite(id:String):void {
			AnimatedSprite(sprites[id]).hide();
		}
		
		public function set smoothing(v:Boolean):void { _smoothing = v; }
		public function get smoothing():Boolean { return _smoothing; }
		
		public function getCurrentAnim():String {
			return currentAnimID;
		}
		
		public function setActionGroup(v:String):void {
			_actionGroup = v;
		}
		public function enableOnChangeFrameEvents():void  { _onChangeFrameEvent = true; }
		public function disableOnChangeFrameEvents():void  { _onChangeFrameEvent = false; }
		
		override public function setMyColorTransform(colorTransform:ColorTransform, level:int = 0, id:String = null):void {
			switch (level) {
			
				case SpriteGroup.LEVEL_SPRITE_GROUP:
				this.transform.colorTransform = colorTransform;
				break;
				
				case SpriteGroup.LEVEL_ANIMATED_SPRITE:
				if(id != null)
					this.sprites[id].setColorTransform(colorTransform);
				else
					trace("WARNING: SpriteGroup:setColorTransform  LEVEL_ANIMATED_SPRITE, id = null");
				break;
				
				case SpriteGroup.LEVEL_SPRITE_ANIM:
				//this.sprites[id].transform.colorTransform = colorTransform;
			}
		}
		
		// Position
		
		public function getBitmapCopy():BitmapData {
			return bitmap.bitmapData.clone();
		}
		
		public override function destroy():void {
			this.stop();
			super.destroy();
			var sprite:AnimatedSprite;
			for each(sprite in sprites)
				sprite.destroy();
			sprites = [];
			actionManager.removeAction(actionID);
		}
		
		public override function toString():String {
			return "[SpriteGroup " + name + "]";
		}
	
	
	
	}


}