package gamestone.packaging {
	
	public class Item {
				
		protected var _isEmpty:Boolean;
		protected var _id:String;
		protected var _type:String;
		protected var _data:Class;
		
		public function Item(id:String, type:String, data:Class) {
			_id = id;
			_type = type;
			_data = data;
		}
		
		//GETTERS
		public function get id():String {return _id;}
		public function get type():String {return _type;}
		public function get data():Class {return _data;}
		public function get isEmpty():Boolean {return _isEmpty}
		//STATIC
		public static function createEmptyItem():Item {
			var item:Item = new Item(null, null, null);
			item._isEmpty = true;
			return item;
		}
		
	}
}