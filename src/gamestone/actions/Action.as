package gamestone.actions {

import flash.utils.*;
import flash.events.*;
import gamestone.events.*;

internal class Action extends EventDispatcher {

	private var className:String = "Action";

	private var id:uint;
	private var callback:Function;
	private var parameters:Array;
	private var lagTime:int;
	private var executionTime:int;
	private var repeats:int;
	private var groupName:String;
	private var pauseTimer:int;
	private var paused:Boolean;
	private var destroyed:Boolean;
	
	public function Action(id:uint, f:Function) {
		this.id = id;
		callback = f;
	}
	
	public function setExecutionTime(t:uint):void {
		lagTime = t;
		updateExecutionTime(t);
	}
	
	private function updateExecutionTime(t:uint):void {
		executionTime = getTimer() + t;
	}
	
	public function setParameters(arr:Array):void {
		parameters = arr;
	}
	
	public function setRepeats(n:int):void {
		repeats = n;
	}
	
	public function getExecutionTime():uint {
		return executionTime;
	}
	
	public function execute():void {
		dispatchEvent(new ActionEvent(ActionEvent.EXECUTE, parameters));
		if (repeats > 0)
			repeats--;
		
		if (repeats != 0)
			executionTime = getTimer() + lagTime;
		
		// ########
		/*
			Updated: 22-11-2007
			Actions with repeats > 0 would execute all of their repeats almost instantly,
			regardless what their lag time was.
		
			Previous (buggy) code: --------
			else if (repeats < 0)
				executionTime = getTimer() + lagTime;
		//////////////////*/
	}
	
	public function setGroupName(name:String):void {
		groupName = name;
	}
	
	public function getGroupName():String {
		return groupName;
	}
	
	public function getRepeats():uint {
		return repeats;
	}
	
	public function pause():void {
		if (paused) return;
		pauseTimer = getTimer();
		paused = true;
	}
	
	public function resume():void {
		if (!paused) return;
		paused = false;
		updateExecutionTime(getExecutionTime() - pauseTimer);
		
		// ########
		/*
			Updated: 22-11-2007
			Actions would execute extremely fast regardless what their lag time was.
			
			Previous (buggy) code: 
			setExecutionTime(getExecutionTime() - pauseTimer);
			
			Explanation:
			setExecutionTime() re-set the lagTime, which should never be resetted after assinged by the ActionManager
			
		//////////////////*/
	}
	
	public function isPaused():Boolean {
		return paused;
	}
	
	public function getID():uint {
		return id;
	}
	
	public function destroy():void {
		pause();
		destroyed = true;
		parameters = null;
	}
	
	public function isDestroyed():Boolean {
		return destroyed;
	}
	
	public function getClassName():String {
		return className;
	}
	
	override public function toString():String {
		var extraState:String = "";
		if (destroyed)
			extraState = " destroyed ";
		else if (paused)
			extraState = " paused ";
		return "["+className+" id=" + id + extraState + "]";
	}
}
}