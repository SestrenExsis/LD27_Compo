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
		public var itemSwapOffset:Number = 0;
		public var itemSwapDelta:int = 0;
		public var swapItemBuffer:Boolean = false;
		public var flipItemBuffer:Boolean = false;
		public var removeItemBuffer:Boolean = false;
		public var timer:FlxTimer;
		
		public var inventory:Array = [ONE_DOLLAR_BILL, ONE_DOLLAR_BILL, ONE_DOLLAR_BILL, ONE_DOLLAR_BILL, ONE_DOLLAR_BILL, TEN_DOLLAR_BILL];
		
		public var itemFacing:uint = CORRECT;
		public var currentItem:uint = 0;
		public var staleMessage:Boolean = false;
		public var tokens:uint = 0;
		public var playingGame:Boolean = false;
		public var continueTimer:FlxTimer;
		
		//public var nextObjective:Entity;
		public var target:Entity;
		public var currentObjective:int = 0;
		public var info:String = "W/A/S/D to move, Q/E to strafe, J/K to change bills. SHIFT to run.";
		
		public function Player(X:Number = 3.5, Y:Number = 2)
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
			timer = new FlxTimer();
			timer.start(0.001);
			continueTimer = new FlxTimer();
			
			inventory.sort(randomSort);
			inventory.unshift(ONE_DOLLAR_BILL);
			itemFacing = UPSIDE_DOWN;
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
			
			if (playingGame) return;
			
			if (FlxG.keys["SHIFT"]) speedMultiplier = 1.5;
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
		
		private function onTimerSwapOut(Timer:FlxTimer):void
		{
			timer.stop();
			timer.start(0.3, 1, onTimerSwapIn);
			itemSwapDelta = -16;
		}
		
		private function onTimerSwapIn(Timer:FlxTimer):void
		{
			timer.stop();
			timer.start(0.3, 1, onTimerSwapDone);
			itemSwapDelta = 16;
			
			if (swapItemBuffer) 
			{
				currentItem += 1;
				if (currentItem >= inventory.length) 
				{
					currentItem = 0;
				}
				if (FlxG.random() < 0.5) itemFacing = CORRECT;
				else itemFacing = UPSIDE_DOWN;
			}
			else if (flipItemBuffer)
			{
				if (itemFacing == CORRECT) itemFacing = UPSIDE_DOWN;
				else itemFacing = CORRECT;
			}
			else if (removeItemBuffer)
			{
				var _item:uint = removeItemFromInventory(currentItem);
				inventory.sort(randomSort);
				currentItem = 0;
				if (FlxG.random() < 0.5) itemFacing = CORRECT;
				else itemFacing = UPSIDE_DOWN;
				if (target)
				{
					if (_item == Entity.FIVE_DOLLAR_BILL) target.tokens += 20;
					else target.tokens += 4;
				}
			}
			swapItemBuffer = flipItemBuffer = removeItemBuffer = false;
		}
		
		private function onTimerSwapDone(Timer:FlxTimer):void
		{
			timer.stop();
			itemSwapDelta = 0;
			itemSwapOffset = 0;
			staleMessage = false;
		}
		
		private function nextItem():void
		{
			if (flipItemBuffer || removeItemBuffer || tokens > 0) return; //Don't skip to the next one
			if (itemSwapDelta == 0)
			{
				swapItemBuffer = true;
				onTimerSwapOut(timer);
			}
			else if (itemSwapDelta > 0 && timer.progress >= 0.3)
			{
				swapItemBuffer = true;
				var _timeLeft:Number = timer.timeLeft;
				onTimerSwapOut(timer);
				timer.stop();
				timer.start(0.3 - _timeLeft, 1, onTimerSwapIn);
			}
			else
			{
				//nothing changes, still waiting for the next item to come up.
			}
		}
		
		private function flipItem():void
		{
			//if (itemFacing == CORRECT) itemFacing = UPSIDE_DOWN;
			//else itemFacing = CORRECT;
			
			if (swapItemBuffer || removeItemBuffer || tokens > 0) return; //Don't bother flipping
			if (itemSwapDelta == 0)
			{
				flipItemBuffer = true;
				onTimerSwapOut(timer);
			}
			else if (itemSwapDelta > 0 && timer.progress >= 0.3)
			{
				flipItemBuffer = true;
				var _timeLeft:Number = timer.timeLeft;
				onTimerSwapOut(timer);
				timer.stop();
				timer.start(0.3 - _timeLeft, 1, onTimerSwapIn);
			}
			else
			{
				//nothing changes, still waiting for the next item to come up.
			}
		}
		
		public function useItem(Ent:Entity, Target:Entity = null):Boolean
		{
			if (!timer.finished) return false;
			
			if (Ent.type == Entity.OBJECTIVE_MAKE_CHANGE)
			{
				if (target)
				{
					info = "You've already paid for tokens. Check the coin deposit slot.";
					//staleMessage = true;
				}
				else if (tokens > 0)
				{
					info = "You already have tokens. Go find the game you want to beat!";
					//staleMessage = true;
				}
				else if (itemFacing == CORRECT && inventory[currentItem] != TEN_DOLLAR_BILL)
				{
					removeItemBuffer = true;
					onTimerSwapOut(timer);
					target = Target;
					staleMessage = false;
					return true;
				}
				else if (!staleMessage)
				{
					if (inventory[currentItem] == TEN_DOLLAR_BILL)
					{
						info = "This machine does not accept $10 bills. Press 'J' to swap it.";
						//staleMessage = true;
					}
					else if (itemFacing != CORRECT)
					{
						info = "The bill is not facing the correct way. Press 'K' to flip it.";
						//staleMessage = true;
					}
				}
			}
			else if (Ent.type == Entity.OBJECTIVE_GET_CHANGE)
			{
				if (target)
				{
					if (target.tokens > 0)
					{
						tokens += target.tokens;
						target.tokens = 0;
						target = null;
						return true;
					}
					else if (!staleMessage)
					{
						info = "The coin deposit slot is empty.";
						//staleMessage = true;
					}
				}
				else if (tokens == 0)
				{
					info = "You haven't inserted any bills into the machine yet.";
					//staleMessage = true;
				}
			}
			else if (Ent.type == Entity.OBJECTIVE_START_GAME)
			{
				if (target)
				{
					info = "You forgot your tokens back at the token machine!";
					//staleMessage = true;
				}
				else
				{
					if (Ent.visible)
					{
						if (tokens > 0)
						{
							tokens = 0;
							playGame();
							return true;
						}
						else if (timer.finished)
						{
							info = "You are out of tokens! Hurry to the nearest token machine!";
						}
					}
					else
					{
						//info = "This is not the game you feel like playing right now.";
					}
				}
				
			}
			
			return false;
		}
		
		public function playGame():void
		{
			playingGame = true;
			velocity.x = velocity.y = angularVelocity = 0;
			FlxG.fade(0xff000000, 0.75, onTimerPlaying, true);
		}
		
		public function onTimerPlaying():void
		{
			//FlxG.
			FlxG.camera.stopFX();
			FlxG.flash(0xff000000, 0.75, onTimerDonePlaying, true);
		}
		
		public function onTimerDonePlaying():void
		{
			playingGame = false;
			continueTimer.stop();
			continueTimer.start(10, 1, onTimerGameOver);
		}
		
		public function onTimerGameOver(Timer:FlxTimer):void
		{
			
		}
		
		public function winGame():void
		{
			
		}
		
		public function removeItemFromInventory(Index:uint):uint
		{
			var _itemType:uint = inventory[Index];
			if (Index == inventory.length - 1)  inventory.pop();
			else if (Index == 0) inventory.shift();
			else
			{
				for (var i:uint = Index; i < inventory.length - 1; i++)
				{
					inventory[i] = inventory[i + 1];
				}
				inventory.pop();
			}
			return _itemType;
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