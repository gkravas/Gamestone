package gamestone.graphics {

	import flash.display.*;
	import flash.errors.IllegalOperationError;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.LoaderContext;
	
	import gamestone.actions.ActionManager;
	import gamestone.events.ActionEvent;
	import gamestone.events.LoaderEvent;
	import gamestone.utils.DebugX;
	import gamestone.utils.IEmbededAssets;
	import gamestone.utils.XMLLoader;
	
	import mx.core.BitmapAsset;
	
	public class ImgLoader extends XMLLoader {
	
		private static var _this:ImgLoader;
		
		
		public static const DEBUG_LEVEL_NONE:int = 0;
		public static const DEBUG_LEVEL_1:int = 1;
		public static const DEBUG_LEVEL_2:int = 2;
		public static const DEBUG_LEVEL_3:int = 3;
		public static const DEBUG_LEVEL_4:int = 4;
		private static var debug:int = 0;
				
		public static var maxLoadingLagTime:int = 1000;
		
		public static var embededAssets:IEmbededAssets;
		
		private static var smoothImages:Boolean;
		
		public static var loadSequentially:Boolean;
		private var loadSequentiallyExternal:Boolean;
		
		private var imgInitParams:Object; 
		private var totalImages:uint, loadedImages:uint;
		private var totalExternalImages:uint, externalLoadedImages:uint;
		private var bitmaps:Object;
		private var bitmapNames:Array;
		private var parsers:Object;
		private var manipulators:Object;
		//private var imgManipulator:ImgManipulator;
		private var defaultParser:ImgParser;
		private var path:String = "";
		
		private var imgSlicer:ImgSlicer;
		private var actionManager:ActionManager;
		private var act_objConfirmLoad:Object;
		
		private var toLoad:Array; 
		
		public static function setDebug(i:int):void { debug = i; }
		public static function set smoothing(b:Boolean):void { smoothImages = b; }
		
		public function ImgLoader(pvt:PrivateClass) {
			if (pvt == null) {
				throw new IllegalOperationError("ImgLoader cannot be instantiated externally. ImgLoader.getInstance() method must be used instead.");
				return null;
			}
			bitmaps = {};
			bitmapNames = [];
			parsers = {};
			manipulators = {};
			imgInitParams = {};
			defaultParser = new ImgParser();
			imgSlicer = ImgSlicer.getInstance();
			loadSequentially = true;
			toLoad = [];
			act_objConfirmLoad = {};
			actionManager = ActionManager.getInstance();
		}
		
		public function setPath(path:String):void {
			this.path = path;
		}
		
		public static function getInstance():ImgLoader {
			if (ImgLoader._this == null)
				ImgLoader._this = new ImgLoader(new PrivateClass());
			return ImgLoader._this;
		}
		
		public function addManager(id:String, manager:ImgParser):void {
			parsers [id] = manager;
		}
		
		public function removeManager(id:String):Boolean {
			if (parsers [id] != null) {
				return delete parsers[id];
			} else return false;
		}
		
		public function addManipulator(id:String, im:ImgManipulator):void {
			manipulators [id] = im;
		}
		
		public function getBitmaps():Object {
			return bitmaps;
		}
		public function getBitmapNames():Array {
			return bitmapNames;
		}
		
		public function slice(id:String):BitmapFileInfo {
			var obj:BitmapFileInfo = getBitmapInfo(id);
			if (obj == null) {
				DebugX.MyTrace("Bitmap with id=" + id + " not found in ImgLoader. No bitmap exists to slice up.");
				return null;
			}
			// Cache system
			// If bitmaps parameter is not set in BitmapFileInfo object,
			// it needs to be sliced
			// #################

			try {
				if (obj.bitmaps == null)
					obj.bitmaps = imgSlicer.slice(obj.bitmap, obj.columns, obj.rows, obj.hasSliceDimensions);
			} catch (error:TypeError) {
				var noBitmap:Boolean = obj.bitmap == null;
				DebugX.MyTrace("TypeError: BitmapFileInfo with id=" + id + " does not have a .bitmap property\n   at ImgLoader.slice().");
			}
			return obj;
		}
		
		public function clearSliceCache(id:String):Boolean {
			var obj:BitmapFileInfo = getBitmapInfo(id);
			
			if (obj == null)
				return false;
			
			DebugX.MyTrace("clearSliceCache:" + id);
			obj.bitmaps = null;
			return true;
		}
	
		
		protected override function xmlLoaded(e:Event):void {
			loadedImages = 0;
			totalImages = 0;
			
			var xml:XML = XML(xmlLoader.data);
			
			xmlLoader = null;
			
			var images:XMLList = xml.img;
			var image:XML;
			
			var nodes:Array;
			var _class:String;
			var id:String;
			var slices:Array;
			var node:ImgInitParams;
			
			toLoad = [];
			//Debug.DebugX.MyTrace("TIMER: " + getTimer());
			for each(image in images) {
				_class = image.@["class"];
				
				if (_class != null && _class !== "Default" && parsers[_class] != null)
					nodes = ImgParser(parsers[_class]).getProccessedNodes(image);
				else
					nodes = defaultParser.getProccessedNodes(image);
				
				
				for each (node in nodes) {
					id = node.id;
					bitmapNames.push(id);
					
					if (!node.startLoading) {
						imgInitParams[node.id] = node;
						continue;
					}
					//Modified by George Kravas
					if (getBitmapInfo(id) != null ) {
						DebugX.MyTrace("Warning: ImageLoader: Duplicate id :" + id + ", for " + node.file + ". The file will not be loaded");
						continue;
					} else if(id == "") {
						DebugX.MyTrace("Warning: ImageLoader: File " + node.file + ", has empty id and will not be loaded");
						continue;
					}
					
					bitmaps[id] = new BitmapFileInfo(_class,
													 node.slices[0],
													 node.slices[1],
													 new Point(node.pivotPoint.x, node.pivotPoint.y),
													 node.hasSliceDimensions);
					//actionManager.add("", loadImage, 40, 1, id, node.file);
					if (loadSequentially)
						toLoad.push([id, node.file, node.embeded]);
					else
						loadImage(id, node.file, node.embeded);
					totalImages++;
				}
			}
			if (loadSequentially)
				loadNext();
		}
		
		private function loadImage(id:String, file:String, embeded:Boolean):void {
			//Debug.DebugX.MyTrace("loading " + path + file);
			if (embeded) {
				embededImageLoaded(id);
				return;
			}
			
			var loader:LoaderX = new LoaderX();
				
			loader.imageID = id;
			loader.contentLoaderInfo.addEventListener(Event.INIT, imageLoadedInternal, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoadingComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.OPEN, loadingStarted, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.UNLOAD, unloadingImage, false, 0, true);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, imageProgress, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			
			var actionID:int = actionManager.addAction(ActionManager.SYSTEM, imageLoadTimeout, maxLoadingLagTime, 1, id, file);
			act_objConfirmLoad[id] = actionID;
			
			debugTrace("Load " + id, DEBUG_LEVEL_1);
			loader.load(new URLRequest(path + file));
		}
		
		private function imageLoadTimeout(event:ActionEvent):void {
			var id:String = event.arguments[0] as String;
			if (!isNaN(act_objConfirmLoad[id])) {
				debugTrace("IMAGE NOT LOADED!! Loading again " + id, DEBUG_LEVEL_1);
				var file:String = event.arguments[1] as String;
				var embeded:Boolean = event.arguments[2] as Boolean;
				loadImage(id, file, embeded);
			}
		}
		
		private function externalImageLoadTimeout(event:ActionEvent):void {
			var params:ImgInitParams = event.arguments[0] as ImgInitParams;
			var id:String = params.id;
			
			if (!isNaN(act_objConfirmLoad[id])) {
				debugTrace("IMAGE NOT LOADED!! Loading again " + id, DEBUG_LEVEL_1);
				var file:String = event.arguments[1] as String;
				loadExternalImage(params);
			}
		}
		
		private function imageLoadingComplete(event:Event):void {
			debugTrace("imageLoadingComplete: " + LoaderX(LoaderInfo(event.target).loader).imageID, DEBUG_LEVEL_3);
		}
		
		private function loadingStarted(event:Event):void {
			debugTrace("loadingStarted: " + event.target + ", " + event.target.url, DEBUG_LEVEL_3);
		}
		
		private function unloadingImage(event:Event):void {
			debugTrace("unloadingImage: " + event.target, DEBUG_LEVEL_3);
		}
		
		private function imageProgress(event:ProgressEvent):void {
			debugTrace("imageProgress: " + event.currentTarget.url + ", " + event.bytesLoaded + "/" + event.bytesTotal, DEBUG_LEVEL_4);
		}
	
		private function ioErrorHandler(event:IOErrorEvent):void {
			DebugX.MyTrace("ioErrorHandler: " + event);
		}
		
		private function removeConfirmLoadAction(imageID:String):void {
			var actionID:int = act_objConfirmLoad[imageID];
			actionManager.removeAction(actionID);
			delete act_objConfirmLoad[imageID];
		}
		
		private function imageLoaded(event:Event):void {
			var loader:LoaderX = LoaderX(LoaderInfo(event.target).loader);
			var id:String = loader.imageID;
			removeConfirmLoadAction(id);
			
			var bitmapData:BitmapData = Bitmap(loader.content).bitmapData;
			var info:BitmapFileInfo = bitmaps[id] as BitmapFileInfo;
			var _class:String = info.className;
			var manipulator:ImgManipulator = manipulators[_class];
			
			
			debugTrace(" -- LOADED: " + id, DEBUG_LEVEL_1);
			
			info.bitmap = bitmapData;

			if (_class != null && manipulator != null)
				info.bitmap = manipulator.getProccessedBitmap(id, info);

			if (loadSequentially && toLoad.length > 0 && !loadSequentiallyExternal)
				loadNext();

			debugTrace("Images left to load: " + toLoad.length, DEBUG_LEVEL_2);
			
			if (loadSequentiallyExternal) {
				if (toLoad.length > 0) {
					loadNextExternal();
				} else
					loadSequentiallyExternal = false;
			}
			
			
			loader.unload();
			
			loader.contentLoaderInfo.removeEventListener(Event.INIT, imageLoadedInternal);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoadingComplete);
			loader.contentLoaderInfo.removeEventListener(Event.OPEN, loadingStarted);
			loader.contentLoaderInfo.removeEventListener(Event.UNLOAD, unloadingImage);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, imageProgress);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			
			dispatchEvent(new LoaderEvent(LoaderEvent.ASSET_LOADED, loadedImages, totalImages));
		}
		
		private function embededImageLoaded(id:String):void {
			removeConfirmLoadAction(id);
			
			var info:BitmapFileInfo = bitmaps[id] as BitmapFileInfo;
			var cl:Class = embededAssets.getAssetClass(id) as Class;
			var ba:BitmapAsset = new cl as BitmapAsset;
			info.bitmap = ba.bitmapData;
			var _class:String = info.className;
			var manipulator:ImgManipulator = manipulators[_class];
			
			if (_class != null && manipulator != null)
				info.bitmap = manipulator.getProccessedBitmap(id, info);
			
			dispatchEvent(new LoaderEvent(LoaderEvent.ASSET_LOADED, loadedImages, totalImages));
			if (loadSequentially && toLoad.length > 0)
				loadNext();
			embededImageLoadedInternal();
			
		}
		private function loadNext():void {
			var arr:Array = toLoad.shift();
			loadImage(arr[0], arr[1], arr[2]);
		}
		
		private function loadNextExternal():void {
			var image:ImgInitParams = toLoad.shift();
			loadExternalImage(image);
		}
		
		private function imageLoadedInternal(event:Event):void {
			//Debug.trace(" -- Loaded (" + (loadedImages + 1) + "/" + totalImages + ") " + LoaderInfo(event.target).url);
			imageLoaded(event);
			checkInternalLoadingComplete();
		}
		
		private function embededImageLoadedInternal():void {
			checkInternalLoadingComplete();
		}
		
		private function checkInternalLoadingComplete():void {
			if (++loadedImages == totalImages) {
				dispatchEvent(new Event(Event.COMPLETE));
				runGC();
				//act_objConfirmLoad = [];
			}
		}
		
		private function imageLoadedExternal(event:Event):void {
			imageLoaded(event);
			checkExternalLoadingComplete();
		}
		
		private function checkExternalLoadingComplete():void {
			if (++externalLoadedImages == totalExternalImages) {
				dispatchEvent(new LoaderEvent(LoaderEvent.EXTERNAL_ASSETS_COMPLETE));
				runGC();
			}
		}
		
		// External - should only be called by other classes, not ImgLoader
		public function loadImages(list:Array):void {
			/*var image:ImgInitParams;
			toLoad = list;
			totalExternalImages = list.length;
			externalLoadedImages = 0;
			for each(image in list) 
				loadExternalImage(image);*/
			
			toLoad = list;
			totalExternalImages = toLoad.length;
			externalLoadedImages = 0;
			loadSequentiallyExternal = true;
			loadNextExternal();
			
		}
		
		public function unloadImages(list:Array):void {
			var params:ImgInitParams;
			for each(params in list) {
				unloadImage(params.id);
			}
			runGC();
		}
		
		public function runGC():void {
			// Make sure the Garbage Collector runs a full mark/sweep to free up memory
			/*DebugX.MyTrace("#@#@# Forcing the GC to perform a mark/sweep @#@#@");
			try {
			   new LocalConnection().connect('foo');
			   new LocalConnection().connect('foo');
			} catch (e:*) {}*/
			// the GC will perform a full mark/sweep on the second call.
		}
		
		public function unloadImagesByID(list:Array):void {
			var id:String;
			for each(id in list) {
				unloadImage(id);
			}
		}
		
		public function countImages():void {
			var cnt:int = 0, b:BitmapFileInfo;
			for each(b in bitmaps)
				cnt++;
			DebugX.MyTrace("Total BitmapFileInfo objects in ImgLoader: " + cnt);
		}
		
		public function unloadImage(id:String):void {
			if( bitmaps[id] != null ) {
				BitmapFileInfo(bitmaps[id]).dispose();
				delete bitmaps[id];
				DebugX.MyTrace("Unloaded: " + id + " --> " + bitmaps[id]);
			}
			else
				DebugX.MyTrace("Warning: Cannot unload image with id = " + id + ". Image does not exist.");
		}
		
		public function loadExternalImage(params:ImgInitParams, overridePath:Boolean = false):void {
			debugTrace("Load external: " + params, DEBUG_LEVEL_1);
			
			if (params == null) {
				DebugX.MyTrace("WARNING: loadExternalImage(), provided ImgInitParams is null. No image exists to load.");
				checkInternalLoadingComplete();
				return;
			}
			
			var loader:LoaderX = new LoaderX();
			
			loader.imageID = params.id;
			loader.contentLoaderInfo.addEventListener(Event.INIT, imageLoadedExternal, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoadingComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.OPEN, loadingStarted, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.UNLOAD, unloadingImage, false, 0, true);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, imageProgress, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			
			bitmaps[params.id] = new BitmapFileInfo(params.className,
													 params.slices[0],
													 params.slices[1],
													 new Point(params.pivotPoint.x, params.pivotPoint.y),
													 params.hasSliceDimensions);
			if(overridePath)
				loader.load(new URLRequest(params.file), new LoaderContext(true));
			else
				loader.load(new URLRequest(path + params.file), new LoaderContext(true));
			
			var actionID:int = actionManager.addAction(ActionManager.SYSTEM, externalImageLoadTimeout, maxLoadingLagTime, 1, params);
			act_objConfirmLoad[params.id] = actionID;
		}
		
		public function loadImagesByGroups(groupsOfGroups:Array):void {
			if(groupsOfGroups.length == 0) {
				dispatchEvent(new LoaderEvent(LoaderEvent.EXTERNAL_ASSETS_COMPLETE));
				//act_objConfirmLoad = [];
				return;
			}
			
			debugTrace("LOAD IMAGES BY GROUPS ::::::: " + groupsOfGroups.join("\n"), DEBUG_LEVEL_1);
			var groups:Array;
			/*
			var optGroups:Array = [];
			var groups:Array;
			for each(groups in groupsOfGroups) {
				if (groups.length == 1)
					optGroups.push(groups[0]);
			}*/
			
			debugTrace("groupsOfGroups: " + groupsOfGroups +", " + groupsOfGroups.length, DEBUG_LEVEL_1);
			for each(groups in groupsOfGroups) {
				debugTrace("groups:   " + groups, DEBUG_LEVEL_1);
				toLoad = toLoad.concat(getImagesByGroup(groups));
			}
			totalExternalImages = toLoad.length;
			externalLoadedImages = 0;
			loadSequentiallyExternal = true;
			loadNextExternal();
		}
		
		public function loadImageByID(id:String):void {
			var img:ImgInitParams = imgInitParams[id];
			
			if(img != null)
				loadExternalImage(img);
		}
		
		public function loadImagesByGroup(groups:Array):void {
			toLoad = getImagesByGroup(groups);
			totalExternalImages = toLoad.length;
			externalLoadedImages = 0;
			loadSequentiallyExternal = true;
			loadNextExternal();
		}
		
		public function unloadImagesByGroups(groupsOfGroups:Array):void {
			if(groupsOfGroups.length == 0)
				return;
			
			debugTrace("UNLOAD IMAGES BY GROUPS ---- " + groupsOfGroups.join("\n"), DEBUG_LEVEL_1);
			var optGroups:Array = [];
			var groups:Array;
			for each(groups in groupsOfGroups) {
				if (groups.length == 1)
					optGroups.push(groups[0]);
			}
			
			var arr:Array = [];
			for each(groups in groupsOfGroups) {
				debugTrace("groups:   " + groups, DEBUG_LEVEL_2);
				arr = arr.concat(getImagesByGroup(groups));
			}
			
			unloadImages(arr);
		}
		
		public function unloadImagesByGroup(groups:Array):void {
			var arr:Array = getImagesByGroup(groups);
			var img:ImgInitParams;
			
			for each(img in arr) {
				unloadImage(img.id);
			}
		}
		
		private function getImagesByGroup(groups:Array):Array {
			var image:ImgInitParams;
			var arr:Array = [];
			
			for each(image in imgInitParams) {
				debugTrace(image.id, DEBUG_LEVEL_2);
				if (checkGroups(image.groups, groups)) {
					arr.push(image);
					debugTrace("Pushing image in aray --> " + image.id, DEBUG_LEVEL_1);
				}
			}

			return arr;
		}
		
		//groups1 is ImgInitParams groups
		//groups2 is filtering groups
		private function checkGroups(groups1:Array, groups2:Array):Boolean {
			var imgGroup:String;
			var filterGroup:String;
			
			groups1 = groups1.slice();
			groups2 = groups2.slice();
			groups1.sort();
			groups2.sort();
			
			var str2:String = groups2.join(",");
			var str1:String = groups1.join(",").substr(0, str2.length);
			
			debugTrace("     |" + str1 + "| == |" + str2 + "|  ?", DEBUG_LEVEL_2);
			
			return str1 == str2;
		}
		
		public function getBitmapInfo(id:String):BitmapFileInfo {
			if (bitmaps[id] != null)
				return BitmapFileInfo(bitmaps[id]);
			//else 
				//DebugX.MyTrace("Error: ImgLoader.getBitmapInfo(), image with id=" + id + " does not exist.");
			return null;
		}
		
		public function getBitmapData(id:String):BitmapData {
			if (bitmaps[id] != null) {
				var bd:BitmapData = (bitmaps[id] as BitmapFileInfo).bitmap;
				return bd;
			}
			//else 
				//DebugX.MyTrace("Error: ImgLoader.getBitmapInfo(), image with id=" + id + " does not exist.");
			return null;
		}
		
		public function getBitmapAsset(id:String):BitmapAsset {
			if (bitmaps[id] != null) {
				var ba:BitmapAsset = new BitmapAsset((bitmaps[id] as BitmapFileInfo).bitmap);
				ba.smoothing = smoothImages
				return ba;
			}
			//else 
			//DebugX.MyTrace("Error: ImgLoader.getBitmapInfo(), image with id=" + id + " does not exist.");
			return null;
		}
		
		private function debugTrace(s:*, level:int):void {
			if (debug >= level)
				DebugX.MyTrace(s);
		}
		
	}
	
}

class PrivateClass {}