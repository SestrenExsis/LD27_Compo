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
		public var widthInWallTextures:uint = 32;
		public var heightInWallTextures:uint = 8;
		public var widthInFloorTextures:uint = 5;
		public var heightInFloorTextures:uint = 10;
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
			setAmbientLighting(4);
			var _tileIndex:int;
			for (var _x:uint = 0; _x < widthInTiles; _x++)
			{
				for (var _y:uint = 0; _y < heightInTiles; _y++)
				{
					_tileIndex = getTile(_x, _y) - 1;
					if (_tileIndex >= 4)
					{
						var _faceIndex:uint = _tileIndex - 4 * int(0.25 * _tileIndex);
						_tileIndex -= _faceIndex;
						switch (_faceIndex)
						{
							case 0:
								if (_y > 0) setPointLightAt(_x, _y, NORTH); break;
							case 1:
								if (_x < widthInTiles) setPointLightAt(_x, _y, EAST); break;
							case 2:
								if (_y < heightInTiles) setPointLightAt(_x, _y, SOUTH); break;
							case 3:
								if (_x > 0) setPointLightAt(_x, _y, WEST); break;
						}
					}
				}
			}
			/*setLightingAt(1, 1, 3);
			setLightingAt(14, 14, 3);
			setLightingAt(1, 14, 3);
			setLightingAt(14, 1, 3);*/
			
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
		
		public function setPointLightAt(PosX:uint, PosY:uint, Facing:uint):void
		{
			var _x:int;
			var _y:int;
			var _light:int;
			switch (Facing)
			{
				case NORTH:
					for (_x = PosX - 3; _x <= PosX + 3; _x++)
					{
						for (_y = PosY - 4; _y <= PosY; _y++)
						{
							if (_x == PosX - 3 || _x == PosX + 3 || _y == PosY - 4) _light = 3;
							else if (_x == PosX - 2 || _x == PosX + 2 || _y == PosY - 3) _light = 4;
							else if (_x == PosX - 1 || _x == PosX + 1 || _y == PosY - 2) _light = 5;
							else if (_y == PosY - 1) _light = 7;
							else _light = 4;
							
							if (_x >= 0 && _x < widthInTiles && _y >= 0 && _y < heightInTiles)
								if (lightmap[_x + _y * widthInTiles] < _light) lightmap[_x + _y * widthInTiles] = _light;
						}
					} break;
				case SOUTH:
					for (_x = PosX - 3; _x <= PosX + 3; _x++)
					{
						for (_y = PosY; _y <= PosY + 4; _y++)
						{
							if (_x == PosX - 3 || _x == PosX + 3 || _y == PosY + 4) _light = 3;
							else if (_x == PosX - 2 || _x == PosX + 2 || _y == PosY + 3) _light = 4;
							else if (_x == PosX - 1 || _x == PosX + 1 || _y == PosY + 2) _light = 5;
							else if (_y == PosY + 1) _light = 7;
							else _light = 4;
							
							if (_x >= 0 && _x < widthInTiles && _y >= 0 && _y < heightInTiles)
								if (lightmap[_x + _y * widthInTiles] < _light) lightmap[_x + _y * widthInTiles] = _light;
						}
					} break;
				case EAST:
					for (_x = PosX; _x <= PosX + 4; _x++)
					{
						for (_y = PosY - 3; _y <= PosY + 3; _y++)
						{
							if (_y == PosY - 3 || _y == PosY + 3 || _x == PosX + 4) _light = 3;
							else if (_y == PosY - 2 || _y == PosY + 2 || _x == PosX + 3) _light = 4;
							else if (_y == PosY - 1 || _y == PosY + 1 || _x == PosX + 2) _light = 5;
							else if (_x == PosX + 1) _light = 7;
							else _light = 4;
							
							if (_x >= 0 && _x < widthInTiles && _y >= 0 && _y < heightInTiles)
								if (lightmap[_x + _y * widthInTiles] < _light) lightmap[_x + _y * widthInTiles] = _light;
						}
					} break;
				case WEST:
					for (_x = PosX - 4; _x <= PosX; _x++)
					{
						for (_y = PosY - 3; _y <= PosY + 3; _y++)
						{
							if (_y == PosY - 3 || _y == PosY + 3 || _x == PosX - 4) _light = 3;
							else if (_y == PosY - 2 || _y == PosY + 2 || _x == PosX - 3) _light = 4;
							else if (_y == PosY - 1 || _y == PosY + 1 || _x == PosX - 2) _light = 5;
							else if (_x == PosX - 1) _light = 7;
							else _light = 4;
							
							if (_x >= 0 && _x < widthInTiles && _y >= 0 && _y < heightInTiles)
								if (lightmap[_x + _y * widthInTiles] < _light) lightmap[_x + _y * widthInTiles] = _light;
						}
					} break;
			}
			//lights[PosX + PosY * widthInTiles] = 8;
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