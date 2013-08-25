package
{
	import org.flixel.*;
	
	public class ScreenState extends FlxState
	{
		[Embed(source="../assets/images/Sprites.png")] protected static var imgSprites:Class;

		public var information:FlxText;
		public var overlay:FlxSprite;
		
		public function ScreenState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			FlxG.flash(0xff000000, 0.5);
			
			information = new FlxText(0, 0, FlxG.width, "blah");
			information.setFormat(null, 16, 0xff0000, "left");
			information.scrollFactor.x = information.scrollFactor.y = 0;
			
			overlay = new FlxSprite(32, FlxG.height - 160);
			overlay.scale.x = overlay.scale.y = 1.5;
			overlay.scrollFactor.x = overlay.scrollFactor.y = 0;
			overlay.alpha = 0.35;
			overlay.loadGraphic(imgSprites, true, false, 128, 128);
			overlay.addAnimation("idle",[0]);
			overlay.addAnimation("countdown", [30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 20], 1, false);
			overlay.play("countdown");
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