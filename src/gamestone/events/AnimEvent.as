package gamestone.events {

import flash.events.*;

public class AnimEvent extends Event {
	
	public static const ANIMATION_OVER:String = "animationOver";
	public static const ITERATION:String = "iteration";
	
	private var _params:Object;
	
	public function AnimEvent(type:String, obj:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
		super(type, bubbles, cancelable);
		_params = obj;
	}
	
	public function get params():Object {
		return _params;
	}
	
	public override function clone():Event {
		return new AnimEvent(type, _params, bubbles, cancelable);
	}
	
	public override function toString():String {
		return formatToString("AnimEvent", "type", "bubbles", "cancelable", "eventPhase");
	}
	
}
	
}