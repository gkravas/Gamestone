package gamestone.utils {

public class Delegate extends Object {
	
	public static var stack:Object = {};
	private static var _i:Number = 0;

	private static var temp:Array = [];
	
	public static function getIndex():Number { return _i; }
	
	public static function create(obj:Object, _func:Function):Function {
		//trace("adding: "+_i);
		//save("adding: "+_i);
		var f:Function = stack[_i] = function():* {
			var self:Function = arguments.callee;
			var _scope:Object = self._scope;
			var _func:Function = self._func;
			var _arg:Array = self._arg;
	
			return _func.apply(_scope, arguments.concat(_arg));
		};
		
		//var f = stack[_i];
		stack[_i]._scope = obj;
		stack[_i]._func = _func;
		stack[_i]._arg = arguments.splice(2);
		stack[_i]._i = _i;
		_i++;
		
		//_level0.TOTALDELEGATES = util.ObjectUtils.length(stack);
		
		
		return f;
	}
	
	public static function dump(id:String):void {
		if (!id) id = "";
		trace("---------- " + id + " ------------");
		//trace("Stack length: "+util.ObjectUtils.length(stack));
		trace("\n");
	}
	
	public static function destroy(f:Object):void {
		if (!(f is Function))
			return;
		if (!f || f["_i"] == null) return;
		//trace(" Deleting: "+f._i);
		//save(" Deleting: "+f._i);
		delete f["_scope"];
		delete f["_func"];
		delete f["_arg"];
		delete stack[f["_i"]];
		delete f["_i"];
	}
	
	public static function save(s:String):void {
		//trace(s);
		return;
		
		/////
		temp.push(s);
		if (temp.length == 500)
			dumpFile();
	}
	
	public static function dumpFile():void {
		//mdm.FileSystem.appendFile("d:\\bounty.txt", temp.join("\n"));
		//temp = [];
	}
	
}

}