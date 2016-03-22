package gamestone.localization {

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import gamestone.utils.ArrayUtil;
	import gamestone.utils.StringUtil;
	import gamestone.utils.XMLLoader;
	
	public class LocalizationDictionary extends XMLLoader {
	
		private static var _this:LocalizationDictionary;
		public static const replacement:String = "#~#";
		
		protected var _languages:Object;
		protected var _currentLanguage:Object;
		protected var _defaultLanguage:String;
		protected var bindedObjects:Array;
		protected var bindedLeemata:Object;
		private var ids:Array;
		
		public function LocalizationDictionary(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("Dictionary: cannot be instantiated by calling new Dictionary(). getInstance() method must be used instead.");
				return null;
			}
			_languages = {};
			_currentLanguage = {};
			ids = [];
			bindedObjects = [];
			bindedLeemata = {};
		}
		
		public static function getInstance():LocalizationDictionary {
			if (LocalizationDictionary._this == null)
				LocalizationDictionary._this = new LocalizationDictionary(new PrivateClass);
			return LocalizationDictionary._this;
		}
		
		protected override function xmlLoaded(event:Event):void {
			var xml:XML = new XML();
			xml = XML(xmlLoader.data);
			var languagesXML:XMLList = xml.language;
			var languageXML:XML;
			var leemata:XMLList;
			var id:String, text:String;
			var leema:XML;
			var defaultLanguage:Boolean;
			_defaultLanguage = xml.@default;
			
			for each (languageXML in languagesXML) {
				var language:Object = {};
				leemata = languageXML.leema;
				defaultLanguage = (languageXML.@id == _defaultLanguage);
				for each (leema in leemata) {
					id = leema.@id;
					text = leema[0];
					addLeema(language, id, text, defaultLanguage);
				}
				_languages[languageXML.@id] = language;
			}
			_currentLanguage = _languages[_defaultLanguage];
			super.xmlLoaded(event);
		}
		
		public function addLeema(language:Object, id:String, leema:String, defaultLanguage:Boolean):void {
			if (leema == null) return;
			if (language[id] != null)
				trace("leema " + id + " has a value already");
			else
			{
				language [id] = leema.split("\\n").join("\n");
				if (defaultLanguage)
					ids.push(id);
			}
		}
		
		public function changeLanguage(id:String):void
		{
			if (!_languages.hasOwnProperty(id)) return;
			_currentLanguage = _languages[id];
			var dbp:DictionaryBindingParams;
			for each(dbp in bindedObjects) {
				dbp.assignLeema(_currentLanguage[dbp.leemaID]);
			}
		}
		
		public function getLeema(leema:String, replaceStr:Array = null):String {
			if (leema == "")
				return "";
			if (_currentLanguage [leema] != null) {
				if (replaceStr != null) {
					var arr:Array = _currentLanguage [leema].split(replacement);
					var str:String = "";
					var txt:String;
					var i:int;
					for (i = 0; i < replaceStr.length; i++) {
						txt = arr[i];
						str += txt + replaceStr[i];
					}
					if (replaceStr.length < arr.length)
						str += arr[i];
					return str;
					//return _currentLanguage [leema].split(replacement).join(replaceStr);
				} else
					return _currentLanguage [leema];
			} else
				return "[" + leema + "]";
		}
		
		public function registerLeemaBinding(object:Object, propertyName:String, leemaID:String):Boolean {
			//If the leema exists in dictionary
			if (!_currentLanguage.hasOwnProperty(leemaID)) {
				//If the property exists in object
				if (object.hasOwnProperty(propertyName)) {
					//# indicates that leema has not been loaded and object propterty will not be binded to it
					object[propertyName] = "[" + leemaID + "#]"
				}
				return false;
			}
			//If the property exists in object
			if (!object.hasOwnProperty(propertyName)) return false;
			//assign the value
			var dbp:DictionaryBindingParams = new DictionaryBindingParams(object, propertyName, leemaID)
			bindedObjects.push(dbp);
			dbp.assignLeema(_currentLanguage[leemaID]);
			if (!bindedLeemata.hasOwnProperty(leemaID)) {
				bindedLeemata[leemaID] = [dbp];
			} else {
				(bindedLeemata[leemaID] as Array).push(dbp);
			}
			return true;
		}
		
		public function unregisterLeemaBinding(object:Object, propertyName:String, leemaID:String):void {
			var dbp:DictionaryBindingParams;
			if (!bindedLeemata.hasOwnProperty(leemaID)) {
				var arr:Array = bindedLeemata[leemaID] as Array;
				for each(dbp in arr) {
					if (dbp.bindedObject == object && dbp.bindedObjectPropterty == propertyName) {
						bindedLeemata[leemaID] = ArrayUtil.remove(arr, dbp);
						bindedObjects = ArrayUtil.remove(bindedObjects, dbp);
					}
				}
			}
		}
	}
	
}


class PrivateClass {}