package;

import lime.app.Application;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		#if desktop
            TitleState.HScript.parser = new hscript.Parser();
            TitleState.HScript.parser.allowJSON = true;
            TitleState.HScript.parser.allowMetadata = true;
            TitleState.HScript.parser.allowTypes = true;
            TitleState.HScript.parser.preprocesorValues = [
                "buildVer" => Application.current.meta.get('version'),
                "desktop" => #if (desktop) true #else false #end,
                "windows" => #if (windows) true #else false #end,
                "mac" => #if (mac) true #else false #end,
                "linux" => #if (linux) true #else false #end,
                "debugBuild" => #if (debug) true #else false #end
            ];
            #end
			
		addChild(new FlxGame(0, 0, TitleState));

		addChild(new FPS(10, 3, 0xFFFFFF));
	}
}
