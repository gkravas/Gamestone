package gamestone.packaging {
	
	import flash.errors.IllegalOperationError;
	
	import mx.core.BitmapAsset;
	import mx.core.SoundAsset;
	
	
	public class AssetPackage {
		
		protected var mod:Object;
		protected var groupsNames:Array;
		protected var groups:Array;
		
		public function AssetPackage(module:Object) {
			mod = module;
			groupsNames = [];
			groups = [];
		}
		    	
    	public function parsePackage():void {
    		var pack:XML = mod.getContent();
    		var group:XML;
    		for each(group in pack.group) {
    			var groupObj:Group = parseGroup(group);
    			groupsNames.push(groupObj.id);
    			groups.push(groupObj);
    		}
    	}
    	
    	protected function parseGroup(group:XML):Group {
    		var groupObj:Group = new Group(group.attribute("id"));
    		var item:XML;
    		for each(item in group.item) {
    			addItem(item, groupObj);
    		}
    		return groupObj;
    	}
    	
    	protected function addItem(item:XML, group:Group):void {
    		var id:String = item.attribute("id");
    		var type:String = item.attribute("type");
    		var data:String = item.attribute("data");
    		var cls:Class = mod.getClass(data);
    		if (cls == null)
    			throw IllegalOperationError("Item " + id + " does not exist in " + mod.name);
    		group.addItem(id, type, cls);
    	}
    	
    	public function getItem(group:String, id:String):Class {
    		return (groups[groupsNames.indexOf(group)] as Group).getItem(id).data;
    	}
    	
    	public function getBitmapAsset(group:String, id:String):BitmapAsset {
    		var cls:Class = getItem(group, id);
    		return new cls as BitmapAsset;
    	}
    	public function getXML(group:String, id:String):XML {
    		var cls:Class = getItem(group, id);
    		return new cls as XML;
    	}
    	public function getSoundAsset(group:String, id:String):SoundAsset {
    		var cls:Class = getItem(group, id);
    		return new cls as SoundAsset;
    	}
	}
}