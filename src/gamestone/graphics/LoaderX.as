package gamestone.graphics {

import flash.display.*;
	
public class LoaderX extends Loader {
	
	private var _imageID:String;
	
	public function LoaderX() {
		super();
	}
	
	public function set imageID(id:String):void {
		_imageID = id;
	}
	
	public function get imageID():String {
		return _imageID;
	}
	
	
	
}
	
}