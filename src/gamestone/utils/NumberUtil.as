package gamestone.utils {

public class NumberUtil {
	
	public static function randomInt(min:int, max:int, randomSign:Boolean = false, signOdds:Number = 1):Number {
		// Usage #1
		// randomInt(10) -> returns a number between 0 and 10
		/*if (isNaN(max)) {
			max = min;
			min = 0;
		}*/
		
		// Usage #2
		// randomInt(2, 10) -> returns a number between 2 and 10
		if (min == max) return min;
		var sign:Number = randomSign ? NumberUtil.randomSign(signOdds) : 1;
		return sign*Math.round(Math.random()*(max - min) + min);
	}
	
	public static function getNumbersInsideLimits(min:int, max:int):Array {
		var arr:Array = [];
		var i:int;
		for (i = min; i <= max; i++)
			arr.push(i);
		return arr;
	}
	
	public static function random(min:Number, max:Number):Number {
		return Math.random()*(max - min) + min;
	}
	
	
	public static function randomDecision(n:Number = 0.5):Boolean {
		if (n < 0)
			n = 0;
		else if (n > 1)
			n = 1;
		
		var rnd:Number = Math.random();
		return rnd <= n;
	}
	
	/*public static function getDependentValue(indValue:Number,
											 indMin:Number,
											 indMax:Number,
											 depMin:Number,
											 depMax:Number,
											 easingStr:String = "Linear.easeNone"):Number {
		// y = F(x)
		// y is the dependent variable
		// x is the independent variable
		//
		// indValue is the current value of the independent variable
		
		//if (easingStr == undefined)
		//	easingStr = "Linear.easeNone";
		
		var easing:Function = new EaseFunctions().getEasingFunction(easingStr);
		
		return easing(indValue - indMin, depMin, depMax - depMin, indMax - indMin);
	} */
	
	public static function roundTo(num:Number, digits:Number):Number {
		if (digits <= 0)
			return Math.round(num);
		//round the number to specified decimal places
		//e.g. 12.3456 to 3 digits (12.346) -> mult. by 1000, round, div. by 1000
		var tenToPower:Number = Math.pow(10, digits);
		return Math.round(num * tenToPower) / tenToPower;
	}
	
	public static function roundToDp(num:Number,digits:Number):* {
		if (digits <= 0)
			return Math.round(num);
		//round the number to specified decimal places
		//e.g. 12.3456 to 3 digits (12.346) -> mult. by 1000, round, div. by 1000
		var tenToPower:Number = Math.pow(10, digits);
		var cropped:String = String(Math.round(num * tenToPower) / tenToPower);
		//add decimal point if missing
		if (cropped.indexOf(".") == -1)
			cropped += ".0";  //e.g. 5 -> 5.0 (at least one zero is needed)
		
		//finally, force correct number of zeros; add some if  necessary
		var halves:Array = cropped.split("."); //grab numbers to the right of the decimal
		//compare digits in right half of string to digits wanted
		var zerosNeeded:Number = digits - halves[1].length; //number of zeros to add
		for (var i:Number=1; i <= zerosNeeded; i++)
			cropped += "0";
		
		return(cropped);
	}
	
	public static function randomSign(odds:Number = .5):Number {
		return NumberUtil.randomDecision(odds) ? 1 : -1;
	}
	
	public static function getSign(n:Number):Number {
		return (n >= 0) ? 1 : -1;
	}
	
	public static function isEven(n:Number):Boolean {
		return (n & 1) == 0;
	}
	
	public static function isOdd(n:Number):Boolean {
		return (n & 1) == 1;
	}
	
	public static function isAroundValue(n2:Number, n1:Number, deviationPercentage:Number):Boolean {
		// e.g. isAroundValue(90, 100, .15) = true
		// 85 <= 90 <= 115
		
		// e.g. isAroundValue(30, 100, .5) = false
		// 50 <= 30 <= 150 (?) NO!
		
		var p:Number = deviationPercentage;
		return (n1*(1-p) <= n2 && n2 <= n1*(1 + p));
	}
	
	public static function getApproximateValue(value:Number, deviationPercentage:Number):Number {
		return NumberUtil.random(value*(1 - deviationPercentage), value*(1 + deviationPercentage));
	}
}
}