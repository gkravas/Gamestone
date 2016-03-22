package gamestone.localization
{
	public class DictionaryBindingParams
	{
		
		protected var _bindedObject:Object;
		protected var _bindedObjectPropterty:String;
		protected var _leemaID:String;
		
		public function DictionaryBindingParams(bindedObject:Object, bindedObjectPropterty:String, leemaID:String) {
			_bindedObject = bindedObject
			_bindedObjectPropterty = bindedObjectPropterty
			_leemaID = leemaID;
		}
		
		public function assignLeema(leema:String):void {
			if (_bindedObject.hasOwnProperty(_bindedObjectPropterty))
				_bindedObject[_bindedObjectPropterty] = leema;
		}
		
		//GETTERS
		public function get bindedObject():Object {return _bindedObject}
		public function get bindedObjectPropterty():String {return _bindedObjectPropterty}
		public function get leemaID():String {return _leemaID}
	}
}