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
			UserSettings.load();
			
			primaryButton = new FlxButton(0.5 * FlxG.width - 80, 0.5 * FlxG.height - 48, "Play", onButtonGame);
			primaryButton.scale.x = primaryButton.scale.y = 2;
			primaryButton.width *= 2;
			primaryButton.height *= 2;
			primaryButton.centerOffsets();
			primaryButton.label.width = primaryButton.width;
			primaryButton.label.size = 16;
			primaryButton.label.offset.y = -6;
			add(primaryButton);
			
			secondaryButton = new FlxButton(0.5 * FlxG.width - 80, 0.5 * FlxG.height - 0, "Config", onButtonSettings);
			secondaryButton.scale.x = secondaryButton.scale.y = 2;
			secondaryButton.width *= 2;
			secondaryButton.height *= 2;
			secondaryButton.centerOffsets();
			secondaryButton.label.width = secondaryButton.width;
			secondaryButton.label.size = 16;
			secondaryButton.label.offset.y = -6;
			add(secondaryButton);

			//information.text = "Click on the screen to start playing.";
			//add(information);
		}
		
		override public function update():void
		{	
			super.update();
			//if (FlxG.mouse.justPressed()) goToGame();
		}

	}
}