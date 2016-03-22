package gamestone.graphics {
	
	public class Animset {
	
		private var _id:String;
		private var anims:Object;
		
		public function Animset(id:String) {
			_id = id;
			anims = {};
		}
		
		public function addAnim(id:String, frames:Array, durations:Array):void {
			
			//Modified by George Kravas
			if(getAnim(id) != null){
				trace("Warning: Animset: Duplicate anim id :" + id + " in animset " + _id + ". The animation will not be loaded");
				return;
			}else if(id == ""){
				trace("Warning: Animset: Some anim has empty id and will not be loaded");
				return;
			}
				
			anims[id] = new Anim(id, frames, durations);
		}
		
		public function get id():String {
			return _id;
		}
		
		public function getAnims():Object {
			return anims;
		}
		
		public function getAnim(id:String):Anim {
			//Modified by George Kravas
			try {
				return Anim(anims[id]);
			} catch (error:TypeError) {
				trace("Error: Animset.getAnim(), anim with id=" + id + " does not exist.");
			}
			return null;
		}
	}
	
}