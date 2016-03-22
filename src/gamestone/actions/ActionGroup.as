package gamestone.actions{
	
import gamestone.actions.Action;
import gamestone.utils.ArrayUtil;
import flash.utils.*;


internal class ActionGroup {
	
	private var className:String = "ActionGroup";
	
	private var groupName:String;
	private var paused:Boolean;
	private var actions:Array;
	private var pauseTimer:uint;
	
	
	public function ActionGroup(name:String) {
		groupName = name;
		actions = [];
		paused = false;
		pauseTimer = 0;
	}
	
	public function pause():void {
		if (paused) return;
		pauseTimer = getTimer();
		paused = true;
	}
	
	public function resume():void {
		if (!paused)
			return;
		paused = false;
		for (var i:String in actions) {
			var action:Action = Action(actions[i]);
			if (action.isDestroyed())
				continue;
			
			// ######################
			// 6/5/2007
			// Was: action.setExecutionTime(action.getExecutionTime() + getTimer() - pauseTimer);
			// replaced with action.resume();
			
			action.resume();
		}
	}
	
	public function addAction(action:Action):void {
		if (ArrayUtil.inArray(actions, action)) return;
		actions.push(action);
		action.setGroupName(groupName);
	}
	
	public function removeAction(action:Action):void {
		ArrayUtil.remove(actions, action);
	}
	
	
	public function isPaused():Boolean {
		return paused;
	}
	
	public function getActions():Array {
		return actions;
	}
	
	public function destroy():void {
		var i:uint = actions.length;
		while (--i >= 0)
			Action(actions[i]).destroy();
		actions = null;
	}
	
	public function toString():String {
		return "[ActionGroup totalActions: "+actions.length+", running: " + !paused + "]";
	}
	
	
}

}