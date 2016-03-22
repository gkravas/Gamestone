package gamestone.packaging {
	
	import gamestone.utils.ArrayUtil;	
	
	public class Group {
		
		protected var _id:String;
		public var itemsNames:Array;
		public var items:Array;
		
		public function Group(id:String) {
			this._id = id;
			itemsNames = []
			items = [];
		}
		
		public function addItem(id:String, type:String, data:Class):void {
			itemsNames.push(id);
			items.push( new Item(id, type, data));
		}
		
		public function getItem(id:String):Item {
			var item:Item;
			var index:int = itemsNames.indexOf(id);
			if (index > -1)
				item = items[index];
			else
				item = Item.createEmptyItem();
			return item;
		}
		
		//GETTERS
		public function get id():String {return _id;}
	}
}