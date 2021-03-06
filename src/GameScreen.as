package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.flixel.*;
	
	public class GameScreen extends ScreenState
	{
		private var worldScale:FlxPoint;
		
		public var viewport:FlxSprite;
		
		private var sourceRect:Rectangle;
		private var floorSourceRect:Rectangle;
		private var destRect:Rectangle;
		private var ceilingRect:Rectangle;
		private var floorRect:Rectangle;
		private var oldSourceX:Number;
		
		private var debugState:uint = 0;
		
		private var player:Player;
		private var playerPOV:PlayerPOV;
		private var arcade:Arcade;
		private var entity:Entity;
		private var objectives:FlxGroup;
		//private var entities:FlxGroup;
		
		private var orderOfObjectives:Array = [0, 1, 2, 0, 1, 2, 0, 1, 5, 6, 7, 5, 6, 7, 8, 6, 7, 8];
		
		//for drawing triangles
		private var canvas:Sprite;
		private var pt0:FlxPoint;
		private var pt1:FlxPoint;
		private var pt2:FlxPoint;
		private var pt3:FlxPoint;
		private var floorPt0:FlxPoint;
		private var floorPt1:FlxPoint;
		private var floorPt2:FlxPoint;
		private var floorPt3:FlxPoint;
		private var uv:Rectangle;
		private var _point:FlxPoint;
		private var _pt:FlxPoint;
		protected var _intersect:FlxPoint;
		
		private var negative:int = 1;
		private var orderTreeMin:int = 0;
		private var orderTreeMax:int = 0;
		
		private var side:int;
		private var drawStart:uint;
		private var drawEnd:uint;
		private var lineHeight:uint;
		
		//texturing calculations
		private var texNum:uint;
		private var wallX:Number;
		
		private var showTriangleEdges:Boolean = false;
		private var useVertexDictionary:Boolean = true;
		private var aspectRatio:Number;
		private var maxRenderDistance:Number;
		
		//private var zBuffer:Array;
		
		public function GameScreen()
		{
			super();
		}

		override public function create():void
		{
			super.create();
			
			worldScale = new FlxPoint(0.5, 1);
			
			viewport = new FlxSprite(0, 0);
			viewport.scrollFactor.make(0, 0);
			viewport.makeGraphic(FlxG.width, FlxG.height, 0xffff0000);
			aspectRatio = viewport.width / viewport.height;
			
			//for drawing triangles
			canvas = new Sprite();
			canvas.width = viewport.width;
			canvas.height = viewport.height;
			pt0 = new FlxPoint();
			pt1 = new FlxPoint();
			pt2 = new FlxPoint();
			pt3 = new FlxPoint();
			floorPt0 = new FlxPoint();
			floorPt1 = new FlxPoint();
			floorPt2 = new FlxPoint();
			floorPt3 = new FlxPoint();
			uv = new Rectangle();
			_point = new FlxPoint();
			_pt = new FlxPoint();
			_intersect = new FlxPoint();
			
			player = new Player();
			FlxG.camera.follow(player);
			playerPOV = new PlayerPOV(player);
			
			objectives = new FlxGroup();
			//the first game
			entity = new Entity(Entity.OBJECTIVE_MAKE_CHANGE, 4.5, 26);
			objectives.add(entity);
			entity = new Entity(Entity.OBJECTIVE_GET_CHANGE, 3.5, 26);
			(objectives.members[0] as Entity).target = entity;
			objectives.add(entity);
			entity = new Entity(Entity.OBJECTIVE_START_GAME, 2, 21.5);
			objectives.add(entity);
			
			//the second game
			entity = new Entity(Entity.OBJECTIVE_MAKE_CHANGE, 15.5, 20);
			objectives.add(entity);
			entity = new Entity(Entity.OBJECTIVE_GET_CHANGE, 14.5, 20);
			(objectives.members[3] as Entity).target = entity;
			objectives.add(entity);
			entity = new Entity(Entity.OBJECTIVE_START_GAME, 9, 7.5);
			objectives.add(entity);
			
			//the last game
			entity = new Entity(Entity.OBJECTIVE_MAKE_CHANGE, 14.5, 5);
			objectives.add(entity);
			entity = new Entity(Entity.OBJECTIVE_GET_CHANGE, 15.5, 5);
			(objectives.members[6] as Entity).target = entity;
			objectives.add(entity);
			entity = new Entity(Entity.OBJECTIVE_START_GAME, 19.5, 25);
			objectives.add(entity);
			
			//entities = new FlxGroup();
			
			arcade = new Arcade(canvas, player);
			sourceRect = new Rectangle(0, 0, arcade.uvWallWidth, arcade.uvWallHeight);
			floorSourceRect = new Rectangle(0, 0, arcade.uvFloorWidth, arcade.uvFloorHeight);
			destRect = new Rectangle(0, 0, 1, 0);
			ceilingRect = new Rectangle(0, 0, FlxG.width, FlxG.height / 2);
			floorRect = new Rectangle(0, FlxG.height / 2, FlxG.width, FlxG.height / 2);
			
			add(viewport);
			add(arcade);
			add(player);
			//add(entities);
			add(objectives);
			add(playerPOV);
			add(overlay);
			add(information);
			add(information2);
			
			//zBuffer = new Array(viewport.width);
			maxRenderDistance = 30;
			
			FlxG.watch(player, "currentObjective");
			FlxG.watch(objectives.members[0], "visible");
		}
		
		override public function destroy():void
		{
			worldScale = null;
			viewport = null;
			canvas = null;
			pt0 = null;
			pt1 = null;
			pt2 = null;
			pt3 = null;
			floorPt0 = null;
			floorPt1 = null;
			floorPt2 = null;
			floorPt3 = null;
			uv = null;
			_point = null;
			_pt = null;
			_intersect = null;
			
			FlxG.camera.follow(null);
			FlxG.unwatch(player, "currentObjective");
			player = null;
			playerPOV = null;
			
			objectives.destroy();
			//the first game
			
			arcade = null;
			sourceRect = null;
			floorSourceRect = null;
			destRect = null;
			ceilingRect = null;
			floorRect = null;
			overlay = null;
			information = null;
			information = null;
			
			super.destroy();
		}
		
		override public function update():void
		{	
			super.update();

			FlxG.overlap(player, arcade, collideWithMap);
			FlxG.overlap(player, objectives, collideWithObjective);
			
			viewport.fill(0xff000000);
			
			drawViewWithFaces();
			//renderEntities();
			renderObjectives();
			
			information.text = player.info;
			//if (FlxG.keys.justPressed("T")) showTriangleEdges = !showTriangleEdges;
		}
		
		private function onTimerGameOver(Timer:FlxTimer):void
		{
			//information.text = "Refresh the page to try again.";
			information2.text = "You didn't make it in time.";
			player.currentObjective = 0;
			player.playingGame = true;
			player.velocity.x = player.velocity.y = player.angularVelocity = 0;
			timer.stop();
			timer.start(3, 1, onTimerRestart);
		}
		
		private function onTimerRestart(Timer:FlxTimer):void
		{
			Entity.currentID = 0;
			onButtonMenu();
		}
		
		private function collideWithMap(Object1:FlxObject, Object2:FlxObject):void
		{
			FlxObject.separate(Object1, Object2);
		}
		
		private function collideWithObjective(Object1:FlxObject, Object2:FlxObject):void
		{
			if (Object1 is Player) 
			{
				if (player.timer.finished) 
				{
					if ((Object2 as Entity).target)
					{
						if ((Object2 as Entity).ID == orderOfObjectives[player.currentObjective])
						{
							if (player.useItem(Object2 as Entity, (Object2 as Entity).target)) player.currentObjective += 1;
						}
					}
					else 
					{
						if ((Object2 as Entity).ID == orderOfObjectives[player.currentObjective])
						{
							if (player.useItem(Object2 as Entity)) player.currentObjective += 1;
						}
						if ((Object2 as Entity).type == Entity.OBJECTIVE_START_GAME)
						{
							if (player.currentObjective == 18) 
							{
								overlay.play("win", true);
								timer.stop();
							}
							else if (player.currentObjective == 3 || player.currentObjective == 9
								|| player.currentObjective == 15) 
							{
								timer.stop();
								timer.start(10, 1, onTimerGameOver);
								overlay.play("countdown", true);
							}
							else if (player.currentObjective == 6 || player.currentObjective == 12
								|| player.currentObjective == 18) 
							{
								timer.stop();
								timer.start(10, 1, onTimerGameOver);
								overlay.play("hurry", true);
							}
							
							if (player.currentObjective == 3) 
								information2.text = "You're out of lives! You need more tokens to continue!";
							else if (player.currentObjective == 6)
								information2.text = "Now hurry to the next game before someone else gets there!";
							else if (player.currentObjective == 9)
								information2.text = "You're out of lives! Hurry!";
							else if (player.currentObjective == 12)
								information2.text = "Just one more game to beat and then you can stop off for ice cream.";
							else if (player.currentObjective == 15)
								information2.text = "You're on the final boss. Don't give up now!";
							else if (player.currentObjective == 18)
								information2.text = "You did it! And you've got enough money left over for two ice creams!";
						}
					}
				}
			}
			else collideWithObjective(Object2, Object1);
		}
		
		private function drawViewWithFaces():void
		{
			arcade.vismap = new Dictionary();
			arcade.orderTree = new Dictionary();
			orderTreeMin = orderTreeMax = 0;
			canvas.graphics.clear();
			if (showTriangleEdges) canvas.graphics.lineStyle(1, 0x00ff00);
			else canvas.graphics.lineStyle();
			addFacesToBuffer(viewport.width);
			
			var _x:uint;
			var _y:uint;
			var _index:int;
			var _face:uint;
			for (var _order:int = orderTreeMin; _order <= orderTreeMax; _order++)
			{
				if (_order == 0) _order += 1;
				_index = arcade.orderTree[_order];
				_face = arcade.vismap[_index];
				if (_index < 0) _index *= -1;
				_x = _index % arcade.widthInTiles;
				_y = int(_index / arcade.widthInTiles);
				renderWall(_x, _y, _face);
			}
			
			viewport.pixels.draw(canvas);
			playerPOV.light(arcade.lightmap[int(player.pos.x / arcade.texFloorWidth)
				+ arcade.widthInTiles * int(player.pos.y / arcade.texFloorHeight)]);
		}
		
		private function addFacesToBuffer(SearchResolution:uint):void
		{
			//****************************************************************************
			// A lot of this code is borrowed from http://lodev.org/cgtutor/raycasting.html.
			// Many thanks to them for the great tutorial.
			//****************************************************************************
			
			//x-coordinate in camera space
			var cameraX:Number;
			//length of ray from current position to next x or y-side
			var sideDistX:Number;
			var sideDistY:Number;
			//length of ray from one x or y-side to next x or y-side
			var deltaDistX:Number;
			var deltaDistY:Number;
			var perpWallDist:Number;
			//what direction to step in x or y-direction (either +1 or -1)
			var stepX:int;
			var stepY:int;
			//var side:int; //was a NS or a EW wall hit?
			var lineHeight:int;
			var drawStart:int;
			var drawEnd:int;
			var texNum:int;
			//var wallX:Number; //where exactly the wall was hit
			var texX:Number;
			//var texY:int;
			var color:uint;
			var y:int;
			var playerPosX:Number;
			var playerPosY:Number;
			var tileX:int;
			var tileY:int;
			//used to combine strips for a drawTriangles() call
			var lastTileX:int = -1;
			var lastTileY:int = -1;
			var lastSide:int = -1;
			var lastWallDistance:Number;
			var wallDistance:Number;
			var _renderDistance:Number;
			var _distX:Number;
			var _distY:Number;
			
			playerPosX = player.pos.x / arcade.texFloorWidth;
			playerPosY = player.pos.y / arcade.texFloorHeight;
			
			for (var x:uint = 0; x < SearchResolution; x += 1)
			{
				cameraX = (2 * (x / SearchResolution) - 1) / worldScale.x;
				
				player.setRayDir(cameraX);
				
				//which box of the map we're in  
				tileX = int(playerPosX);
				tileY = int(playerPosY);
				
				//calculate length of ray from one x or y-side to next x or y-side
				deltaDistX = Math.sqrt(1 + (player.rayDir.y * player.rayDir.y) / (player.rayDir.x * player.rayDir.x));
				deltaDistY = Math.sqrt(1 + (player.rayDir.x * player.rayDir.x) / (player.rayDir.y * player.rayDir.y));
				
				//calculate step and initial sideDist
				if (player.rayDir.x < 0)
				{
					stepX = -1;
					sideDistX = (playerPosX - tileX) * deltaDistX;
				}
				else
				{
					stepX = 1;
					sideDistX = (tileX + 1.0 - playerPosX) * deltaDistX;
				}      
				if (player.rayDir.y < 0)
				{
					stepY = -1;
					sideDistY = (playerPosY - tileY) * deltaDistY;
				}
				else
				{
					stepY = 1;
					sideDistY = (tileY + 1.0 - playerPosY) * deltaDistY;
				}
				//perform DDA
				passedThroughTile(tileX, tileY);
				do {//jump to next map square, OR in x-direction, OR in y-direction
					if (sideDistX < sideDistY)
					{
						sideDistX += deltaDistX;
						tileX += stepX;
						side = 0;
						//if (stepX
					}
					else
					{
						sideDistY += deltaDistY;
						tileY += stepY;
						side = 1;
					}
					_distX = playerPosX - tileX;
					_distY = playerPosY - tileY;
					_renderDistance = Math.sqrt(_distX * _distX + _distY * _distY);
				} while (passedThroughTile(tileX, tileY))// && _renderDistance < maxRenderDistance); //Check if ray has hit a wall
				
				//if (_renderDistance <= maxRenderDistance)
				{
					if (side == 0) wallDistance = Math.abs((tileX - playerPosX + (1 - stepX) / 2) / player.rayDir.x);
					else wallDistance= Math.abs((tileY - playerPosY + (1 - stepY) / 2) / player.rayDir.y);
					//zBuffer[x] = wallDistance;
					if (lastTileX != tileX || lastTileY != tileY || lastSide != side)
					{
						if (wallDistance < lastWallDistance)
						{
							orderTreeMax += 1;
							arcade.orderTree[orderTreeMax] = negative * (tileX + tileY * arcade.widthInTiles);
						}
						else
						{
							orderTreeMin -= 1;
							arcade.orderTree[orderTreeMin] = negative * (tileX + tileY * arcade.widthInTiles);
						}
						//FlxG.log(negative);
						lastWallDistance = wallDistance;
						lastTileX = tileX;
						lastTileY = tileY;
						lastSide = side;
					}
				}
				//else zBuffer[x] = maxRenderDistance;
			}
		}
		
		public function passedThroughTile(TileX:uint, TileY:uint):Boolean
		{
			var _tile:uint = arcade.getTile(TileX, TileY);
			var _index:uint = TileX + TileY * arcade.widthInTiles;
			var _face:uint = 0;
			negative = 1;
			
			if (_tile == 0) //floor tile
			{
				var _tileX:int = (player.pos.x / arcade.texFloorWidth);
				var _tileY:int = (player.pos.y / arcade.texFloorHeight);
				_face = Arcade.FLOOR;
				if (arcade.vismap[_index] != _face) renderFloor(TileX, TileY, TileX + 1, TileY + 1, 2);
			}
			else //wall tile
			{
				if (side == 1) //north or south faces
				{
					negative = 1;
					if (player.rayDir.y < 0) _face = Arcade.SOUTH;
					else _face = Arcade.NORTH;
				}
				else //east or west faces
				{
					negative = -1;
					if (player.rayDir.x > 0) _face = Arcade.WEST;
					else _face = Arcade.EAST;
				}
			}
			arcade.vismap[negative * _index] = _face;
			return (_tile == 0);
		}
		
		private function renderFloor(StartTileX:Number, StartTileY:Number, EndTileX:Number, EndTileY:Number, IterationsLeft:uint = 2):void
		{
			var _pX:Number = player.pos.x / arcade.texFloorWidth;
			var _pY:Number = player.pos.y / arcade.texFloorHeight;
			var _tX:Number = 0.5 * (StartTileX + EndTileX);
			var _tY:Number = 0.5 * (StartTileY + EndTileY);
			
			var _tileDistance:Number = Math.sqrt((_pX - _tX) * (_pX - _tX) + (_pY - _tY) * (_pY - _tY));
			var _badPt0:Boolean = false;
			var _badPt1:Boolean = false;
			var _badPt2:Boolean = false;
			var _badPt3:Boolean = false;
			var _badPointExists:Boolean = false;
			var _ptDistance:Number = 0;
			var _closestGoodPt:int = -1;
			var _minDistance:Number = 10;
			var _offScreenCount:uint = 0;
			
			//distance to upper-left corner of tile
			_pt.x = StartTileX * arcade.texFloorWidth;
			_pt.y = StartTileY * arcade.texFloorHeight;
			_ptDistance = projectPointToScreen(_pt.x, _pt.y, 0, floorPt0)
			if (_ptDistance == -1) _badPt0 = _badPointExists = true;
			else if (_ptDistance < _minDistance)
			{
				_closestGoodPt = 0;
				_minDistance = _ptDistance;
			}
			
			//distance to upper-right corner of tile
			_pt.x = EndTileX * arcade.texFloorWidth;
			_ptDistance = projectPointToScreen(_pt.x, _pt.y, 0, floorPt1)
			if (_ptDistance == -1) _badPt1 = _badPointExists = true;
			else if (_ptDistance < _minDistance)
			{
				_closestGoodPt = 1;
				_minDistance = _ptDistance;
			}
			
			//distance to lower-right corner of tile
			_pt.y = EndTileY * arcade.texFloorHeight;
			_ptDistance = projectPointToScreen(_pt.x, _pt.y, 0, floorPt3)
			if (_ptDistance == -1) _badPt3 = _badPointExists = true;
			else if (_ptDistance < _minDistance)
			{
				_closestGoodPt = 3;
				_minDistance = _ptDistance;
			}
			
			//distance to lower-left corner of tile
			_pt.x = StartTileX * arcade.texFloorWidth;
			_ptDistance = projectPointToScreen(_pt.x, _pt.y, 0, floorPt2)
			if (_ptDistance == -1) _badPt2 = _badPointExists = true;
			else if (_ptDistance < _minDistance)
			{
				_closestGoodPt = 2;
				_minDistance = _ptDistance;
			}
			
			if (_badPointExists)
			{
				if (IterationsLeft == 0) return;
				//invalidate the closest good point, so we can figure out whether to cut it in half or in quadrants, as well as
				//which quadrant or half to use
				if (_closestGoodPt == 0) _badPt0 = true;
				else if (_closestGoodPt == 1) _badPt1 = true;
				else if (_closestGoodPt == 2) _badPt2 = true;
				else if (_closestGoodPt == 3) _badPt3 = true;
				
				var _sX:Number = StartTileX;
				var _sY:Number = StartTileY;
				var _eX:Number = EndTileX;
				var _eY:Number = EndTileY;
				if 		(_badPt0 && _badPt1) _sY = StartTileY + 0.4 * (EndTileY - StartTileY);
				else if (_badPt2 && _badPt3) _eY = StartTileY + 0.6 * (EndTileY - StartTileY);
				if 		(_badPt0 && _badPt2) _sX = StartTileX + 0.4 * (EndTileX - StartTileX);
				else if (_badPt1 && _badPt3) _eX = StartTileX + 0.6 * (EndTileX - StartTileX);
				if (IterationsLeft > 0) renderFloor(_sX, _sY, _eX, _eY, IterationsLeft - 1);
			}
			else
			{
				var _light:int = Arcade.LIGHT_LEVELS - arcade.lightmap[int(StartTileX) + int(StartTileY) * arcade.widthInTiles];
				if (_tileDistance >= 10) _light += int(1 * (_tileDistance - 9));
				if (_light >= Arcade.LIGHT_LEVELS) return;//_light = 5;
				var _startTexX:Number = arcade.uvFloorWidth * (StartTileX - int(StartTileX));
				var _startTexY:Number = arcade.uvFloorHeight * (StartTileY - int(StartTileY));
				var _endTexX:Number = arcade.uvFloorWidth * (EndTileX - int(StartTileX));
				var _endTexY:Number = arcade.uvFloorHeight * (EndTileY - int(StartTileY));
				
				//x, y, width, and height must be moved over 1 to give a texture "buffer" zone to prevent seams.
				floorSourceRect.x = 1 * arcade.uvFloorWidth + _startTexX;
				floorSourceRect.y = (_light + 1) * arcade.uvFloorHeight + _startTexY;
				floorSourceRect.width = 1 * arcade.uvFloorWidth + _endTexX;
				floorSourceRect.height = (_light + 1) * arcade.uvFloorHeight + _endTexY;
				drawPlaneToCanvas(floorPt0, floorPt1, floorPt2, floorPt3, floorSourceRect, arcade.floorTextures.pixels);
				
				floorPt0.y = viewport.height - floorPt0.y;
				floorPt1.y = viewport.height - floorPt1.y;
				floorPt2.y = viewport.height - floorPt2.y;
				floorPt3.y = viewport.height - floorPt3.y;
				
				//x and width must be moved over an additional 2 to give a texture "buffer" zone to prevent seams.
				floorSourceRect.x = 3 * arcade.uvFloorWidth + _startTexX;
				floorSourceRect.width = 3 * arcade.uvFloorWidth + _endTexX;
				drawPlaneToCanvas(floorPt0, floorPt1, floorPt2, floorPt3, floorSourceRect, arcade.floorTextures.pixels);
			}
		}
		
		private function renderWall(TileX:uint, TileY:uint, Face:uint):void
		{
			var _pX:Number = player.pos.x / arcade.texFloorWidth;
			var _pY:Number = player.pos.y / arcade.texFloorHeight;
			var _tX:Number = TileX + 0.5;
			var _tY:Number = TileY + 0.5;
			var _tileDistance:Number = Math.sqrt((_pX - _tX) * (_pX - _tX) + (_pY - _tY) * (_pY - _tY));
			
			var _index:uint = TileX + TileY * arcade.widthInTiles;
			var _light:int;
			//Use the lighting of the square that is adjacent to this particular wall face
			if (Face == Arcade.WEST) _light = Arcade.LIGHT_LEVELS - arcade.lightmap[_index - 1];
			else if (Face == Arcade.EAST) _light = Arcade.LIGHT_LEVELS - arcade.lightmap[_index + 1];
			else if (Face == Arcade.NORTH) _light = Arcade.LIGHT_LEVELS - arcade.lightmap[_index - arcade.widthInTiles];
			else if (Face == Arcade.SOUTH) _light = Arcade.LIGHT_LEVELS - arcade.lightmap[_index + arcade.widthInTiles];
			if (_tileDistance >= 10) _light += int(1 * (_tileDistance - 9));
			if (_light >= Arcade.LIGHT_LEVELS) return;
			
			var _tileIndex:uint = arcade.getTile(TileX, TileY) - 1;
			var _faceIndex:uint = _tileIndex - 4 * int(0.25 * _tileIndex);
			_tileIndex -= _faceIndex;
			switch (_faceIndex)
			{
				case 0:
					_tileIndex += (Face - 1) % 4; break;
				case 1:
					_tileIndex += (Face + 2) % 4; break;
				case 2:
					_tileIndex += (Face + 1) % 4; break;
				case 3:
					_tileIndex += (Face + 0) % 4; break;
			}
			//move downward on the texture file based on how dark it needs to be.
			sourceRect.x = arcade.uvWallWidth * int(_tileIndex % arcade.widthInWallTextures);
			sourceRect.y = arcade.uvWallHeight * _light;
			sourceRect.width = sourceRect.x + arcade.uvWallWidth;
			sourceRect.height = sourceRect.y + arcade.uvWallHeight;
			
			var _ptDistance:Number = 0;
			var _shiftAmount:Number = 0.15;
			//distance to upper-left corner of face
			_pt.x = TileX * arcade.texFloorWidth;
			_pt.y = TileY * arcade.texFloorHeight;
			if (Face == Arcade.EAST || Face == Arcade.SOUTH) _pt.x += arcade.texFloorWidth;
			if (Face == Arcade.WEST || Face == Arcade.SOUTH) _pt.y += arcade.texFloorHeight;
			_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt0)
			if (_ptDistance == -1)
			{
				sourceRect.x += _shiftAmount * arcade.uvWallWidth;
				if (Face == Arcade.NORTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
				else if (Face == Arcade.EAST) _pt.y += _shiftAmount * arcade.texFloorHeight;
				else if (Face == Arcade.SOUTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
				else if (Face == Arcade.WEST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
				_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt0);
				if (_ptDistance == -1)
				{	// If the distance is negative, then the point is behind the player, and will not render properly. So, we need to cut
					//part of the wall off and try again, and again, and again, if needed ...
					sourceRect.x += _shiftAmount * arcade.uvWallWidth;
					if (Face == Arcade.NORTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
					else if (Face == Arcade.EAST) _pt.y += _shiftAmount * arcade.texFloorHeight;
					else if (Face == Arcade.SOUTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
					else if (Face == Arcade.WEST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
					_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt0);
					if (_ptDistance == -1)
					{
						sourceRect.x += _shiftAmount * arcade.uvWallWidth;
						if (Face == Arcade.NORTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
						else if (Face == Arcade.EAST) _pt.y += _shiftAmount * arcade.texFloorHeight;
						else if (Face == Arcade.SOUTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
						else if (Face == Arcade.WEST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
						_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt0);
						if (_ptDistance == -1)
						{
							sourceRect.x += _shiftAmount * arcade.uvWallWidth;
							if (Face == Arcade.NORTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
							else if (Face == Arcade.EAST) _pt.y += _shiftAmount * arcade.texFloorHeight;
							else if (Face == Arcade.SOUTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
							else if (Face == Arcade.WEST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
							_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt0);
							if (_ptDistance == -1)
							{
								sourceRect.x += _shiftAmount * arcade.uvWallWidth;
								if (Face == Arcade.NORTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
								else if (Face == Arcade.EAST) _pt.y += _shiftAmount * arcade.texFloorHeight;
								else if (Face == Arcade.SOUTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
								else if (Face == Arcade.WEST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
								_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt0);
								if (_ptDistance == -1)
								{
									sourceRect.x += _shiftAmount * arcade.uvWallWidth;
									if (Face == Arcade.NORTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
									else if (Face == Arcade.EAST) _pt.y += _shiftAmount * arcade.texFloorHeight;
									else if (Face == Arcade.SOUTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
									else if (Face == Arcade.WEST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
									_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt0);
								}
							}
						}
					}
				}
			}
			if (_ptDistance == -1) return;
			
			//distance to lower-left corner of face
			pt2.x = pt0.x;
			pt2.y = viewport.height - pt0.y;
			
			//distance to upper-right corner of face
			_pt.x = TileX * arcade.texFloorWidth;
			_pt.y = TileY * arcade.texFloorHeight;
			if (Face == Arcade.NORTH || Face == Arcade.EAST) _pt.x += arcade.texFloorWidth;
			if (Face == Arcade.EAST || Face == Arcade.SOUTH) _pt.y += arcade.texFloorHeight;
			_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt1);
			
			if (_ptDistance == -1)
			{	// If the distance is negative, then the point is behind the player, and will not render properly. So, we need to cut
				//part of the wall off and try again, and again, and again, if needed ...
				sourceRect.width -= _shiftAmount * arcade.uvWallWidth;
				if (Face == Arcade.NORTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
				else if (Face == Arcade.EAST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
				else if (Face == Arcade.SOUTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
				else if (Face == Arcade.WEST) _pt.y += _shiftAmount * arcade.texFloorHeight;
				_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt1);
				if (_ptDistance == -1)
				{
					sourceRect.width -= _shiftAmount * arcade.uvWallWidth;
					if (Face == Arcade.NORTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
					else if (Face == Arcade.EAST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
					else if (Face == Arcade.SOUTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
					else if (Face == Arcade.WEST) _pt.y += _shiftAmount * arcade.texFloorHeight;
					_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt1);
					if (_ptDistance == -1)
					{
						sourceRect.width -= _shiftAmount * arcade.uvWallWidth;
						if (Face == Arcade.NORTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
						else if (Face == Arcade.EAST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
						else if (Face == Arcade.SOUTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
						else if (Face == Arcade.WEST) _pt.y += _shiftAmount * arcade.texFloorHeight;
						_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt1);
						if (_ptDistance == -1)
						{
							sourceRect.width -= _shiftAmount * arcade.uvWallWidth;
							if (Face == Arcade.NORTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
							else if (Face == Arcade.EAST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
							else if (Face == Arcade.SOUTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
							else if (Face == Arcade.WEST) _pt.y += _shiftAmount * arcade.texFloorHeight;
							_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt1);
							if (_ptDistance == -1)
							{
								sourceRect.width -= _shiftAmount * arcade.uvWallWidth;
								if (Face == Arcade.NORTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
								else if (Face == Arcade.EAST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
								else if (Face == Arcade.SOUTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
								else if (Face == Arcade.WEST) _pt.y += _shiftAmount * arcade.texFloorHeight;
								_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt1);
								if (_ptDistance == -1)
								{
									sourceRect.width -= _shiftAmount * arcade.uvWallWidth;
									if (Face == Arcade.NORTH) _pt.x -= _shiftAmount * arcade.texFloorWidth;
									else if (Face == Arcade.EAST) _pt.y -= _shiftAmount * arcade.texFloorHeight;
									else if (Face == Arcade.SOUTH) _pt.x += _shiftAmount * arcade.texFloorWidth;
									else if (Face == Arcade.WEST) _pt.y += _shiftAmount * arcade.texFloorHeight;
									_ptDistance = projectPointToScreen(_pt.x, _pt.y, arcade.texFloorHeight, pt1);
								}
							}
						}
					}
				}
			}
			if (_ptDistance == -1) return;
			
			//distance to lower-right corner of face
			pt3.x = pt1.x;
			pt3.y = viewport.height - pt1.y;
			
			drawPlaneToCanvas(pt0, pt1, pt2, pt3, sourceRect, arcade.wallTextures.pixels);
		}
		
		public function renderObjectives():void
		{
			for (var i:uint = 0; i < objectives.length; i++)
			{
				entity = objectives.members[i];
				if (entity.exists)
				{
					entity.distance = projectPointToScreen(entity.pos.x, entity.pos.y, 0.5 * arcade.texFloorHeight, entity.viewPos, entity);
					if (entity.ID == orderOfObjectives[player.currentObjective])
					{
						entity.visible = true;
						entity.angleToPlayer = Math.abs(FlxU.getAngle(entity.pos, player.pos) - player.viewAngle + 360) % 360;
						entity.distanceToPlayer = FlxU.getDistance(entity.pos, player.pos);
					}
					else entity.visible = false;
				}
			}
		}
		
		public function drawPlaneToCanvas(Point0:FlxPoint, Point1:FlxPoint, Point2:FlxPoint, Point3:FlxPoint, SourceRect:Rectangle, Bmp:BitmapData):void
		{
			//Many thanks to http://zehfernando.com/2010/the-best-drawplane-distortimage-method-ever/ for this!
			
			var _indentX:Number = 0.000390625;//1/128/10/2;
			var _indentY:Number = 0.000390625;//1/128/20/2;
			_point = intersect(Point0, Point1, Point2, Point3);
			if (_point == null) return;
			
			// Lengths of first diagonal		
			var ll1:Number = FlxU.getDistance(Point0, _point);
			var ll2:Number = FlxU.getDistance(_point, Point3);
			
			// Lengths of second diagonal		
			var lr1:Number = FlxU.getDistance(Point1, _point);
			var lr2:Number = FlxU.getDistance(_point, Point2);
			
			// Ratio between diagonals
			var f:Number = (ll1 + ll2) / (lr1 + lr2);
			
			// Draws the triangle
			canvas.graphics.beginBitmapFill(Bmp, null, false, false);
			canvas.graphics.drawTriangles(
				Vector.<Number>([Point0.x, Point0.y, Point1.x, Point1.y, Point2.x, Point2.y, Point3.x, Point3.y]),
				Vector.<int>([0, 1, 2, 1, 3, 2]),
				Vector.<Number>([
					SourceRect.x + _indentX,		SourceRect.y + _indentY,		(1/ll2)*f,
					SourceRect.width - _indentX,	SourceRect.y + _indentY,		(1/lr2), 
					SourceRect.x + _indentX,		SourceRect.height - _indentY,	(1/lr1),
					SourceRect.width - _indentX,	SourceRect.height - _indentY,	(1/ll1)*f ])
			);
		}
		
		/**
		 * Get the <code>intersect</code> of the diagonals between the four courners of the 3D face we're wanting to draw.
		 */
		public function intersect(Point0:FlxPoint, Point1:FlxPoint, Point2:FlxPoint, Point3:FlxPoint):FlxPoint
		{
			// Returns a point containing the intersection between two lines
			// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
			
			var a1:Number = Point3.y - Point0.y;
			var b1:Number = Point0.x - Point3.x;
			var a2:Number = Point1.y - Point2.y;
			var b2:Number = Point2.x - Point1.x;
			
			var denom:Number = a1 * b2 - a2 * b1;
			if (denom == 0) return null;
			
			var c1:Number = Point3.x * Point0.y - Point0.x * Point3.y;
			var c2:Number = Point1.x * Point2.y - Point2.x * Point1.y;
			
			_intersect.make((b1 * c2 - b2 * c1)/denom, (a2 * c1 - a1 * c2)/denom);
			
			if (FlxU.getDistance(_intersect, Point3) > FlxU.getDistance(Point0, Point3)) return null;
			if (FlxU.getDistance(_intersect, Point0) > FlxU.getDistance(Point0, Point3)) return null;
			if (FlxU.getDistance(_intersect, Point1) > FlxU.getDistance(Point2, Point1)) return null;
			if (FlxU.getDistance(_intersect, Point2) > FlxU.getDistance(Point2, Point1)) return null;
			
			return _intersect;
		}
		
		/**
		 * Projects a point in 3d (x, y, z) map space to a point in 2d (x, y) screen space, relative to the Player.
		 * 
		 * @param	SourceX				The x-coordinate in map space of the point to be projected.
		 * @param	SourceY				The y-coordinate in map space of the point to be projected.
		 * @param	SourceZ				The z-coordinate in map space of the point to be projected.
		 * @param	DestinationPoint	The point used to store the screen coordinates after projection.
		 * @param	GameEntity			If present, it means this Entity needs to be resized after its distance has been calculated.
		 * 
		 * @return	The distance in tile units from the player to the point.
		 */
		public function projectPointToScreen(SourceX:Number, SourceY:Number, SourceZ:Number, DestinationPoint:FlxPoint, GameEntity:Entity = null):Number
		{
			var planeX:Number = player.magView * player.view.x;
			var planeY:Number = player.magView * player.view.y;
			var invDet:Number = 1.0 / (planeX * player.dir.y - player.dir.x * planeY);
			
			var _x:Number = SourceX - player.pos.x;
			var _y:Number = SourceY - player.pos.y;
			
			var transformX:Number = invDet * (player.dir.y * _x - player.dir.x * _y);
			var transformY:Number = invDet * (-planeY * _x + planeX * _y); 
			var _height:Number = viewport.height / transformY;
			
			if (transformY > 0)
			{
				DestinationPoint.x = int((0.5 * viewport.width) * (1 + worldScale.x * (transformX / transformY)));
				
				//if we're projecting a singular point that is representing a game sprite, we need to adjust its scale
				if (GameEntity) GameEntity.scale.x = GameEntity.scale.y = Math.abs(_height);
				
				DestinationPoint.y = 0.5 * viewport.height;
				DestinationPoint.y -= (SourceZ / arcade.texFloorHeight - 0.5) * arcade.texFloorHeight * _height;
				
				return transformY / arcade.texFloorHeight;
			}
			else 
			{
				return -1;
			}
		}

	}
}