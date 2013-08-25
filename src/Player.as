package
{
	import flash.display.Graphics;
	
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		public static const CORRECT:uint = 0;
		public static const WRONG_WAY:uint = 1;
		public static const UPSIDE_DOWN:uint = 2;
		public static const UPSIDE_DOWN_AND_WRONG_WAY:uint = 3;
		
		public static const TOKEN:uint = 0;
		public static const ONE_DOLLAR_BILL:uint = 1;
		public static const FIVE_DOLLAR_BILL:uint = 2;
		public static const TEN_DOLLAR_BILL:uint = 3;
		
		private static var kUp:String = "W";
		private static var kDown:String = "S";
		private static var kLeft:String = "A";
		private static var kRight:String = "D";
		private static var kJump:String = "SPACE";
		
		protected var _dir:FlxPoint; // initial direction vector
		protected var _view:FlxPoint; //the 2d raycaster version of camera plane
		protected var _pos:FlxPoint;
		protected var _rayDir:FlxPoint;
		
		//speed modifiers
		public var moveSpeed:Number = 5.0 * 128; //the constant value is in tiles/second
		public var rotSpeed:Number = 3.0; //the constant value is in radians/second
		public var speedMultiplier:Number = 1.0;
		protected var _fov:Number;
		
		public var magDir:Number = 0;
		public var magView:Number = 0;
		public var angView:Number = 0;
		public var viewOffset:Number = 0;
		
		public var inventory:Array = [ONE_DOLLAR_BILL, ONE_DOLLAR_BILL, ONE_DOLLAR_BILL, FIVE_DOLLAR_BILL, TEN_DOLLAR_BILL];
		
		public var itemFacing:uint = CORRECT;
		public var currentItem:uint = 0;
		
		public function Player(X:Number = 3, Y:Number = 2)
		{
			super(X, Y);
			
			width = 64;
			height = 64;
			solid = true;

			x = X * 128 - width / 2;
			y = Y * 128 - height / 2;
			velocity.x = moveSpeed;
			drag.x = drag.y = 8 * moveSpeed;
			angle = 90;
			_dir = new FlxPoint(1, 0); // initial direction vector
			magDir = Math.sqrt(_dir.x * _dir.x + _dir.y * _dir.y);
			_view = new FlxPoint(0, 1); //the 2d raycaster version of camera plane
			fov = 66 * (Math.PI / 180);
			_pos = new FlxPoint();
			_rayDir = new FlxPoint();
			
			inventory.sort(randomSort);
			inventory.unshift(ONE_DOLLAR_BILL);
		}
		
		private function randomSort(a:*, b:*):Number
		{
			if (FlxG.random() < 0.5) return -1;
			else return 1;
		}
		
		override public function draw():void
		{
			if (FlxG.visualDebug) super.draw();
		}
		
		override public function update():void
		{
			super.update();
			if (FlxG.keys["SHIFT"]) speedMultiplier = 0.2;
			else speedMultiplier = 1;
			
			//velocity.x = velocity.y = 0;
			
			if (FlxG.keys["W"])
			{ //move forward
				velocity.x = dir.x * moveSpeed * speedMultiplier;
				velocity.y = dir.y * moveSpeed * speedMultiplier;
			}
			else if (FlxG.keys["S"])
			{ //move backwards
				velocity.x = dir.x * -moveSpeed * speedMultiplier;
				velocity.y = dir.y * -moveSpeed * speedMultiplier;
			}
			
			//eventually, will have to calculate this differently to prevent speed increases
			if (FlxG.keys["Q"])
			{ //strafe left
				velocity.x += view.x * -moveSpeed * speedMultiplier;
				velocity.y += view.y * -moveSpeed * speedMultiplier;
			}
			else if (FlxG.keys["E"])
			{ //strafe right
				velocity.x += view.x * moveSpeed * speedMultiplier;
				velocity.y += view.y * moveSpeed * speedMultiplier;
			}
			
			var _speedThrottle:Number = Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y) / moveSpeed / speedMultiplier;
			if (_speedThrottle > 1) 
			{
				velocity.x /= _speedThrottle;
				velocity.y /= _speedThrottle;
			}
			
			if (angle < 0) angle += 360;
			
			if (FlxG.keys["A"]) //rotate to the right
			{ //both camera direction and camera plane must be rotated
				angularVelocity = rotSpeed * speedMultiplier * (180 / Math.PI);
			}
			else if (FlxG.keys["D"]) //rotate to the left
			{ //both camera direction and camera plane must be rotated
				angularVelocity = -rotSpeed * speedMultiplier * (180 / Math.PI);
			}
			else angularVelocity = 0;
			
			if (FlxG.keys.justPressed("J")) nextItem();
			else if (FlxG.keys.justPressed("K")) flipItem();
		}
		
		private function nextItem():void
		{
			currentItem += 1;
			if (currentItem >= inventory.length) 
			{
				inventory.sort(randomSort);
				currentItem = 0;
			}
			if (FlxG.random() < 0.5) itemFacing = CORRECT;
			else itemFacing = UPSIDE_DOWN;
		}
		
		private function flipItem():void
		{
			if (itemFacing == CORRECT) itemFacing = UPSIDE_DOWN;
			else itemFacing = CORRECT;
		}
		
		public function useItem():void
		{
			if (itemFacing == CORRECT && inventory[currentItem] != TEN_DOLLAR_BILL)
			{
				FlxG.log("CORRECT");
			}
			else
			{
				FlxG.log("INCORRECT");
			}
		}
		
		public function light(LightLevel:uint):void
		{			
			var _light:Number = LightLevel;
			if (_light < 2) _light = 2;
			else if (_light > 10) _light = 10;
			_light /= 10;
			var _red:uint;
			var _green:uint;
			var _blue:uint;
			
			_red = 255 * _light;
			_green = 255 * _light;
			_blue = 255 * _light;
			color = (_red << 16) + (_green << 8) + _blue;
		}
		
		public function get rayDir():FlxPoint
		{
			return _rayDir;
		}
		
		public function setRayDir(CameraX:Number):void
		{
			_rayDir.x = magDir * dir.x + magView * view.x * CameraX;
			_rayDir.y = magDir * dir.y + magView * view.y * CameraX;
		}
		
		public function get fov():Number
		{
			return _fov;
		}
		
		public function set fov(Value:Number):void
		{
			_fov = Value;
			angView = _fov / 2;
			magView = Math.sin(angView) * (magDir / Math.cos(angView));
		}
		
		public function get viewAngle():Number
		{
			var _viewAngle:Number = Math.abs(angle + 360) % 360;
			return _viewAngle;
		}
		
		public function get dir():FlxPoint
		{
			var _angle:Number = Math.abs(angle + 360) % 360;
			_angle = _angle * Math.PI / 180; //convert to radians
			
			_dir.x = Math.cos(_angle);
			_dir.y = Math.sin(_angle);
			return _dir;
		}
		
		public function get view():FlxPoint
		{
			var _angle:Number = Math.abs(angle + 270) % 360;
			_angle = _angle * Math.PI / 180; //convert to radians
			
			_view.x = Math.cos(_angle);
			_view.y = Math.sin(_angle);
			return _view;
		}
		
		public function get pos():FlxPoint
		{
			_pos.x = x + width / 2;
			_pos.y = y + height / 2;
			return _pos;
		}
	}
}