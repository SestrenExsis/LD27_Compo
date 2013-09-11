package
{
	//import flash.display.Stage;
	
	import org.flixel.*;
	import org.flixel.system.input.Input;
	
	public class SettingsScreen extends ScreenState
	{
		private var listenForKey:Boolean = false;
		private var _select:int = -1;
		private var textboxes:Array;

		
		public function SettingsScreen()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			FlxG.bgColor = 0xff888899;

			buttons = new Array(9);
			textboxes = new Array(9);
			var _offsetX:Number = 0;
			var _offsetY:Number = 0;
			for (var i:uint = 0; i < buttons.length; i++)
			{
				textboxes[i] = new FlxText(FlxG.width / 2 - 200 - 2, 85 + 24 * i, 200, Player.actions[i]);
				(textboxes[i] as FlxText).alignment = "right";
				(textboxes[i] as FlxText).ID = i;
				add(textboxes[i]);
				
				buttons[i] = new FlxButton(_offsetX + FlxG.width / 2 + 2, _offsetY + 80 + 24 * i, Player.keymap[i], remapKey);
				(buttons[i] as FlxButton).ID = i;
				add(buttons[i]);
			}
			
			information.x = 0;//new FlxText(0, FlxG.height - 24, FlxG.width, "Press ESC to return to main menu.");
			information.y = FlxG.height - 24;
			information.color = 0x000000;
			information.text = "Press ESC to return to main menu.";
			information.alignment = "center";
			add(information);
			
			primaryButton = new FlxButton(FlxG.width / 2 - 102, FlxG.height - 48, "Save", saveSettings);
			add(primaryButton);
			
			secondaryButton = new FlxButton(FlxG.width / 2 + 2, FlxG.height - 48, "Default", defaultSettings);
			add(secondaryButton);
		}
		
		override public function destroy():void
		{
			//sfxLogo.destroy();
			super.destroy();
		}
		
		override public function update():void
		{	
			super.update();
			
			if (FlxG.keys["ESCAPE"]) fadeToMenu();
			
			if (FlxG.keys.any() && listenForKey)
			{
				listenForKey = false;
				var _record:Array = FlxG.keys.record();
				var _key:int = _record[0].code;
				var _keyname:String = FlxG.keys.getKeyName(_record[0].code);
				//remapKeyDisplay.text = _keyname;
				if (_select >= 0) 
				{
					var _btn:FlxButton = buttons[_select];
					_btn.active = true;
					_btn.status = FlxButton.NORMAL;
					_btn.label.text = _keyname;
					information.text = Player.actions[_select] + " is now mapped to '" + _keyname + "'";
					Player.keymap[_select] = _keyname;
				}
			}
			//else if (!FlxG.keys.any()) FlxG.keys.reset();
		}
		
		public function remapKey():void
		{
			information.text = "<Press any key>";
			for (var i:uint = 0; i < buttons.length; i++)
			{
				var _btn:FlxButton = buttons[i];
				if (_btn.status != FlxButton.NORMAL) _select = _btn.ID;
			}
			listenForKey = true;
			_btn = buttons[_select];
			_btn.label.text = "...";
			_btn.status = FlxButton.PRESSED;
			_btn.active = false;
		}
		
		public function saveSettings():void
		{
			UserSettings.keymap = Player.keymap.slice();
			information.text = "Settings have been saved.";
		}
		
		public function defaultSettings():void
		{
			UserSettings.keymap = ["W","S","A","D","Q","E","J","K","SHIFT"];
			Player.keymap = ["W","S","A","D","Q","E","J","K","SHIFT"];
			information.text = "Default settings have been restored.";
			
			for (var i:uint = 0; i < buttons.length; i++)
			{
				var _btn:FlxButton = buttons[i];
				_btn.label.text = Player.keymap[i];
			}
		}
	}
}