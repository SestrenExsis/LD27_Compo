package
{
	import org.flixel.FlxGame;
	[SWF(width="640", height="480", backgroundColor="#888888")]
	
	public class LD27_Compo extends FlxGame
	{
		public function LD27_Compo()
		{
			super(640, 480, MenuScreen, 1.0, 60, 60, true);
			forceDebugger = true;
		}
	}
}