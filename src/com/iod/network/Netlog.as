package com.iod.network
{
	public class Netlog
	{
		public static var max_log_count : Number = 999999;

		private static var logs:Array = new Array();
		
		public static function log(info:String) : void
		{			
			logs.push(info);
			if (logs.length > max_log_count) {
				logs.shift();
			}
		}
		
		public static function fetch() : String 
		{
			return logs.shift() as String;
		}
		
		public static function fetchAll() : Array
		{
			var out:Array = logs;
			logs = new Array;
			return out;
		}
	}
}