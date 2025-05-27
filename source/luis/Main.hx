package luis;

import luis.back.Handler;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		Handler.init();
		addChild(new FlxGame(1280, 720, ImageBatchProcessorUI, #if (flixel < "5.0.0") 1, #end 60, 60, true, false));
	}
}
