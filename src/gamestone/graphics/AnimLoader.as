package gamestone.graphics {

	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.errors.IllegalOperationError;
	
	import gamestone.graphics.*;
	import gamestone.utils.StringUtil;
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.XMLLoader;
	
	public class AnimLoader extends XMLLoader {
	
		private static var _this:AnimLoader;
		
		private var animsets:Object;
		private var create:Function;
		
		public function AnimLoader(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("AnimLoader cannot be instantiated externally. getInstance() method must be used.");
				return null;
			}
			animsets = {};
		}
		
		public static function getInstance():AnimLoader {
			if (AnimLoader._this == null)
				AnimLoader._this = new AnimLoader(new PrivateClass());
			return AnimLoader._this;
		}
		
		public function getAnimset(id:String):Animset {
			//Modified by George Kravas
			try {
				return Animset(animsets[id]);
			} catch (error:TypeError) {
				trace("Error: AnimLoader.getAnimset(), animset with id=" + id + " does not exist.");
			}
			return null;
		}
		
		protected override function xmlLoaded(e:Event):void {
			var xml:XML = XML(xmlLoader.data);
			
			var animsets:XMLList = xml.animset;
			var animset:XML;
			var animsetID:String;
			var anims:XMLList;
			
			var anim:XML;
			var animID:String;
			var frames:Array;
			var durations:Array;
			
			create = ArrayUtil.quickCreate;
			
			for each(animset in animsets) {
				animsetID = animset.@id;
				
				//Modified by George Kravas
				if(getAnimset(animsetID) != null){
					trace("Warning: AnimLoader: Duplicate animset id :" + animsetID + ". The animation will not be loaded");
					continue;
				}else if(animsetID == ""){
					trace("Warning: AnimLoader: Some animset has empty id and will not be loaded");
					continue;
				}
				
				this.animsets[animsetID] = new Animset(animsetID);
				
				anims = animset.anim;
				
				for each(anim in anims) {
					animID = anim.@id;
					frames = parseFrames(anim.frames[0]);
					durations = StringUtil.splitToInt(anim.durations[0]);
					this.animsets[animsetID].addAnim(animID, frames, durations);
				}
				
			}
			super.xmlLoaded(e);
		}
		
		private function parseFrames(str:String):Array {
			var frames:Array = [];
			var tmp:Array = str.split(",");
			var s:String, tmp2:Array;
			if (str.indexOf("*") < 0)
				return tmp;
			else {
				for each (s in tmp) {
					tmp2 = s.split("*");
					if (tmp2.length == 2) {
						frames = frames.concat(create(int(tmp2[1]), int(tmp2[0])));
					} else
						frames.push(tmp2[0]);
				}
			}
			
			return frames;
		}
		
		
	}
	
}

class PrivateClass {}