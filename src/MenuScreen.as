package
{
	import org.flixel.*;
	
	public class MenuScreen extends ScreenState
	{
		public function MenuScreen()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			information.text = "Click on the screen to start playing.";
			
			add(information);
		}
		
		override public function update():void
		{	
			super.update();
			if (FlxG.mouse.justPressed()) goToGame();
		}

	}
}