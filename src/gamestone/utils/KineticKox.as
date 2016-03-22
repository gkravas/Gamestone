package gamestone.utils
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.controls.scrollClasses.ScrollThumb;

	public class KineticKox extends Box
	{
        private var d0:int;
        private var offset:Point;
        private var deltaPosition:Point;
        private var speed:Point;
        
        public var factorDesacceleration:uint = 20;
        public var factorAcceleration:uint = 50;
        
        private var timerRefresh:Timer;
        
        private var isMouseDown:Boolean = false;
        	        
		public function KineticKox()
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
				
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
        }
        
        private function onMouseUp (event:MouseEvent):void 
        {
        	if (isMouseDown)
        	{
	        	isMouseDown = false;
	        	
	            deltaPosition = new Point(event.stageX - offset.x,event.stageY - offset.y);
	            var dt:int = (new Date()).getTime() - d0;
	            
	            speed = new Point(factorAcceleration*deltaPosition.x/dt,factorAcceleration*deltaPosition.y/dt);
         	}
        }
        	        
 		private function onTick (e:TimerEvent):void 
 		{		
 			if (isMouseDown)
 			{
				deltaPosition = new Point(stage.mouseX - offset.x,stage.mouseY - offset.y);
            
	            speed = new Point(factorAcceleration*deltaPosition.x/500,factorAcceleration*deltaPosition.y/500);
	        }
 			
            if (speed.y > 0)
            {
                speed.y -= speed.y/factorDesacceleration;
                
                if (this.verticalScrollPosition > 0)
                {
                	this.verticalScrollPosition -= speed.y;
                }
            } 
            else if (speed.y < 0) 
            {
                speed.y += -speed.y/factorDesacceleration;
                
                if (this.verticalScrollPosition < this.maxVerticalScrollPosition)
                {
                	this.verticalScrollPosition -= speed.y;
                }
            }
            
            if (speed.x > 0 )
            {
                speed.x -= speed.x/factorDesacceleration;
                
                if (this.horizontalScrollPosition > 0)
                {
                	this.horizontalScrollPosition -= speed.x;
                }
            } 
            else if (speed.x < 0) 
            {
                speed.x += -speed.x/factorDesacceleration;
                
                if (this.horizontalScrollPosition < this.maxHorizontalScrollPosition)
                {
                	this.horizontalScrollPosition -= speed.x;
                }
            }
        }
	}
}