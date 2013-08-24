package
{
	import org.flixel.*;
	
	public class ScreenState extends FlxState
	{
		
		public function ScreenState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			FlxG.flash(0xff000000, 0.5);
		}
		
		override public function update():void
		{	
			super.update();
		}
		
		public function onButtonMenu():void
		{
			fadeToMenu();
		}
		
		public function fadeToMenu(Timer:FlxTimer = null):void
		{
			FlxG.fade(0xff000000, 0.5, goToMenu);
		}
		
		public function goToGame():void
		{
			FlxG.switchState(new GameScreen);
		}
		
		public function onButtonGame():void
		{
			fadeToGame();
		}
		
		public function fadeToGame(Timer:FlxTimer = null):void
		{
			FlxG.fade(0xff000000, 0.5, goToGame);
		}
		
		public function goToMenu():void
		{
			FlxG.switchState(new MenuScreen);
		}
		
		public static function playRandomSound(Sounds:Array, Volume:Number = 1.0):void
		{
			FlxG.play(Sounds[Math.floor(Sounds.length * Math.random())], Volume, false, false);
		}

	}
}