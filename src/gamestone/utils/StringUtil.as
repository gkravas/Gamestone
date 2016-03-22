package gamestone.utils {

import flash.geom.Rectangle;
import flash.utils.getTimer;

public class StringUtil {
	
	private static var profanityRoots:Array = ["fuck", "bastard", "vagina", "nigger", "asshole", "shithead"];
	private static var profanityWords:Array = ["damn", "shit", "pussy", "ass", "bitch"];
	
	public static function totalChars (string:String, sChar:String):Number {
		var cnt:Number = 0;
		var sl:Number = string.length;
		var ol:Number = sChar.length;
		var i:Number = sl + 1;
		while (--i > 0) {
			if (string.substr(i - ol, ol) == sChar) cnt++;
		}
		return cnt;
	}

	/**
	* @method endswith
	* @description check if input string (inString) terminates with the given char/string (sChar)
	* @param inString String
	* @param sChar String
	* @returns Boolean
	*/
	static public function endswith(inString:String, sChar:String):Boolean
	{
			var l_index:Number = inString.lastIndexOf(sChar);
			var s_count:int = inString.length;
			var c_count:int = sChar.length;
			return (s_count - c_count == l_index);
	}
	/**
	* @method startwith
	* @description check if input string (inString) begin with the given char/string (sChar)
	* @param inString String
	* @param sChar String
	* @returns Boolean
	*/
	static public function startswith(inString:String, sChar:String):Boolean {
		return inString.indexOf(sChar) == 0;
	}
	/**
	* @method lstrip
	* @description trim left a string
	* @param inString String
	* @returns String
	*/
	static public function lstrip(inString:String):String {
		inString = String(inString);
		var index:int = 0;
		while(inString.charCodeAt(index) < 33){
			index++;
		}
		return inString.substr(index);
	}
	/**
	* @method rstrip
	* @description trim right a string
	* @param inString String
	* @returns String
	*/
	static public function rstrip(inString:String):String {
		inString = String(inString);
		var index:int = inString.length - 1;
		while(inString.charCodeAt(index) < 33){
			index--;
		}
		return inString.substr(0,index + 1);
	}
	/**
	* @method strip
	* @description trim a string
	* @param inString String
	* @returns String
	*/
	static public function strip(inString:String):String
	{
		return StringUtil.rstrip(StringUtil.lstrip(inString))
	}
	/**
	* @method capitalize
	* @description Convert the first char of every string words in uppercase
	* @param inString String
	* @returns String
	*/
	static public function capitalize(inString:String):String
	{
			var a:Number = 0;
			var aString:Array = inString.split(" ");
			for(a = 0; a < aString.length; a++)
			{
					aString[a] = aString[a].substring(0,1).toUpperCase() + aString[a].substring(1, aString[a].length).toLowerCase();
			}
			return aString.join(" ");
	}
	
	static public function capitalizeFirst(s:String):String {
		return s.substr(0, 1).toUpperCase() + s.substr(1);
	}
	
	static public function capitalizeFirstOnly(s:String):String {
		return s.substr(0, 1).toUpperCase() + s.substr(1).toLowerCase();
	}
	
	static public function makeSmallFirst(s:String):String {
		return s.substr(0, 1).toLowerCase() + s.substr(1);
	}
	
	/**
	* @method replace
	* @description replace all occurrence of a char into a string with the new char
	* @param inStr String to be converted
	* @param oldChar String value to replace
	* @param newChar String new value replaced
	* @return String
	*/
	static public function replace(inStr:String, oldChar:String, newChar:String):String
	{
			if(inStr == null)
				return inStr;
			else
			return inStr.split(oldChar).join(newChar);
	}

	/**
	* @method md5
	* @description encrypt a string using the MD5 crypt hash
	* @param str String string to be crypted
	* @return String
	*/
	/*static public function md5(str:String):String
	{
			function safe_add(x, y)
			{
					var lsw = (x & 0xFFFF) + (y & 0xFFFF);
					var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
					return (msw << 16) | (lsw & 0xFFFF);
			}
			function rol(num, cnt)
			{
					return (num << cnt) | (num >>> (32 - cnt));
			}
			function cmn(q, a, b, x, s, t)
			{
					return safe_add(rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b);
			}
			function ff(a, b, c, d, x, s, t)
			{
					return cmn((b & c) | ((~b) & d), a, b, x, s, t);
			}
			function gg(a, b, c, d, x, s, t)
			{
					return cmn((b & d) | (c & (~d)), a, b, x, s, t);
			}
			function hh(a, b, c, d, x, s, t)
			{
					return cmn(b ^ c ^ d, a, b, x, s, t);
			}
			function ii(a, b, c, d, x, s, t)
			{
					return cmn(c ^ (b | (~d)), a, b, x, s, t);
			}
			function coreMD5(x)
			{
					var a = 1732584193;
					var b = -271733879;
					var c = -1732584194;
					var d = 271733878;
					for (var i = 0; i < x.length; i += 16)
					{
							var olda = a;
							var oldb = b;
							var oldc = c;
							var oldd = d;
							a = ff(a, b, c, d, x[i + 0], 7, -680876936);
							d = ff(d, a, b, c, x[i + 1], 12, -389564586);
							c = ff(c, d, a, b, x[i + 2], 17, 606105819);
							b = ff(b, c, d, a, x[i + 3], 22, -1044525330);
							a = ff(a, b, c, d, x[i + 4], 7, -176418897);
							d = ff(d, a, b, c, x[i + 5], 12, 1200080426);
							c = ff(c, d, a, b, x[i + 6], 17, -1473231341);
							b = ff(b, c, d, a, x[i + 7], 22, -45705983);
							a = ff(a, b, c, d, x[i + 8], 7, 1770035416);
							d = ff(d, a, b, c, x[i + 9], 12, -1958414417);
							c = ff(c, d, a, b, x[i + 10], 17, -42063);
							b = ff(b, c, d, a, x[i + 11], 22, -1990404162);
							a = ff(a, b, c, d, x[i + 12], 7, 1804603682);
							d = ff(d, a, b, c, x[i + 13], 12, -40341101);
							c = ff(c, d, a, b, x[i + 14], 17, -1502002290);
							b = ff(b, c, d, a, x[i + 15], 22, 1236535329);
							a = gg(a, b, c, d, x[i + 1], 5, -165796510);
							d = gg(d, a, b, c, x[i + 6], 9, -1069501632);
							c = gg(c, d, a, b, x[i + 11], 14, 643717713);
							b = gg(b, c, d, a, x[i + 0], 20, -373897302);
							a = gg(a, b, c, d, x[i + 5], 5, -701558691);
							d = gg(d, a, b, c, x[i + 10], 9, 38016083);
							c = gg(c, d, a, b, x[i + 15], 14, -660478335);
							b = gg(b, c, d, a, x[i + 4], 20, -405537848);
							a = gg(a, b, c, d, x[i + 9], 5, 568446438);
							d = gg(d, a, b, c, x[i + 14], 9, -1019803690);
							c = gg(c, d, a, b, x[i + 3], 14, -187363961);
							b = gg(b, c, d, a, x[i + 8], 20, 1163531501);
							a = gg(a, b, c, d, x[i + 13], 5, -1444681467);
							d = gg(d, a, b, c, x[i + 2], 9, -51403784);
							c = gg(c, d, a, b, x[i + 7], 14, 1735328473);
							b = gg(b, c, d, a, x[i + 12], 20, -1926607734);
							a = hh(a, b, c, d, x[i + 5], 4, -378558);
							d = hh(d, a, b, c, x[i + 8], 11, -2022574463);
							c = hh(c, d, a, b, x[i + 11], 16, 1839030562);
							b = hh(b, c, d, a, x[i + 14], 23, -35309556);
							a = hh(a, b, c, d, x[i + 1], 4, -1530992060);
							d = hh(d, a, b, c, x[i + 4], 11, 1272893353);
							c = hh(c, d, a, b, x[i + 7], 16, -155497632);
							b = hh(b, c, d, a, x[i + 10], 23, -1094730640);
							a = hh(a, b, c, d, x[i + 13], 4, 681279174);
							d = hh(d, a, b, c, x[i + 0], 11, -358537222);
							c = hh(c, d, a, b, x[i + 3], 16, -722521979);
							b = hh(b, c, d, a, x[i + 6], 23, 76029189);
							a = hh(a, b, c, d, x[i + 9], 4, -640364487);
							d = hh(d, a, b, c, x[i + 12], 11, -421815835);
							c = hh(c, d, a, b, x[i + 15], 16, 530742520);
							b = hh(b, c, d, a, x[i + 2], 23, -995338651);
							a = ii(a, b, c, d, x[i + 0], 6, -198630844);
							d = ii(d, a, b, c, x[i + 7], 10, 1126891415);
							c = ii(c, d, a, b, x[i + 14], 15, -1416354905);
							b = ii(b, c, d, a, x[i + 5], 21, -57434055);
							a = ii(a, b, c, d, x[i + 12], 6, 1700485571);
							d = ii(d, a, b, c, x[i + 3], 10, -1894986606);
							c = ii(c, d, a, b, x[i + 10], 15, -1051523);
							b = ii(b, c, d, a, x[i + 1], 21, -2054922799);
							a = ii(a, b, c, d, x[i + 8], 6, 1873313359);
							d = ii(d, a, b, c, x[i + 15], 10, -30611744);
							c = ii(c, d, a, b, x[i + 6], 15, -1560198380);
							b = ii(b, c, d, a, x[i + 13], 21, 1309151649);
							a = ii(a, b, c, d, x[i + 4], 6, -145523070);
							d = ii(d, a, b, c, x[i + 11], 10, -1120210379);
							c = ii(c, d, a, b, x[i + 2], 15, 718787259);
							b = ii(b, c, d, a, x[i + 9], 21, -343485551);
							a = safe_add(a, olda);
							b = safe_add(b, oldb);
							c = safe_add(c, oldc);
							d = safe_add(d, oldd);
					}
					return [a, b, c, d];
			}
			function binl2hex(binarray)
			{
					var hex_tab = "0123456789abcdef";
					var str = "";
					for (var i = 0; i < binarray.length * 4; i++)
					{
							str += hex_tab.charAt((binarray[i >> 2] >> ((i % 4) * 8 + 4)) & 0xF) + hex_tab.charAt((binarray[i >> 2] >> ((i % 4) * 8)) & 0xF);
					}
					return str;
			}
			function binl2b64(binarray)
			{
					var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
					var str = "";
					for (var i = 0; i < binarray.length * 32; i += 6)
					{
							str += tab.charAt(((binarray[i >> 5] << (i % 32)) & 0x3F) | ((binarray[i >> 5 + 1] >> (32 - i % 32)) & 0x3F));
					}
					return str;
			}
			function str2binl(str)
			{
					var nblk = ((str.length + 8) >> 6) + 1;
					var blks = new Array(nblk * 16);
					for (var i:Number = 0; i < nblk * 16; i++)
					{
							blks[i] = 0;
					}
					for (i = 0; i < str.length; i++)
					{
							blks[i >> 2] |= (str.charCodeAt(i) & 0xFF) << ((i % 4) * 8);
					}
					blks[i >> 2] |= 0x80 << ((i % 4) * 8);
					blks[nblk * 16 - 2] = str.length * 8;
					return blks;
			}
			function strw2binl(str)
			{
					var nblk = ((str.length + 4) >> 5) + 1;
					var blks = new Array(nblk * 16);
					for (var i:Number = 0; i < nblk * 16; i++)
					{
							blks[i] = 0;
					}
					for (i = 0; i < str.length; i++)
					{
							blks[i >> 1] |= str.charCodeAt(i) << ((i % 2) * 16);
					}
					blks[i >> 1] |= 0x80 << ((i % 2) * 16);
					blks[nblk * 16 - 2] = str.length * 16;
					return blks;
			}
			function hexMD5(str){ return binl2hex(coreMD5(str2binl(str)))};
			function hexMD5w(str){  return binl2hex(coreMD5(strw2binl(str)))};
			function b64MD5(str){ return binl2b64(coreMD5(str2binl(str)))};
			function b64MD5w(str){ return binl2b64(coreMD5(strw2binl(str)))};
			function calcMD5(str){ return binl2hex(coreMD5(str2binl(str)))};
			return calcMD5(str);
	}

	/**
	 * dec2bin      convert a decimal number into binary string
	 *
	 * @param       num     Number
	 * @return      String
	 */
	/*static function dec2bin(num:Number):String {
			var bin:Array = new Array();
			var result:Number = num;
			var rest:Number;
			do
			{
					rest = result%2;
					result = Math.floor(result/2);
					bin.push(rest);
			} while(result != 0);
			bin.reverse()
			return bin.join('');
	}

	/**
	 * string_repeat return a string with the char repeated n times
	 *
	 * @param       st      String
	 * @param       num     Number
	 * @return      String
	 */
	/*static function string_repeat(st:String, num:Number):String {
			var ret:String = '';
			for(var a = 0; a < num; a++){
					ret = ret + st;
			}
			return ret;
	}*/
	
	public static function create(total:int, str:String):String {
		var string:String = "";
		var i:int = total;
		while (--i >= 0) {
			string += str;
		}
		return string;
		
	}
	
	public static function parseBoolean(str:String, defaultIfNull:Boolean = false):Boolean {
		if (str == null || str == "") return defaultIfNull;
		var s:String = StringUtil.strip(str.toLowerCase());
		return s == "true" || parseInt(s) == 1;
	}
	
	public static function getRandomChar(s:String):String {
		return s.substr(Math.floor(Math.random()*s.length), 1);
	}
	
	public static function getCapitalLettersObject():Object {
		return {a:1, b:2, c:3, d:4, e:5, f:6, g:7, h:8, i:9, j:10, k:11, l:12, 
				m:13, n:14, o:15, p:16, q:17, r:18, s:19, t:20, u:21, v:22, w:23, x:24, y:25, z:26};
	}
	
	public static function getCapitalLetters():String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; }
	public static function getSmallLetters():String { return "abcdefghijklmnopqrstuvwxyz"; }
	public static function getVowels():String { return "aeiouwy"; }
	public static function getConsonants():String { return "bcdfghjklmnpqrstvxz"; }
	public static function getNumbers():String { return "0123456789"; }
	public static function getSymbols():String { return "`~!@#$%^&*()_+-=\|[]{};':\",./<>?"; }
	
	public static function getGreekCapitalLetters():String { return "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ"; }
	public static function getGreekSmallLetters():String { return "αβγδεζηθικλμνξοπρστυφχψω"; }
	public static function getGreekAccentedLetters():String { return "άέίύόήώΆΈΊΎΌΉΏϊϋΐΰ"; }
	
	public static function getIndices(str:String, sStr:String):Array {
		var arr:Array = [];
		var i:Number = -1;
		var l:Number = str.length;
		var sl:Number = sStr.length;
		while (++i < l) {
			if (str.substr(i, sl) == sStr) {
				arr.push(i);
			}
		}
		return arr;
	}
	
	public static function replaceAt(index:Number, str:String, rStr:String):String {
		return str.substring(0, index) + rStr + str.substr(index+1);
	}
	
	public static function isSymbol(s:String):Boolean {
		if (s.length > 1) s = s.charAt(0);
		var ascii:Number = s.charCodeAt(0);
		return (ascii >= 34 && ascii <= 47)
				|| (ascii >= 58 && ascii <= 64) 
				|| (ascii >= 34 && ascii <= 47)
				|| (ascii >= 91 && ascii <= 96)
				|| (ascii >= 123 && ascii <= 126)
				|| (ascii == 32);
	}
	
//	public static function pad(str:String, padString:String, totalCharacters:Number):String {
//		return string_repeat(padString, totalCharacters - str.length) + str;
//	}
	
	public static function reverse(str:String):String {
		var arr:Array = str.split("");
		arr.reverse();
		return arr.join("");
	}
	
	public static function stripNumbers(str:String):String {
		for (var i:Number=0; i<=9; i++) {
			str = str.split(String(i)).join("");
		}
		return str;
	}
	
//	public static function getRandomHash(length:Number):String {
//		return md5(String(getTimer())).substr(0, length).toUpperCase();
//	}
	
	public static function devulgarize(phrase:String):String {
		phrase = " " + phrase + " ";
		var vulgar:String;
		for (var i:String in profanityWords) {
			vulgar = " " + profanityWords[i] + " ";
			phrase = phrase.split(vulgar).join(" * ");
		}
		for (i in profanityRoots) {
			vulgar = profanityRoots[i];
			phrase = phrase.split(vulgar).join("*");
		}
		return phrase.substring(1, phrase.length - 1);
	}
	
	public static function stripLineFeed(str:String):String {
		return str.split("\n").join("").split("\r").join("");
	}
	
	public static function totalOccurencies(string:String, str:String):Number {
		return string.length - string.split(str).join("").length;
	}
	
	public static function getEllipsisString(str:String, maxLength:Number):String {
		return str.length <= maxLength ? str : str.substr(0, maxLength - 3) + "...";
	}
	
	public static function splitToStrings(str:String, delimiter:String = ","):Array {
		var arr:Array = str.split(delimiter);
		for (var i:String in arr)
			arr[i] = String(arr[i]);
		return arr;
	}
	
	public static function splitToNumbers(str:String, delimiter:String = ","):Array {
		var arr:Array = str.split(delimiter);
		for (var i:String in arr)
			arr[i] = Number(arr[i]);
		return arr;
	}
	
	public static function splitToInt(str:String, delimiter:String = ","):Array {
		var arr:Array = str.split(delimiter);
		for (var i:String in arr)
			arr[i] = int(arr[i]);
		return arr;
	}
	
	public static function splitToObject(str:String, delimiter1:String = ",", delimiter2:String = ":"):Object {
		if (str == null) return null;
		var arr:Array = str.split(delimiter1);
		var arr1:Array;
		var obj:Object = {};
		
		for (var i:String in arr) {
			arr1 = String(arr[i]).split(delimiter2);
			obj[arr1[0]] = arr1[1];
		}
		return obj;
	}
	
	public static function splitToArray2D(str:String, delimiter1:String = ",", delimiter2:String = ":"):Array {
		if (str == null) return null;
		var farr:Array = [];
		var arr:Array = str.split(delimiter1);		
		for (var i:String in arr) {
			var arr1:Array = String(arr[i]).split(delimiter2);
			farr.push(arr1);
		}
		return farr;
	}
	public static function isEmpty(s:String):Boolean {
		return s == null || StringUtil.strip(s) == "";
	}
	
	public static function nullSafeParse(s:String):String {
		return StringUtil.isEmpty(s) ? "" : s;
	}
	
	public static function generateRandomString(newLength:uint = 1, userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String{
	    var alphabet:Array = userAlphabet.split("");
	    var alphabetLength:int = alphabet.length;
	    var randomLetters:String = "";
	    for (var i:uint = 0; i < newLength; i++){
	    	randomLetters += alphabet[int(Math.floor(Math.random() * alphabetLength))];
	    }
	    return randomLetters;
    }
	
	public static function rectangleToString(rect:Rectangle):String {
		return (rect.x + "," + rect.y + "," + rect.width + "," + rect.height);
	}
	
	public static function stringToRectangle(str:String):Rectangle {
		var arr:Array = StringUtil.splitToInt(str);
		return new Rectangle(arr[0], arr[1], arr[2], arr[3]);
	}
	
}

}