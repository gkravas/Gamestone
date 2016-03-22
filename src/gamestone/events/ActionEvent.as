package gamestone.events {

import flash.events.*;

public class ActionEvent extends Event {
	
	public static const EXECUTE:String = "execute";
	
	private var _arguments:Array;
	
	public function ActionEvent(type:String, args:Array = null, bubbles:Boolean = false, cancelable:Boolean = false) {
		super(type, bubbles, cancelable);
		_arguments = args;
	}
	
	public function get arguments():Array {
		return _arguments;
	}
	
	public override function clone():Event {
		return new ActionEvent(type, arguments, bubbles, cancelable);
	}
	
	public override function toString():String {
		return formatToString("ActionEvent", "type", "bubbles", "cancelable", "eventPhase");
	}
	
}
	
}