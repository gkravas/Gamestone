package gamestone.display {

	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	
	import gamestone.actions.ActionManager;
	import gamestone.display.MySprite;
	import gamestone.graphics.AnimParams;
	
	public class AnimatedSprite extends MySprite {

		// If set to true, the AnimatedSprite handles the animation by itself
		// if not, it means that it's been handled by a SpriteGroup object
		private var _autonomous:Boolean;
		
		private var colored:Boolean;
		
		private var currentAnimID:String;
		private var totalAnims:uint;
		private var anims:Object;
		
		private var actionID:int;
		private var actionManager:ActionManager;
		private var actionGroup:String;
		
		public function AnimatedSprite(name:String) {
			this.name = name;
			_autonomous = true;
			totalAnims = 0;
			actionID = -1;
			anims = {};
			actionGroup = ActionManager.GAMEPLAY;
			actionManager = ActionManager.getInstance();
		}
	
		public function addAnim(name:String, bitmaps:Array, durations:Array, pivot:Point = null):void {
			if(pivot == null) pivot = MySprite.POINT_0;
			
			var params:AnimParams = new AnimParams(bitmaps, durations, pivot);
			var anim:SpriteAnim = anims[name] = new SpriteAnim(name, params);
			anim.autonomous = false;
			totalAnims++;
			
			// If no current anim has been set, set the first one as the current anim
			if (currentAnimID == null)
				currentAnimID = name;
		}
		
		public function setAnim(animID:String):void { 
			/*if (animID != null && anims[animID] != null)
				currentAnimID = animID;*/
			
			if (animID != null)
				currentAnimID = animID;
			
			if (anims[animID] == null)
				return;
				
			SpriteAnim(anims[currentAnimID]).resetFrame();
		}
		
		public function setAnimFlipHorizontal(animID:String, flip:Boolean):void { 			
			//if (animID != null)
				//currentAnimID = animID;
			
			if (anims[animID] == null)
				return;
				
			SpriteAnim(anims[animID]).setFlipHorizontal(flip);
		}
		
		public function isAnimflippedHorizontaly(animID:String):void { 			
			if (animID != null)
				currentAnimID = animID;
			
			if (anims[animID] == null)
				return;
				
			SpriteAnim(anims[currentAnimID]).getFlipHorizontal();
		}
		
		public function flipAnimVertical(animID:String):void { 			
			if (animID != null)
				currentAnimID = animID;
			
			if (anims[animID] == null)
				return;
				
			SpriteAnim(anims[currentAnimID]).setFlipVertical(true);
		}
		
		public function isAnimflippedVerticaly(animID:String):void { 			
			if (animID != null)
				currentAnimID = animID;
			
			if (anims[animID] == null)
				return;
				
			SpriteAnim(anims[currentAnimID]).getFlipVertical();
		}
		
		public function play(animID:String = null, resetFrame:Boolean = false):void {
			if (currentAnimID == animID && isPlaying()) return;
			if (isPlaying())
				this.stop();
			
			hide();
			if (animID != null)
				setAnim(animID);
			
			show();
			
			var anim:SpriteAnim = SpriteAnim(anims[currentAnimID]);
			
			if (resetFrame)
				anim.resetFrame();
				
			if (_autonomous)
				prepareNextFrame();
		}
		
		private function prepareNextFrame():void {
			actionID = actionManager.addAction(actionGroup, playNextFrame, getFrameDuration());
			
		}
		
		private function playNextFrame(e:Event):void {
			SpriteAnim(anims[currentAnimID]).playNext();
			if (_autonomous)
				prepareNextFrame();
		}
		
		public function stop():void {
			actionManager.removeAction(actionID);
		}
		
		public function hide():void {
			var anim:SpriteAnim = SpriteAnim(anims[currentAnimID]);
			if (anim.parent == this)
				removeChild(anim);
		}
		
		public function show():void {
			var anim:SpriteAnim = SpriteAnim(anims[currentAnimID]);
			addChild(anim);
		}
		
		public function nextFrame():void {
			var anim:SpriteAnim;
			for each(anim in anims)
				anim.nextFrame();
		}
		
		public function getcurrentAnim():SpriteAnim {
			return SpriteAnim(anims[currentAnimID]);
		}
		
		public function getDurations(id:String):Array {
			return SpriteAnim(anims[id]).getDurations();
		}
		
		internal function getFrameDuration(id:String = null):Number {
			if (id == null) id = currentAnimID;
			return SpriteAnim(anims[id]).getFrameDuration();
		}
		
		public function getBitmapClone():BitmapData {
			return getBitmap().clone();
		}
		
		internal function getBitmap():BitmapData {
			if(anims[currentAnimID] ==  null)
				return null;
			
			try {
				if (!colored)
					return SpriteAnim(anims[currentAnimID]).getCurrentBitmap();
				else
					return SpriteAnim(anims[currentAnimID]).getCurrentBitmapColored();
			} catch (error:TypeError) {
				trace("TypeError in " + this + ", getBitmap(), " + currentAnimID, anims[currentAnimID]);
			} catch (error:ArgumentError) {
				trace("ArgumentError in " + this + ", getBitmap()" + currentAnimID, anims[currentAnimID]);
			}
			
			return null;
		}
		
		override public function setMyColorTransform(colorTransform:ColorTransform, level:int = 0, id:String = null):void {
			if (colorTransform == null) {
				throw new TypeError("Error: setColorTransform() in AnimatedSprite cannot take a null value for parameter colorTransform. Use unsetColorTransform() instead.");
				return;
			}
			transform.colorTransform = colorTransform;
			colored = true;
			var anim:SpriteAnim;
			for each(anim in anims)
				anim.setMyColorTransform(colorTransform);
		}
		
		public function unsetColorTransform():void {
			transform.colorTransform = null;
			colored = false;
			var anim:SpriteAnim;
			for each(anim in anims)
				anim.unsetColorTransform();
		}
		
		public function isPlaying():Boolean {
			return actionID > -1;
		}
		
		public function isPlayingAnim(id:String):Boolean {
			return currentAnimID == id && SpriteAnim(anims[currentAnimID]).isPlaying();
		}
		
		public function isAutonomous():Boolean { return _autonomous; }
		
		public function setActionGroup(v:String):void {
			actionGroup = v;
		}
		
		// Internal functions
		// Only objects of the same package can have acces to them
		// (they are actually called by an AnimatedSprite class object)
		internal function set autonomous(v:Boolean):void { 
			_autonomous = v;
		}
		
		
		public override function destroy():void {
			actionManager.removeAction(actionID);
			super.destroy();
			this.stop();
			var anim:SpriteAnim;
			for each(anim in anims)
				anim.destroy();
			anims = [];
		}
		
		public override function toString():String {
			return "[AnimatedSprite " + name + "]";
		}
	
	
	}
	
	
	
}