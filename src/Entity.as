package
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{
		[Embed(source="../assets/images/Sprites.png")] protected static var imgSprites:Class;

		//different Entity Types
		public static const TOKEN:uint = 0;
		public static const ONE_DOLLAR_BILL:uint = 1;
		public static const FIVE_DOLLAR_BILL:uint = 2;
		public static const TEN_DOLLAR_BILL:uint = 3;
		//objectives
		public static const OBJECTIVE_START_GAME:uint = 10;
		public static const OBJECTIVE_CONTINUE_GAME:uint = 11;
		public static const OBJECTIVE_MAKE_CHANGE:uint = 12;
		public static const OBJECTIVE_GET_CHANGE:uint = 13;
		
		public static const UP_AND_DOWN:uint = 0;
		public static const LEFT_AND_RIGHT:uint = 1;
		
		public static var currentID:uint = 0;
		
		protected var _pos:FlxPoint;
		protected var _type:uint;
		
		public var viewPos:FlxPoint;
		public var distance:Number;
		public var clipRect:Rectangle;
		public var timer:FlxTimer;
		public var doClipping:Boolean = true;
		
		public var bobStyle:uint = UP_AND_DOWN;
		public var bobAmount:Number = 20;
		public var bobPosition:Number = 0;
		public var startingColor:uint = 0xffffff;
		public var endingColor:uint = 0xffffff;
		public var angleToPlayer:Number;
		public var distanceToPlayer:Number;
		
		public var prevObjectiveID:int;
		public var target:Entity;
		
		public var tokens:uint = 0;
		
		public function Entity(Type:uint, X:Number = 3.5, Y:Number = 2)
		{
			super(X, Y);
			
			loadGraphic(imgSprites, true, true, 128, 128);
			addAnimation("down_arrow",[5]);
			addAnimation("left_arrow",[15]);
			addAnimation("right_arrow",[25]);
			
			width = 128;
			height = 128;
			solid = true;

			x = X * 128 - width / 2;
			y = Y * 128 - height / 2;
			
			_pos = new FlxPoint();
			viewPos = new FlxPoint();
			clipRect = new Rectangle();
			timer = new FlxTimer();
			timer.start(0.001);
			type = Type;
			
			target = null;
			
			if (type >= OBJECTIVE_START_GAME) ID = currentID++;
			else ID = -1;
			play("down_arrow");
		}
		
		override public function draw():void
		{
			if (FlxG.visualDebug) super.draw();
			
			if (distance == -1 && type < OBJECTIVE_START_GAME) return;
			
			var _xx:Number = viewPos.x - 0.5 * frameWidth;
			var _yy:Number = viewPos.y - 0.5 * frameHeight;
			
			if (type >= OBJECTIVE_START_GAME) //objective
			{
				clipRect.x = clipRect.y = 0;
				clipRect.width = FlxG.width;
				clipRect.height = FlxG.height;
			}
			
			if(_flickerTimer != 0)
			{
				_flicker = !_flicker;
				if(_flicker)
					return;
			}
			
			if(dirty)	//rarely 
				calcFrame();
			
			if(cameras == null)
				cameras = FlxG.cameras;
			var camera:FlxCamera;
			var i:uint = 0;
			var l:uint = cameras.length;
			while(i < l)
			{
				camera = cameras[i++];
				//if(!onScreen(camera))
				//	continue;
				_point.x = _xx - offset.x;
				_point.y = _yy - offset.y;
				_point.x += (_point.x > 0)?0.0000001:-0.0000001;
				_point.y += (_point.y > 0)?0.0000001:-0.0000001;
				if(((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null)) //&& (skew.x == 0) && (skew.y == 0)
				{	//Simple render
					_flashPoint.x = _point.x;
					_flashPoint.y = _point.y;
					camera.buffer.copyPixels(framePixels,_flashRect,_flashPoint,null,null,true);
				}
				else
				{	//Advanced render
					_matrix.identity();
					//_matrix.concat(new flash.geom.Matrix(1, skew.y, skew.x, 1, 0, 0));//***
					_matrix.translate(-origin.x,-origin.y);
					_matrix.scale(scale.x,scale.y);
					if((angle != 0) && (_bakedRotation <= 0))
						_matrix.rotate(angle * 0.017453293);
					_matrix.translate(_point.x+origin.x,_point.y+origin.y);
					camera.buffer.draw(framePixels,_matrix,null,blend,null,antialiasing);
				}
				//_VISIBLECOUNT++;
				if(FlxG.visualDebug && !ignoreDrawDebug)
					drawDebug(camera);
			}
		}
		
		override public function update():void
		{
			super.update();
			
			if (type >= OBJECTIVE_START_GAME)
			{
				if (distanceToPlayer < 32)
				{
					visible = false;
				}
				else if (distance == -1 || (angleToPlayer > 320 || angleToPlayer < 220))
				{
					/*bobStyle = LEFT_AND_RIGHT;
					scale.x = scale.y = 1;
					if (angleToPlayer >= 90 && angleToPlayer <= 270)
					{
						viewPos.x = FlxG.width - 0.5 * frameWidth;
						play("right_arrow");
					}
					else
					{
						viewPos.x = 0.5 * frameWidth;
						play("left_arrow");
					}*/
				}
				else 
				{
					bobStyle = UP_AND_DOWN;
					play("down_arrow");
				}
				
				var _delta:Number = 60 * 180;
				var _period:Number = 360;
				bobPosition += FlxG.elapsed * _delta;
				if (bobPosition > _period) bobPosition -= _period;
				if (bobStyle == UP_AND_DOWN)
				{
					offset.x = 0;
					offset.y = bobAmount * Math.cos(bobPosition * Math.PI / 180) * scale.y;
				}
				else
				{
					offset.x = bobAmount * Math.sin(bobPosition * Math.PI / 180) * scale.x;
					offset.y = 0;
				}
				var _redStart:uint = (startingColor & 0xff0000) >> 16;
				var _greenStart:uint = (startingColor & 0x00ff00) >> 8;
				var _blueStart:uint = (startingColor & 0x0000ff);
				var _redEnd:uint = (endingColor & 0xff0000) >> 16;
				var _greenEnd:uint = (endingColor & 0x00ff00) >> 8;
				var _blueEnd:uint = (endingColor & 0x0000ff);
				
				var _progress:Number = Math.abs(bobPosition - 180) / 180;
				
				_redEnd = _progress * _redStart + (1 - _progress) * _redEnd;
				_greenEnd = _progress * _greenStart + (1 - _progress) * _greenEnd;
				_blueEnd = _progress * _blueStart + (1 - _progress) * _blueEnd;
				color = (_redEnd << 16) + (_greenEnd << 8) + _blueEnd;
			}
			else
			{
				offset.x = offset.y = 0;
			}
			
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			_pos = null;
			viewPos = null;
			clipRect = null;
			timer = null;
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
		
		public function get pos():FlxPoint
		{
			_pos.x = x + width / 2;
			_pos.y = y + height / 2;
			return _pos;
		}
		
		public function get type():uint
		{
			return _type;
		}
		
		public function set type(Value:uint):void
		{
			_type = Value;
			
			if (_type >= OBJECTIVE_START_GAME)
			{	//objective
				doClipping = false;
				startingColor = 0xffff00;
				endingColor = 0xff0000;
				color = startingColor;
				visible = false;
			}
		}
	}
}