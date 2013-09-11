package
{
	import org.flixel.*;
	
	public class ScreenState extends FlxState
	{
		[Embed(source="../assets/images/Sprites.png")] protected static var imgSprites:Class;

		public var buttons:Array;
		public var primaryButton:FlxButton;
		public var secondaryButton:FlxButton;
		public var information:FlxText;
		public var information2:FlxText;
		public var overlay:FlxSprite;
		public var timer:FlxTimer;
		
		public function ScreenState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			FlxG.flash(0xff000000, 0.5);
			
			information = new FlxText(0, 0, FlxG.width, "");
			information.setFormat(null, 16, 0xff0000, "left");
			information.scrollFactor.x = information.scrollFactor.y = 0;
			
			information2 = new FlxText(0, 20, FlxG.width, "");
			information2.setFormat(null, 16, 0x00ff00, "left");
			information2.scrollFactor.x = information2.scrollFactor.y = 0;
			
			overlay = new FlxSprite(32, FlxG.height - 160);
			overlay.scale.x = overlay.scale.y = 1.5;
			overlay.scrollFactor.x = overlay.scrollFactor.y = 0;
			overlay.alpha = 0.35;
			overlay.loadGraphic(imgSprites, true, false, 128, 128);
			overlay.addAnimation("idle",[0]);
			overlay.addAnimation("win",[16]);
			overlay.addAnimation("hurry", [20, 20, 21, 21, 22, 22, 23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 10], 2, false);
			overlay.addAnimation("countdown", [30, 30, 31, 31, 32, 32, 33, 33, 34, 34, 35, 35, 36, 36, 37, 37, 38, 38, 39, 39, 10], 2, false);
			overlay.play("idle");
			
			timer = new FlxTimer();
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
		
		public function goToMenu():void
		{
			FlxG.switchState(new MenuScreen);
		}
		
		public function onButtonGame():void
		{
			fadeToGame();
		}
		
		public function fadeToGame(Timer:FlxTimer = null):void
		{
			FlxG.fade(0xff000000, 0.5, goToGame);
		}
		
		public function goToGame():void
		{
			FlxG.switchState(new GameScreen);
		}
		
		public function onButtonSettings():void
		{
			fadeToSettings();
		}
		
		public function fadeToSettings(Timer:FlxTimer = null):void
		{
			FlxG.fade(0xff000000, 0.5, goToSettings);
		}
		
		public function goToSettings():void
		{
			FlxG.switchState(new SettingsScreen);
		}
		
		public static function playRandomSound(Sounds:Array, Volume:Number = 1.0):void
		{
			FlxG.play(Sounds[Math.floor(Sounds.length * Math.random())], Volume, false, false);
		}

	}
}