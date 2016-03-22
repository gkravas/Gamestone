package gamestone.utils
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.controls.scrollClasses.ScrollThumb;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	public class IPhoneScrollerManager
	{
		// ----------------------------------------------------
		// Zone Manager
		// ----------------------------------------------------	
		
		static private var mapInstances:Dictionary = new Dictionary(true);
		
		static public function addContainer (container:Container, useScrollRect:Boolean = false, updateFunction:Function =null, onMouseDownFunction:Function= null, onMouseUpFunction:Function= null, onMouseOutFunction:Function= null):void
		{
			mapInstances[container] = new IPhoneScrollerManager(container, useScrollRect, updateFunction, onMouseDownFunction, onMouseUpFunction, onMouseOutFunction);
			
		}
		
		static public function removeContainer (container:Container):void
		{
			(mapInstances[container] as IPhoneScrollerManager)
		}			
		
		// ----------------------------------------------------
		// Zone instance
		// ----------------------------------------------------
		
			// Container target
				private var container:Container;
		
			// Settings for the effects
				private var d0:int;
        		private var offset:Point;
	        	private var deltaPosition:Point;
        		private var speed:Point;
        
	        	public var factorDesacceleration:uint = 20;
        		public var factorAcceleration:uint = 50;
        		
        		public var _useScrollRect:Boolean;
        		public var _updateFunction:Function;
        		public var _onMouseDownFunction:Function;
        		public var _onMouseUpFunction:Function;
        		public var _onMouseOutFunction:Function;
        		
        		private var timerRefresh:Timer;
        
        	// Flag meaning if the mouse is pressed
        		private var isMouseDown:Boolean = false;
        	        
        	// Constructor
				public function IPhoneScrollerManager(container:Container, useScrollRect:Boolean = false, updateFunction:Function= null, onMouseDownFunction:Function= null, onMouseUpFunction:Function= null, onMouseOutFunction:Function= null)
				{
					this.container = container;
					_useScrollRect = useScrollRect;
					_updateFunction = updateFunction;
					_onMouseDownFunction = onMouseDownFunction;
					_onMouseUpFunction = onMouseUpFunction;
					_onMouseOutFunction = onMouseOutFunction;
					
					container.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
					container.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
					container.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
				}
				
			// Destructor
				public function dispose():void
				{
					container.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					container.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					//container.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);	
					
					if (timerRefresh != null)
					{
						timerRefresh.stop();
						timerRefresh.removeEventListener(TimerEvent.TIMER,onTick);
						timerRefresh = null;				
					}						
					
					speed = null;
					deltaPosition = null;
				}	
			
			// Mouse Down event: Check if the target is not the scrollbar
				private function onMouseDown(event:MouseEvent):void
				{
					if (!(event.target is ScrollThumb))
					{
						isMouseDown = true;
						
						if (timerRefresh == null)
						{
							timerRefresh = new Timer(20);
							timerRefresh.addEventListener(TimerEvent.TIMER,onTick);
							timerRefresh.start();				
						}
						
			            offset = new Point(event.stageX,event.stageY);
			            d0 = (new Date()).getTime();
			            
			            speed = new Point(0,0);
		   			}
		   			_onMouseDownFunction.apply(container);
		        }
        
        	// Mouse up event
	        private function onMouseUp (event:MouseEvent):void 
	        {
	        	if (isMouseDown)
	        	{
		        	isMouseDown = false;
		        	
		            deltaPosition = new Point(event.stageX - offset.x,event.stageY - offset.y);
		            var dt:int = (new Date()).getTime() - d0;
		            
		            speed = new Point(factorAcceleration*deltaPosition.x/dt,factorAcceleration*deltaPosition.y/dt);
	         	}
	         	_onMouseUpFunction.apply(container);
	        }
        	
        	// Mouse out event
	        private function onMouseOut (event:MouseEvent):void 
	        {
	        	onMouseUp(event);
	        	_onMouseOutFunction.apply(container);
	        }
	        
        	// Calcul
	 		private function onTick (e:TimerEvent):void 
	 		{		
	 			if (isMouseDown)
	 			{
					deltaPosition = new Point(container.stage.mouseX - offset.x,container.stage.mouseY - offset.y);
	            
		            speed = new Point(factorAcceleration*deltaPosition.x/500,factorAcceleration*deltaPosition.y/500);
		        }
	 			
	            if (speed.y > 0)
	            {
	                speed.y -= speed.y/factorDesacceleration;
	                
	                if (container.verticalScrollPosition > 0)
	                {
	                	container.verticalScrollPosition -= speed.y;
	                }
	            } 
	            else if (speed.y < 0) 
	            {
	                speed.y += -speed.y/factorDesacceleration;
	                
	                if (container.verticalScrollPosition < container.maxVerticalScrollPosition)
	                {
	                	container.verticalScrollPosition -= speed.y;
	                }
	            }
	            
	            if (speed.x > 0 )
	            {
	                speed.x -= speed.x/factorDesacceleration;
	                
	                if (container.horizontalScrollPosition > 0)
	                {
	                	container.horizontalScrollPosition -= speed.x;
	                }
	            } 
	            else if (speed.x < 0) 
	            {
	                speed.x += -speed.x/factorDesacceleration;
	                
	                if (container.horizontalScrollPosition < container.maxHorizontalScrollPosition)
	                {
	                	container.horizontalScrollPosition -= speed.x;
	                }
	            }
	            
	            if (_useScrollRect && _updateFunction != null) {
	            	_updateFunction.apply(container, [-speed.x, -speed.y]);
	            	//var rect:Rectangle = container.scrollRect;
	            	//rect.offset(speed.x, speed.y);
	            	//container.scrollRect = rect;
	            }
	            
	            for each (var item:UIComponent in container.getChildren())
	            {
	            	item.invalidateSize();
	            }
	        }
	}
}