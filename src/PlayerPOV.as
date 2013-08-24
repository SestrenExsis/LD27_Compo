package
{
	import flash.display.Graphics;
	
	import org.flixel.*;
	
	public class PlayerPOV extends FlxSprite
	{
		[Embed(source="../assets/images/POVSprites.png")] protected static var imgPOV:Class;
		
		public var swayRadius:Number = 64;
		public var maxSwayAngle:Number = 60;
		//public var swayTime:Number = 1;
		public var swayPosition:Number = 0;
		public var swayAngle:Number = 0;
		public var swayDelta:Number = 2000;
		private var target:Player;
		
		public function PlayerPOV(Target:Player)
		{
			super(0, 0);
			target = Target;
			
			loadGraphic(imgPOV, true, true, 128, 128);
			addAnimation("cash",[1]);
			
			width = 128;
			height = 128;
			solid = false;

			x = FlxG.width - width * 2;
			y = FlxG.height - height;
			
			scrollFactor.x = scrollFactor.y = 0;
			scale.x = scale.y = 2;
			play("cash");
			FlxG.watch(this,"swayPosition");
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
			
			var _speed:Number = Math.sqrt(target.velocity.x * target.velocity.x + target.velocity.y * target.velocity.y) / target.moveSpeed;
			var _delta:Number = _speed * Math.sqrt((swayDelta) / swayRadius);
			//var _period:Number = (2 * Math.PI) / Math.sqrt(swayDelta / swayRadius);;
			swayPosition += FlxG.elapsed * _delta;
			//if (swayPosition > _period) swayPosition -= _period;
			swayAngle = maxSwayAngle * Math.sin(swayPosition);
			offset.x = swayRadius * Math.sin(swayAngle * Math.PI / 180);
			offset.y = swayRadius * Math.cos(swayAngle * Math.PI / 180);
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