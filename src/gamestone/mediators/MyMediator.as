package gamestone.mediators {
	
	import com.greensock.TweenMax;
	import com.greensock.events.TweenEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import gamestone.display.MySprite;
	import gamestone.graphics.ImgLoader;
	import gamestone.localization.LocalizationDictionary;
	
	import mx.core.IVisualElement;
	
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.Signal;
	import org.robotlegs.mvcs.Mediator;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	
	public class MyMediator extends Mediator {

		public var showed:DeluxeSignal;
		public var hided:DeluxeSignal;
		
		protected var locDic:LocalizationDictionary;
		protected var imgLoader:ImgLoader;
		protected var _showTween:TweenMax;
		protected var _hideTween:TweenMax;
		protected var _isModal:Boolean;
		protected var _mouseBlocker:MySprite;
		protected var _enabled:Boolean;
		
		public function MyMediator() {
			super();
			locDic = LocalizationDictionary.getInstance();
			imgLoader = ImgLoader.getInstance();
			_enabled = true;
			showed = new DeluxeSignal(this, MyMediator);
			hided = new DeluxeSignal(this, MyMediator);
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		protected function onShowComplete(e:Event = null):void {
			viewComponent.mouseEnabled = true;
			viewComponent.mouseChildren = true;
			showed.dispatch(this);
		}
		protected function onShowStart(e:Event = null):void {
			viewComponent.visible = true;
		}
		
		protected function onHideStart(e:Event = null):void {
			
		}
		
		protected function onHideComplete(e:Event = null):void {
			viewComponent.mouseEnabled = false;
			viewComponent.mouseChildren = false;
			viewComponent.visible = false;
			if (_isModal)
				destroyMouseBlocker();
			_isModal = false;
			hided.dispatch(this);
		}
		
		public function show(isModal:Boolean = false):void {
			if (!_enabled) return;
			_isModal = isModal;
			bringToFront();
			if (_isModal)
				createMouseBlocker();
			bringToFront();
			if (_showTween == null)
				onShowComplete();
			else {
				_showTween.restart();
				_showTween.play();
			}
		}
		public function hide():void {
			if (_hideTween == null) {
				viewComponent.visible = false;
				onHideComplete();
			} else {
				_hideTween.restart();
				_hideTween.play();
			}
		}
		
		protected function createMouseBlocker():void {
			var vc:BorderContainer = (viewComponent as BorderContainer);
			_mouseBlocker = new MySprite();
			_mouseBlocker.addChild(new Bitmap(new BitmapData(vc.root.width, vc.root.height, true, 0xFF000000)));
			_mouseBlocker.alpha = 0.2;
			(vc.owner as BorderContainer).addElement(_mouseBlocker);
			//var index:int = (vc.owner as BorderContainer).getElementIndex(vc);
			//(vc.owner as BorderContainer).setElementIndex(_mouseBlocker, index - 1);
		}
		protected function destroyMouseBlocker():void {
			(_mouseBlocker.owner as BorderContainer).removeElement(_mouseBlocker);
			_mouseBlocker.destroy();
			_mouseBlocker = null;
		}
		protected function bringToFront():void {
			var parent:BorderContainer = viewComponent.owner;
			var me:BorderContainer = viewComponent as BorderContainer;
			parent.setElementIndex(me, parent.numElements - 1);
			//((viewComponent as Group).parent as Group).setChildIndex(viewComponent
			//((viewComponent as Group).parent as Group).setElementIndex((viewComponent as Group), (viewComponent as Group).(parent as Group).numElements - 1);
		}
		
		//SETTERS
		public function set showTween(tween:TweenMax):void {
			_showTween = tween;
			_showTween.pause();
			_showTween.addEventListener(TweenEvent.START, onShowStart);
			_showTween.addEventListener(TweenEvent.COMPLETE, onShowComplete);
		}
		
		public function set hideTween(tween:TweenMax):void {
			_hideTween = tween;
			_hideTween.pause();
			_hideTween.addEventListener(TweenEvent.START, onHideStart);
			_hideTween.addEventListener(TweenEvent.COMPLETE, onHideComplete);
		}
		
		public function set enabled(value:Boolean):void {_enabled = value;}
		
		//GETTERS
		public function get uiX():int {return viewComponent.x;}
		public function get uiY():int {return viewComponent.y;}
		public function get enabled():Boolean {return _enabled;}
	}
	
}
