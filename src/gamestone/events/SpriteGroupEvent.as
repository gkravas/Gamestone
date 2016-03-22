package gamestone.events {

import flash.events.*;

public class SpriteGroupEvent extends Event {
	
	public static const NEXT_FRAME:String = "next_Frame";
	
	private var _params:Object;
	
	public function SpriteGroupEvent(type:String, obj:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
		super(type, bubbles, cancelable);
		_params = obj;
	}
	
	public function get params():Object {
		return _params;
	}
	
	public override function clone():Event {
		return new SpriteGroupEvent(type, _params, bubbles, cancelable);
	}
	
	public override function toString():String {
		return formatToString("SpriteGroupEvent", "type", "bubbles", "cancelable", "eventPhase");
	}
	
}
	
}