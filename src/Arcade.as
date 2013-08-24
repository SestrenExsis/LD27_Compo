package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.flixel.*;
	
	public class Arcade extends FlxTilemap
	{
		public static const LIGHT_LEVELS:uint = 10;
		
		public static const FLOOR:uint = 0;
		public static const NORTH:uint = 1;
		public static const EAST:uint = 2;
		public static const SOUTH:uint = 3;
		public static const WEST:uint = 4;
		public static const CEILING:uint = 5;
		
		[Embed(source="../assets/images/Textures.png")] protected static var imgTextures:Class;
		[Embed(source="../assets/maps/levelOne.csv", mimeType = "application/octet-stream")] protected var mapLevel1:Class;
		
		public var textures:FlxSprite;
		public var texWidth:Number = 128;
		public var texHeight:Number = 128;
		public var texWallHeight:Number = 256;
		public var uvWidth:Number;
		public var uvHeight:Number;
		public var uvWallHeight:Number;
		
		public var mapWidth:uint = 16;
		public var mapHeight:uint = 16;
		
		public var vismap:Dictionary;
		public var orderTree:Dictionary;
		
		public var lightmap:Array;
		public var lights:Array;
		
		public function Arcade(Canvas:Sprite, Plyr:Player)
		{
			super();
			
			loadMap(new mapLevel1, imgTextures, texWidth, texHeight, FlxTilemap.OFF, 0, 1, 1);
			
			lightmap = new Array(totalTiles);
			lights = new Array(totalTiles);
			setAmbientLighting(10);
			/*setLightingAt(3, 2, 10);
			setLightingAt(3, 20, 10);
			setLightingAt(3, 38, 10);
			setLightingAt(21, 2, 10);
			setLightingAt(21, 20, 10);
			setLightingAt(21, 38, 10);*/
			
			textures = new FlxSprite();
			textures.loadGraphic(imgTextures);
			uvWidth = texWidth / textures.width;
			uvHeight = texHeight / textures.height;
			uvWallHeight = texWallHeight / textures.height;
			FlxG.worldBounds.make(0, 0, width, height);
			vismap = new Dictionary();
			orderTree = new Dictionary();
		}
		
		override public function update():void
		{
			super.update();
			
			visible = FlxG.visualDebug;
			//planes.sort(sortByDistance);
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		public function setLightingAt(PosX:uint, PosY:uint, LightLevel:uint = 10):void
		{
			lights[PosX + PosY * widthInTiles] = LightLevel;
			
			var _span:int = LightLevel - 1;
			var _xx:int;
			var _yy:int;
			var _light:int;
			for (var _x:int = -_span; _x <= _span; _x++)
			{
				for (var _y:int = -_span; _y <= _span; _y++)
				{
					_xx = PosX + _x;
					_yy = PosY + _y;
					if (_xx >= 0 && _xx < widthInTiles && _yy >= 0 && _yy < heightInTiles)
					{
						_light = LightLevel - Math.max(Math.abs(_x), Math.abs(_y));
						if (lightmap[_xx + _yy * widthInTiles] < _light) 
						{
							lightmap[_xx + _yy * widthInTiles] = _light;
						}
					}
				}
			}
		}
		
		public function setAmbientLighting(LightLevel:uint = 1):void
		{
			for (var i:uint = 0; i < totalTiles; i++)
			{
				lights[i] = LightLevel;
				lightmap[i] = LightLevel;
			}
		}
		
		public function resetLighting(StartX:uint, StartY:uint, EndX:uint, EndY:uint):void
		{
			//recalculate all the lights within the bounded region
		}
	}
}