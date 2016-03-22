package gamestone.actions {

	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.errors.IllegalOperationError;
	
	import gamestone.actions.Action;
	import gamestone.actions.ActionGroup;
	import gamestone.utils.Delegate;
	import gamestone.events.ActionEvent;
	
	public final class ActionManager {
		
		private var className:String = "ActionManager";
		
		public static const DEFAULT:String = "default";
		public static const SYSTEM:String = "system";
		public static const APPLICATION:String = "application";
		public static const CONTROLS:String = "controls";
		public static const PANELS:String = "panels";
		public static const GAMEPLAY:String = "gamePlay";
		public static const SOUND:String = "sound";
		public static const ANIMATIONS:String = "animations";
		
		public static const STEP:uint = 10;
		
		private static var _instance:ActionManager;
		private var actions:Object;
		private var groups:Object;
		
		private var timer:Timer;
		
		private var actionID:uint;
	
		private var paused:Boolean;
		
		private var pauseLag:uint;
		private var pauseTimer:uint;
		
		public function ActionManager (pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("ActionManager: cannot be instanciated by calling new ActionManager. getInstance() method must be used instead.");
				return null;
			}
			actions = new Object();
			groups = new Object();
			actionID = 1;
			timer = new Timer(STEP, 0);
			timer.addEventListener(TimerEvent.TIMER, execute, false, 0, true);
			addActionGroup(ActionManager.DEFAULT);
			activateManager();
		}
		
		public static function getInstance():ActionManager {
			if (ActionManager._instance == null)
				ActionManager._instance = new ActionManager(new PrivateClass);
			return _instance;
		}
		
		private function activateManager():void {
			timer.start();
			pauseLag = 0;
			paused = false;
		}
		
		private function deactivateManager():void {
			timer.stop();
		}
		
		public function addAction(groupName:String, callback:Function, lagTime:uint, repeats:int = 1, ...args):uint {
			// If you don't want to specify an actionGroup
			// just pass "" as groupName
			
			var id:uint = actionID++;
			var action:Action = actions [id] = new Action(id, callback);
			
			// Specify when this action should take place
			action.setExecutionTime(lagTime);
			action.setParameters(args);
			action.addEventListener(ActionEvent.EXECUTE, callback, false, 0, true);
			// Set the times you want this action to repeat executing
			// Each time the action will need --lagTime-- time to execute
			// Pass:
			// 1) nothing for 1 execution,
			// 2) an integer for specific number of loops
			// 3) -1 for infinate executions
			action.setRepeats(repeats);
			
			
			if (groupName == null || groupName.length == 0)
				groupName = ActionManager.DEFAULT;
			
			// Add the action to an action group
			if (groups[groupName] == null)
				addActionGroup(groupName);
			
			ActionGroup(groups[groupName]).addAction(action);
			
			return id;
		}
		
		private function execute(event:Event):void {
			var action:Action;
			var toExecute:Array = [];
			for each(action in actions) {
				
				if (action == null) continue;
				
				//Output.dump(action);
				
				// ### Added 30-8-2006
				if (action.isDestroyed()) {
					delete actions [action.getID()];
					continue;
				}
				
				if (getActionGroup(action.getGroupName()).isPaused()) continue;
				
				if (getTimer() >= action.getExecutionTime() + pauseLag && !action.isPaused())
					toExecute.push(action);
			}
			for each(action in toExecute) {
				action.execute();
				if (action.getRepeats() == 0) {
					var groupName:String = action.getGroupName();
					if (groupName.length)
						getActionGroup(groupName).removeAction(action);
					
					action.destroy();
					var id:uint = action.getID();
					action = null;
					delete actions[id];
				}
			}
		}
		
		public function removeAction(id:int):Boolean {
			if (isNaN(id) || actions[id] == null) return false;
			var action:Action = Action(actions[id]);
			var groupName:String = action.getGroupName();
			if (groupName.length)
				getActionGroup(groupName).removeAction(action);
			action.destroy();
			return delete actions [id];
		}
		
		public function removeActions(o:Object):void {
			var id:int;
			for each(id in o) {
				removeAction(id);
				delete actions[id];
			}
		}
		
		public function addActionGroup(name:String):void {
			groups [name] = new ActionGroup(name);
		}
		
		public function removeActionGroup(name:String):void {
			var temp:Array = ActionGroup(groups[name]).getActions();
			
			// ### Added 30-8-2006
			for (var i:String in temp)
				removeAction(Action(temp[i]).getID());
				
			ActionGroup(groups [name]).destroy();
			delete groups [name];
		}
		
		public function pause(groupName:String = null):void {
			// Pause every action
			if (groupName == null) {
				if (paused) return;
				pauseTimer = getTimer();
				deactivateManager();
				for (var i:String in groups)
					getActionGroup(i).pause();
				paused = true;
			}
			// Pause a specific action group
			else {
				getActionGroup(groupName).pause();
			}
		}
		
		public function resume(groupName:String = null):void {
			// Pause every action
			if (groupName == null) {
				pauseLag = getTimer() - pauseTimer;
				activateManager();
				for (var i:String in groups)
					getActionGroup(i).resume();
				paused = false;
			}
			// Pause a specific action group
			else {
				getActionGroup(groupName).resume();
			}
		}
		
		public function pauseAction(actionID:uint):void {
			// Pause action
			var action:Action = Action(actions [actionID]);
			try {
				action.pause();
			} catch (error:TypeError) {
				trace("Error: Action with id " + actionID + " does not exist in ActionManager. pause() failed");
			}
		}
		
		public function resumeAction(actionID:uint):void {
			// Resumer action
			var action:Action = Action(actions [actionID]);
			try {
				action.resume();
			} catch (error:TypeError) {
				trace("Error: Action with id " + actionID + " does not exist in ActionManager. resume() failed");
			}
		}
		
		public function actionExists(actionID:uint):Boolean {
			return actions [actionID] != null;
		}
		
		private function getActionGroup(name:String):ActionGroup {
			return groups[name];
		}
		
		public function isActionGroupPaused(name:String):Boolean {
			var group:ActionGroup = groups[name];
			if (group == null) throw new Error("ActionManager:: Group with name = " + name + "does not exists.");
			return group.isPaused();
		}
		
		public function isActionPaused(actionID:uint):Boolean {
			var action:Action = actions [actionID];
			if (action == null) throw new Error("ActionManager:: Action with id = " + actionID + "does not exists.");
			return action.isPaused();
		}
		
		public function destroy():void {
			deactivateManager();
			for (var i:String in actions) {
				Action(actions[i]).destroy();
			}
			actions = null;
		}
		
		public function getActionRemainingTime(id:uint):uint {
			return Action(actions [id]).getExecutionTime() - getTimer();
		}
		
		public function getClassName():String {
			return className;
		}
		
		public function toString():String {
			return "["+className+"]";// , total:"+util.ObjectUtils.length(this)+"]";
		}
	}

}

// Needed to achieve Singleton functionality
internal class PrivateClass {}