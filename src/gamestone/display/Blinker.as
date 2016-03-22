
package gamestone.display {

	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import gamestone.actions.ActionManager;
	import gamestone.events.ActionEvent;
	
	public class Blinker extends EventDispatcher {
	
		public static const TYPE_VISIBLE:String = "visible";
		public static const TYPE_ALPHA:String = "alpha";
		public static const TYPE_FILTERS:String = "filters";
		
		public static const CYCLE_COMPLETE:String = "cycleComplete";
		
		public static const HIDDEN:int = 0;
		public static const VISIBLE:int = 1;
		public static const STOPPED:int = -1;
		public static const PAUSED:int = 2;
	
		private var sprite:DisplayObject;
		private var _type:String;
		private var state:int;
		private var startAlpha:Number, startFilters:Array, _hiddenStateFilters:Array;
		private var _hideDur:int, _showDur:int;
		private var _maxCycles:uint, cnt:uint;
		private var _pauseTime:uint;
		private var _maxPauseCycles:uint;
		private var _pauseCnt:uint;
		private var _endLagTime:uint;
		private var running:Boolean;
		
		private var actionManager:ActionManager, act_nextState:uint, act_endLagEvent:uint;
		
		public function Blinker(s:DisplayObject, dur1:int, dur2:int, maxCycles:int = -1, type:String = "visible") {
			sprite = s;
			_type = type;
			_hideDur = dur1;
			_showDur = dur2;
			if (type == Blinker.TYPE_VISIBLE)
				startAlpha = sprite.alpha;
			else if (type == Blinker.TYPE_FILTERS)
				startFilters = sprite.filters;

			// Default value for maxCycles should be ~infinity
			_maxCycles = (maxCycles < 1) ? uint.MAX_VALUE : maxCycles * 2;
			_pauseTime = 0;
			_maxPauseCycles = uint.MAX_VALUE;
			_pauseCnt = 1;
			_endLagTime = 0;
			running = false;
			actionManager = ActionManager.getInstance();
		}
		
		public function setPauseTime(time:uint):void {
			_pauseTime = time;
		}
		
		public function setMaxPauseCycles(cycles:uint):void {
			_maxPauseCycles = cycles;
		}
		
		public function start(event:ActionEvent = null):void {
			if (!isStopped())
				this.stop();
			cnt = 0;
			state = Blinker.VISIBLE;
			running = true;
			hide();
		}
		
		public function stop():void {
			state = Blinker.STOPPED;
			running = false;
			show();
			clearAction();
		}
		
		private function hide(e:Event = null):void {
			switch (_type) {
				
				case Blinker.TYPE_VISIBLE:
				sprite.visible = false;
				break;
				
				case Blinker.TYPE_ALPHA:
				sprite.alpha = 0;
				break;
				
				case Blinker.TYPE_FILTERS:
				sprite.filters = (_hiddenStateFilters == null) ? [] : _hiddenStateFilters;
				break;
			}
			cnt++;
			if (!isStopped()) {
				state = Blinker.HIDDEN;
				prepareNextState();
			}
		}
		
		private function show(e:Event = null):void {
			switch (_type) {
				
				case Blinker.TYPE_VISIBLE:
				sprite.visible = true;
				break;
				
				case Blinker.TYPE_ALPHA:
				sprite.alpha = 1;
				break;
				
				case Blinker.TYPE_FILTERS:
				sprite.filters = startFilters;
				break;
			}
			cnt++;
			if (!isStopped()) {
				state = Blinker.VISIBLE;
				prepareNextState();
			}
		}
		
		private function prepareNextState():void {
			if (cnt < _maxCycles) {
				if (state == 0)
					act_nextState = actionManager.addAction(ActionManager.GAMEPLAY, show, _hideDur);
				else
					act_nextState = actionManager.addAction(ActionManager.GAMEPLAY, hide, _showDur);
			} else {
				if(_pauseTime > 0 && _pauseCnt < _maxPauseCycles) {
					_pauseCnt++;
					dispatchEvent(new Event(Blinker.CYCLE_COMPLETE));
					state = Blinker.PAUSED;
					act_nextState = actionManager.addAction(ActionManager.GAMEPLAY, start, _pauseTime);
				} else {
					if(_endLagTime == 0)
						dispatchEvent(new Event(Event.COMPLETE));
					else
						act_endLagEvent = actionManager.addAction(ActionManager.GAMEPLAY, dispatchCompleteEventWithLag, _endLagTime);
				}
			}
		}
		
		private function dispatchCompleteEventWithLag(event:ActionEvent):void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function isVisible():Boolean { return state == Blinker.VISIBLE; }
		public function isHidden():Boolean { return state == Blinker.HIDDEN; }
		public function isStopped():Boolean { return state == Blinker.STOPPED; }
		public function isPaused():Boolean { return state == Blinker.PAUSED; }
		
		public function isOn():Boolean { return running; }
		
		private function clearAction():void {
			actionManager.removeAction(act_nextState);
		}
		
		public function get maxCycles():uint { return _maxCycles; }
		public function set maxCycles(v:uint):void { _maxCycles = v; }
		
		public function set endLagTime(v:uint):void { _endLagTime = v; }
		
		public function set hiddenStateFilters(v:Array):void { _hiddenStateFilters = v; }
		public function set visibleStateFilters(v:Array):void { startFilters = v; }
	
		public function destroy():void {
			this.stop();
			clearAction();
			actionManager.removeAction(act_endLagEvent);
			_hiddenStateFilters = null;
		}
	}

}