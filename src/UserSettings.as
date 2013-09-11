package
{
	import org.flixel.*;
	
	public class UserSettings
	{
		private static var _save:FlxSave;
		private static var _tempKeymap:Array;
		private static var _loaded:Boolean = false;
		//private static var _highScore:uint = 0;
		//private static var _tempHighScore:uint;
		
		public static function get keymap():Array
		{
			if (_loaded) return _save.data.keymap;
			else return _tempKeymap;
		}
		
		public static function set keymap(Value:Array):void
		{
			if (_loaded) _save.data.keymap = Value;
			else _tempKeymap = Value;
		}
		
		/*public static function get highScore():int
		{
			if (_loaded) return _save.data.highScore;
			else return _highScore;
		}
		
		public static function set highScore(value:int):void
		{
			if (_loaded) _save.data.highScore = value;
			else _tempHighScore = value;
		}*/

		public static function load():void
		{
			_save = new FlxSave();
			_loaded = _save.bind("LD27CompoSettings");
			
			if (_loaded)
			{
				if (_save.data.keymap == null) 
				{
					_save.data.keymap = new Array("W","S","A","D","Q","E","J","K","SHIFT");
					FlxG.log("loading default key config ...");
				}
				else 
				{
					FlxG.log("loading previous key config ...");
					Player.keymap = UserSettings.keymap.slice();
				}
			}
			else FlxG.log("failed to load");
		}
		
		public static function save():void
		{
			_save.flush();
		}
	}
}