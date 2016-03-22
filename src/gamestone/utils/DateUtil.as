package gamestone.utils {

	public class DateUtil {
		
		
		// Used to calculate weekday
		private static var months:Array = [0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5];
		private static var leapMonths:Array = [6, 2];
		private static var centuryOffsetYear:int = 2000;
		private static var centuryOffset:Array = [0, 6];
		private static var weekdays:Array = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		
		
		public static function aroundDate(date:Date, leftLimit:Number, rightLimit:Number):Boolean {
			var d1:Date = new Date(date.getTime() - leftLimit);
			var d2:Date = new Date(date.getTime() + rightLimit);
			var now:Date = new Date();
			
			//trace(">"+now);
			//trace(d1);
			//trace(d2);
			return d1 <= now && now <= d2;
		}
		
		public static function aroundDateInDays(date:Date, leftLimit:Number, rightLimit:Number):Boolean {
			// leftLimit and rightLimit in days
			var m:Number = 24*60*60*1000;
			//date = new Date(date.getTime()
			return aroundDate(date, m*leftLimit, m*rightLimit);
		}
		
	
		// Examples of a format string: "mm:ss" "m:ss" "m:s" "hh.mm.ss"
		public static function getFormattedTime(seconds:int, formatString:String = "MM:SS"):String {
			var showHours:Boolean = formatString.indexOf("H") >= 0;
			var showMinutes:Boolean = formatString.indexOf("M") >= 0;
			var showSeconds:Boolean = formatString.indexOf("S") >= 0;
			
			var minutes:int = seconds/60;
			if (showMinutes)
				seconds -= minutes*60;
			var hours:int = minutes/60;
			if (showHours) {
				if (showMinutes)
					minutes -= hours*60;
				else
					seconds -= hours*60*60;
			}
			
			var str_minutes:String = String(minutes);
			var str_seconds:String = String(seconds);
			var str_hours:String = String(hours);
			
			var min_2_digits:Boolean = false;
			var sec_2_digits:Boolean = false;
			var hour_2_digits:Boolean = false;
			
			if (formatString.indexOf("HH") >= 0) {
				if (hours < 10) str_hours = "0" + str_hours;
				hour_2_digits = true;
			}
			if (formatString.indexOf("MM") >= 0) {
				if (minutes < 10) str_minutes = "0" + str_minutes;
				min_2_digits = true;
			}
			if (formatString.indexOf("SS") >= 0) {
				if (seconds < 10) str_seconds = "0" + str_seconds;
				sec_2_digits = true;
			}
			
			
			var timeStr:String = formatString;
			
			if (hour_2_digits) {
				timeStr = timeStr.split("HH").join(str_hours);
			} else {
				timeStr = timeStr.split("H").join(str_hours);
			}
			if (min_2_digits) {
				timeStr = timeStr.split("MM").join(str_minutes);
			} else {
				timeStr = timeStr.split("M").join(str_minutes);
			}
			if (sec_2_digits) {
				timeStr = timeStr.split("SS").join(str_seconds);
			} else {
				timeStr = timeStr.split("S").join(str_seconds);
			}
		
			return timeStr;
		}
			
		
		public static function getWeekDay(day:Number, month:Number, year:Number):Number {
			// Will find the weekday for every date between 1900 and 2099
			var a1:Number = year < centuryOffsetYear ? centuryOffset[0] : centuryOffset[1];
			var a2:Number = Number(String(year).substr(-2, 2));
			var a3:Number = Math.floor(a2/4);
			var a4:Number = (isLeapYear(year) && month <= 2)? leapMonths[month - 1] : months[month - 1];
			var sum:Number = a1 + a2 + a3 + a4 + day;
			var index:Number = sum % 7;
			return index;
		}
		
		public static function getWeekDayName(index:int):String {
			return weekdays[index];
		}
		
		public static function isLeapYear(year:int):Boolean {
			return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
		} 
		
	}
	
}