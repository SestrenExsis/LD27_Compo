package
{
	import flash.display.Graphics;
	
	import org.flixel.*;
	
	public class PlayerPOV extends FlxSprite
	{
		[Embed(source="../assets/images/Sprites.png")] protected static var imgPOV:Class;
		
		public static const animationNames:Array = ["token", "one_front", "five_front", "ten_front",
			"quarter", "one_back", "five_back", "ten_back"];
		
		public var swayRadius:Number = 64;
		public var maxSwayAngle:Number = 60;
		public var swayPosition:Number = 0;
		public var swayAngle:Number = 0;
		public var swayDelta:Number = 2000;
		private var target:Player;
		
		public function PlayerPOV(Target:Player)
		{
			super(0, 0);
			target = Target;
			
			loadGraphic(imgPOV, true, true, 128, 128);
			addAnimation("one_front",[1]);
			addAnimation("five_front",[2]);
			addAnimation("ten_front",[3]);
			addAnimation("token",[4]);
			addAnimation("one_back",[11]);
			addAnimation("five_back",[12]);
			addAnimation("ten_back",[13]);
			addAnimation("quarter",[14]);
			
			width = 128;
			height = 128;
			solid = false;

			x = FlxG.width - width * 2;
			y = FlxG.height - height;
			
			scrollFactor.x = scrollFactor.y = 0;
			scale.x = scale.y = 2;
			play("one_back");
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
			
			var _displayIndex:int;
			if (target.tokens > 0) _displayIndex = 0;
			else 
			{
				_displayIndex = target.inventory[target.currentItem];
				if (target.itemFacing == Player.UPSIDE_DOWN) _displayIndex += 4;
			}
			play(animationNames[_displayIndex]);
			
			var _speed:Number = Math.sqrt(target.velocity.x * target.velocity.x + target.velocity.y * target.velocity.y) / target.moveSpeed;
			var _delta:Number = _speed * Math.sqrt((swayDelta) / swayRadius);
			var _period:Number = 2 * Math.PI;
			swayPosition += FlxG.elapsed * _delta;
			if (swayPosition > _period) swayPosition -= _period;
			swayAngle = maxSwayAngle * Math.sin(swayPosition);
			offset.x = swayRadius * Math.sin(swayAngle * Math.PI / 180);
			offset.y = swayRadius * Math.cos(swayAngle * Math.PI / 180);
			target.itemSwapOffset += target.itemSwapDelta;
			offset.y += target.itemSwapOffset;
			//if (target.flipItemBuffer) offset.x -= target.itemSwapOffset;
			
			//currently unused
			target.viewOffset = offset.y / swayRadius;
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
	}
}