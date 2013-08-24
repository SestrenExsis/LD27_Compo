package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.flixel.*;
	
	public class Arcade extends FlxTilemap
	{
		public static const LIGHT_LEVELS:uint = 8;
		
		public static const FLOOR:uint = 0;
		public static const NORTH:uint = 1;
		public static const EAST:uint = 2;
		public static const SOUTH:uint = 3;
		public static const WEST:uint = 4;
		public static const CEILING:uint = 5;
		
		[Embed(source="../assets/images/FloorTextures.png")] protected static var imgFloors:Class;
		[Embed(source="../assets/images/WallTextures.png")] protected static var imgWalls:Class;
		[Embed(source="../assets/maps/levelOne.csv", mimeType = "application/octet-stream")] protected var mapLevel1:Class;
		
		public var wallTextures:FlxSprite;
		public var floorTextures:FlxSprite;
		public var texFloorWidth:Number = 128;
		public var texFloorHeight:Number = 128;
		public var texWallWidth:Number = 128;
		public var texWallHeight:Number = 256;
		public var uvFloorWidth:Number;
		public var uvFloorHeight:Number;
		public var uvWallWidth:Number;
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
			
			loadMap(new mapLevel1, imgWalls, texFloorWidth, texFloorHeight, FlxTilemap.OFF, 0, 1, 1);
			
			lightmap = new Array(totalTiles);
			lights = new Array(totalTiles);
			setAmbientLighting(2);
			for (var x:uint = 0; x < widthInTiles; x++)
			{
				for (var y:uint = 0; y < heightInTiles; y++)
				{
					
				}
			}
			setLightingAt(1, 1, 8);
			setLightingAt(14, 14, 8);
			setLightingAt(1, 14, 8);
			setLightingAt(14, 1, 8);
			
			floorTextures = new FlxSprite();
			floorTextures.loadGraphic(imgFloors);
			uvFloorWidth = texFloorWidth / floorTextures.width;
			uvFloorHeight = texFloorHeight / floorTextures.height;
			
			wallTextures = new FlxSprite();
			wallTextures.loadGraphic(imgWalls);
			uvWallWidth = texWallWidth / wallTextures.width;
			uvWallHeight = texWallHeight / wallTextures.height;
			
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
		
		public function setLightingAt(PosX:uint, PosY:uint, LightLevel:uint = 8):void
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