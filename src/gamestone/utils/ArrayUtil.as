package gamestone.utils {
	
	import flash.utils.getTimer;
	
	public class ArrayUtil {
	
		private static var _REVERSE:Number = 1;
		private static var _EMPTY_ARRAY:String = "__EMPTY_ARRAY__";
		
		public static function hasPrimitive(arr:Array, p:*, char:String = ","):Boolean {
			return (char + arr.join(char) + char).indexOf(char+p+char) >= 0;
		}
		
		public static function remove(arr:Array, p:*):Array {
			var i:int = arr.indexOf(p);
			var arr1:Array = arr.concat();
			if (i >= 0) {
				arr1.splice(i, 1);
				return arr1;
			} else
				return arr1;
		}
		
		public static function swap(arr:Array, index1:int, index2:int):Array {
			var item1:* = arr[index1];
			var item2:* = arr[index2];
			arr[index1] = item2;
			arr[index2] = item1;
			return arr;
		}
		
		public static function getLastElement(arr:Array):Object {
			return arr[arr.length - 1];
		}
		
		public static function inArray(arr:Array, o:Object, startIndex:uint = 0):Boolean {
			return arr.indexOf(o, startIndex) >= 0;
		}
		
		public static function inArrayFromArray(arr:Array, arr1:Array, startIndex:uint = 0):Boolean {
			var o:Object;
			for each (o in arr1) {
				if (inArray(arr, o))
					return true;
			}
			return false;
		}
		
		public static function indexedAt(arr:Array, o:Object):Number {
			var i:Number = arr.length;
			while (--i >= 0) {
				if (arr[i] == o) return i;
			}
			return -1;
		}
		
		public static function setNullValue(arr:Array, o:Object):void {
			var i:Number = ArrayUtil.indexedAt(arr, o);
			arr[i] = null;
		}
		
		public static function shuffle(arr:Array):Array {
			arr.sort(ArrayUtil.shuffleSort);
			return arr;
		}
		
		public static function reverse(arr:Array):Array {
			var newArr:Array = [];
			var i:Number = arr.length;
			while (--i >= 0) {
				newArr.push(arr[i]);
			}
			return newArr;
		}
		
		public static function sortByLength(arr:Array, reverse:Number):Array {
			!reverse == ArrayUtil.REVERSE ? arr.sort(ArrayUtil.lengthSort) : arr.sort(ArrayUtil.reverseLengthSort);
			return arr;
		}
		
		private static function shuffleSort(a:Number, b:Number):Number {
			var r1:Number = Math.random();
			var r2:Number = Math.random();
			if (r1 < r2) {
				return 1;
			} else if (r1 > r2) {
				return -1;
			} else {
				return 0;
			}
		}
		
		private static function lengthSort(a:Array, b:Array):Number {
			if (a.length < b.length)
				return 1;
			else if (a.length > b.length)
				return -1;
			else
				return 0;
		}
		
		private static function reverseLengthSort(a:Array, b:Array):Number {
			if (a.length > b.length)
				return 1;
			else if (a.length < b.length)
				return -1;
			else
				return 0;
		}
		
		public static function cycle (arr:Array, steps:Number):Array {
			var index:Number;
			var slice1:Array;
			var slice2:Array;
			if (steps >= 0) {
				index = arr.length - steps;
				slice1 = arr.slice(0, index);
				slice2 = arr.slice(index);
				return slice2.concat(slice1);
			} else {
				index = -steps;
				slice1 = arr.slice(index);
				slice2 = arr.slice(0, index);
				return slice1.concat(slice2);
			}
		}
		
		public static function getRandomValue(arr:Array):* {
			return arr [NumberUtil.randomInt(0, arr.length - 1)];
		}
		
		public static function getRandomIndex(arr:Array):int {
			return NumberUtil.randomInt(0, arr.length - 1);
		}
		
		public static function getShuffledSlice(a:Array, total:int):Array {
			var g:int = getTimer();
			var source:Array = a.concat();
			var arr:Array = [];
			var i:int = total;
			var index:int;
			while (i-- > 0) {
				index = getRandomIndex(source);
				arr.push(source.splice(index, 1)[0]);
			}
			return arr;
		}
		
		public static function horizontal2Vertical(arr:Array):Array {
			var newArray:Array = [];
			
			var i:Number = arr[0].length;
			while (--i >= 0) {
				newArray[i] = [];
			}
			
			i = arr.length;
			while (--i >= 0) {
				var j:Number = arr[i].length;
				while (--j >= 0) {
					newArray[j][i] = arr[i][j];
				}
			}
			return newArray;
		}
		
		public static function expand2D(arr:Array, rows:Number, columns:Number, emptyChar:String):Array {
			// If expansion is not possible with the given values
			// return (a copy of) the old array
			if ((rows < arr.length || columns < arr[0].length)
				|| (rows == arr.length && columns == arr[0].length)) {
				return arr.slice();
			}
			
			var arrChars:Array;
			if (emptyChar == null) arrChars = [" "];
			// You can provide all the chars you want inside the emptyChar string e.g. SKLSFDJ@#$KDFGSDF
			else
				arrChars = emptyChar.split("");
			
			var _cnt:Number = 0;
			var getEmptyChar:Function = function():String {
				_cnt++;
				if (_cnt > arrChars.length - 1) _cnt = 0;
				return arrChars [_cnt];
			}
			
			var newArray:Array = [];
			
			var i:Number = rows;
			while (--i >= 0) {
				newArray[i] = [];
			}
			
			while (--i >= 0) {
				var j:Number = columns;
				while (--j >= 0) {
					newArray[i][j] = (i > arr.length - 1 || j > arr[0].length - 1) ? getEmptyChar() : arr[i][j];
				}
			}
			
			return newArray;
		}
		
		public static function quickCreate(length:int, itemToPlace:* = null):Array {
			var arr:Array = [];
			while (--length >= 0)
				arr [length] = itemToPlace;
			return arr;
		}
		
		public static function createArray(length:int, itemToPlace:* = null):Array {
			var fillWith:Array;
			var arr:Array = [];
			while (--length >= 0) {
				if (itemToPlace == _EMPTY_ARRAY)
					fillWith = new Array();
				else
					fillWith = itemToPlace;
				arr [length] = fillWith;
			}
			return arr;
		}
		
		public static function create2DArray(rows:Number, columns:Number, itemToPlace:Object):Array {
			if (itemToPlace == null) itemToPlace = null;
			var arr:Array = [];
			var r:Number = rows;
			while (--r >= 0) {
				arr [r] = [];
				var c:Number = columns;
				while (--c >= 0) {
					arr [r][c] = itemToPlace;
				}
			}
			return arr;
		}
		
		public static function getSum(arr:Array):Number {
			var sum:Number = 0;
			var n:Number = arr.length;
			while (--n >= 0) {
				sum += Number(arr [n]);
			}
			return sum;
		}
		
		public static function unserializeTo2DArray(str:String, columnDelimeter:String, rowDelimeter:String):Array {
			var arr:Array = str.split(rowDelimeter);
			var i:Number = arr.length;
			while (--i >= 0)
				arr[i] = arr[i].split(columnDelimeter);
			return arr;
		}
		
		public static function unserializeTo2DObjectArray(str:String, columnDelimeter:String, rowDelimeter:String):Array {
			var arr:Array = unserializeTo2DArray(str, columnDelimeter, rowDelimeter);
			var keys:Array = arguments.slice(3);
			
			var i:Number = arr.length;
			while (--i >= 0) {
				var tmp:Array = arr[i].slice();
				arr[i] = {};
				var k:Number = keys.length;
				while (--k >= 0)
					arr[i][keys[k]] = tmp.pop();
			}
			return arr;
		}
		
		public static function stripDuplicates(arr:Array):Array {
			var a:Array = [];
			
			var i:int = -1;
			var l:int = arr.length;
			while (++i < l) {
				if (!ArrayUtil.inArray(a, arr[i]))
					a.push(arr[i]);
			}
			return a;
		}
		
		public static function stripEmpty(arr:Array):Array {
			var o:Object;
			var a:Array = [];
			
			for each(o in arr) {
				if (o != null)
					a.push(o);
			}
			return a;
		}
		
		public static function allValuesAreTheSame(arr:Array):Boolean {
			var v:* = arr[0];
			var i:Number = arr.length;
			while (--i >= 0) {
				if (arr[i] != v)
					return false;
			}
			return true;
		}
		
		public static function getValues(src:Array, ind:Array):Array {
			var arr:Array = [];
			var l:Number = ind.length;
			for (var i:Number=0; i<l; i++) {
				arr.push(src[ind[i]]);
			}
			return arr;
		}
		
		public static function splitToNumbers(str:String, delimiter:String = ","):Array {
			return ArrayUtil.toNumbers(str.split(delimiter));
		}
		
		public static function splitToIntegers(str:String, delimiter:String = ","):Array {
			return ArrayUtil.toIntegers(str.split(delimiter));
		}
		
		public static function splitToObject(arr:Array, delimiter:String = ":"):Object {
			var arr1:Array;
			var obj:Object = {};
			
			for (var i:String in arr) {
				arr1 = String(arr[i]).split(delimiter);
				obj[arr1[0]] = String(arr1[1]);
			}
			return obj;
		}
		
		public static function toNumbers(arr:Array):Array {
			var l:uint = arr.length - 1;
			var i:uint;
			for each (i in arr) {
				i = Number(i);
				if (isNaN(i))
					i = 0;
			}
			return arr;
		}
		
		public static function toIntegers(arr:Array):Array {
			var l:uint = arr.length - 1;
			for (var i:int=l; i>=0; --i) {
				arr[i] = parseInt(arr[i]);
				if (isNaN(arr[i]))
					arr[i] = 0;
			}
			return arr;
		}
		
		public static function firstEmptyIndex(arr:Array):Number {
			var l:Number = arr.length;
			for (var i:Number=0; i<l; ++i) {
				if (arr[i] == null)
					return i;
			}
			return -1;
		}
		
		public static function lastEmptyIndex(arr:Array):Number {
			var l:Number = arr.length - 1;
			for (var i:Number=l; i>=0; --i) {
				if (arr[i] == null)
					return i;
			}
			return -1;
		}
		
		
		// Get static
		public static function get REVERSE():Number {
			return ArrayUtil._REVERSE;
		}
		
		public static function get EMPTY_ARRAY():String {
			return ArrayUtil._EMPTY_ARRAY;
		}
	
	}

}