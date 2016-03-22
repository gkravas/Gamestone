package gamestone.utils {

	//import flash.filesystem.File;
	//import flash.filesystem.FileMode;
	//import flash.filesystem.FileStream;
		
	public class DebugX {
		
		private static var textArea:Object;
		
		public static function init(ta:Object):void {
			textArea = ta;
		}
		
		public static function MyTrace(s:String):void {
			trace(s);
			if (textArea == null) return;
			textArea.text += s + "\n";
			textArea.verticalScrollPosition = textArea.maxVerticalScrollPosition;
		}
		
		public static function print(fileName:String):void {
			//if (textArea == null) return;
			//var stream:FileStream = new FileStream;
			//var file:File =  File.desktopDirectory.resolvePath(fileName);
			//stream.open(file, FileMode.WRITE);
			//stream.writeUTF(textArea.text);
			//stream.close();
		}
	}

}