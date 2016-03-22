package gamestone.packaging {
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import gamestone.events.PackageManagerEvent;
	
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.Module;
	import mx.modules.ModuleManager;
	
	
	public class PackageManager extends EventDispatcher {
		
		protected static var _this:PackageManager;
		protected var _modulesForLoad:Array;
		protected var _modulesIDs:Array;
		protected var _modules:Object;
		protected var _totalModule:int;
		
		public function PackageManager(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("ModuleManager cannot be instantiated externally. getInstance() method must be used instead.");
				return null;
			}
			_modulesForLoad = [];
			_modulesIDs = [];
			_modules = {};
		}
		
		public static function getInstance():PackageManager {
			if (PackageManager._this == null)
				PackageManager._this = new PackageManager(new PrivateClass);
			return PackageManager._this;
		}
		
		public function addModule(id:String, url:String):void {
			var info:IModuleInfo = ModuleManager.getModule(url);
            info.addEventListener(ModuleEvent.READY, moduleLoaded, false, 0, true);
            info.addEventListener(ModuleEvent.PROGRESS, moduleProgress, false, 0, true);
			_modulesForLoad.push(info);
			_modulesIDs.push(id);
		}
		
		public function load():void {
			_totalModule = _modulesForLoad.length;
			(_modulesForLoad[0] as IModuleInfo).load();
		}
		
		protected function moduleLoaded(e:ModuleEvent):void {
			var id:String = _modulesIDs.pop();
			_modulesForLoad.pop();
			var mod:Object = e.module.factory.create();
			var pack:AssetPackage = new AssetPackage(mod as Module);
			_modules[id] = pack;
			pack.parsePackage();
			if (_modulesForLoad.length > 0)
				(_modulesForLoad[0] as IModuleInfo).load();
			else
				dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function moduleProgress(e:ModuleEvent):void {
			var mPercent:Number = e.bytesLoaded / e.bytesTotal;
			var progress:Number = (totalModules - _modulesForLoad.length - 1 + mPercent) / totalModules;
			dispatchEvent(new PackageManagerEvent(PackageManagerEvent.PROGRESS, progress));
		}
		
		public function getPackage(id:String):AssetPackage {
			return _modules[id] as AssetPackage;
		}
		
		//GETTERS
		public function get totalModules():int {return _totalModule;}
	}
}
class PrivateClass {}