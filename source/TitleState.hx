package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
#if desktop
import Main;
import hscript.Expr.Error;
import openfl.Assets;
import hscript.*;
#end

using StringTools;

class TitleState extends MusicBeatState {
	static var initialized:Bool = false;
	static public var soundExt:String = ".ogg";

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var script:HScript;

	override public function create():Void {
		FlxG.save.bind('Funkin Meep', 'meepers');

		polymodload();

		script = new HScript("assets/data/TitleState");
		if (!script.isBlank && script.expr != null) {
			script.interp.scriptObject = this;
			script.setValue("yooo", true);
			script.interp.execute(script.expr);
		}
		script.callFunction("create");

		options.SettingConfigs.loadsettings();
		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null) {
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic('assets/images/newgrounds_logo.png');
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		new FlxTimer().start(1, function(tmr:FlxTimer) {
			startIntro();
		});

		// credGroup.add(credTextShit);
	}

	function startIntro() {
		script.callFunction('startIntro');

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
	}

	function getIntroTextShit():Array<Array<String>> {
		var fullText:String = Assets.getText('assets/data/introText.txt');

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray) {
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F) {
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE && !transitioning && skippedIntro) {
			script.callFunction('pressedEnter');
			FlxG.camera.flash(0xFFffffff, 0.9);
			FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt, 0.7);
			transitioning = true;
			// FlxG.sound.music.stop();
			new FlxTimer().start(2, function(tmr:FlxTimer) {
				FlxG.switchState(new MainMenuState());
			});
			// FlxG.sound.play('assets/music/titleShoot' + TitleState.soundExt, 0.7);
		}
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE && !skippedIntro) {
			skipIntro();
		}
	}

	function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String) {
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText() {
		while (textGroup.members.length > 0) {
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit() {
		super.beatHit();

		script.callFunction('beatHit');

		FlxG.log.add(curBeat);

		switch (curBeat) {
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('newgrounds');
				ngSpr.visible = true;
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void {
		script.callFunction('skipIntro');
		if (!skippedIntro) {
			remove(ngSpr);
			remove(credGroup);
			skippedIntro = true;
			FlxG.camera.flash(0xffffff, 4);
		}
	}

	function polymodload() {
		#if desktop
		polymod.Polymod.init({
			modRoot: "mods",
			dirs: CoolUtil.coolStringFile(sys.io.File.getContent('./mods/modList.txt')),
			// errorCallback: (e) -> {trace(e.message);},
			frameworkParams: {
				assetLibraryPaths: [
					// All my homies hate libraries
					"songs" => "assets/songs",
					"images" => "assets/images",
					"data" => "assets/data",
					"fonts" => "assets/fonts",
					"sounds" => "assets/sounds",
					"music" => "assets/music",
				]
			}
		});
		#end
	}
}

class HScript {
	#if desktop
	public static final allowedExtensions:Array<String> = ["hx", "hscript", "hxs", "script"];
	public static var parser:Parser;
	public static var staticVars:Map<String, Dynamic> = new Map();

	public var interp:Interp;
	public var expr:Expr;

	var initialLine:Int = 0;
	#end

	public var isBlank:Bool;

	var blankVars:Map<String, Null<Dynamic>>;
	var path:String;

	#if desktop
	public function new(scriptPath:String) {
		path = scriptPath;
		if (!scriptPath.startsWith("assets/"))
			scriptPath = "assets/" + scriptPath;
		var boolArray:Array<Bool> = [for (ext in allowedExtensions) Assets.exists('$scriptPath.$ext')];
		isBlank = (!boolArray.contains(true));
		if (boolArray.contains(true)) {
			interp = new Interp();
			interp.staticVariables = staticVars;
			interp.allowStaticVariables = true;
			interp.allowPublicVariables = true;
			interp.errorHandler = traceError;
			try {
				var path = scriptPath + "." + allowedExtensions[boolArray.indexOf(true)];
				parser.line = 1; // Reset the parser position.
				expr = parser.parseString(Assets.getText(path));
				interp.variables.set("trace", hscriptTrace);
			} catch (e) {
				lime.app.Application.current.window.alert('Looks like the game couldn\'t parse your hscript file.\n$scriptPath\n${e.toString()}\n\nThe game will replace this\nscript with a blank script.',
					'Failed to Parse $scriptPath');
				isBlank = true;
			}
		}
		if (isBlank) {
			blankVars = new Map();
		} else {
			var defaultVars:Map<String, Dynamic> = [
				"Math" => Math,
				"Std" => Std,

				"FlxG" => flixel.FlxG,
				"FlxSprite" => flixel.FlxSprite,
				// Abstract Imports
				"FlxColor" => Type.resolveClass("flixel.util._FlxColor.FlxColor_Impl_"),
				"FlxTrail" => flixel.addons.effects.FlxTrail,
				"FlxBackdrop" => flixel.addons.display.FlxBackdrop,

				"Conductor" => Conductor,
				"PlayState" => PlayState,

				"GraphicTransTileDiamond" => flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond,
				"TransitionData" => flixel.addons.transition.TransitionData,
				"FlxTransitionableState" => flixel.addons.transition.FlxTransitionableState,

				"Assets" => Assets
			];
			for (va in defaultVars.keys())
				setValue(va, defaultVars[va]);
		}
	}

	function hscriptTrace(v:Dynamic)
		trace(v);

	function traceError(e:Error) {
		Application.current.window.alert('$e', 'meep engine error handler');
	}

	public function callFunction(name:String, ?params:Array<Dynamic>) {
		var functionVar = (isBlank) ? blankVars.get(name) : interp.variables.get(name);
		var hasParams = (params != null && params.length > 0);
		if (functionVar == null || !Reflect.isFunction(functionVar))
			return null;
		return hasParams ? Reflect.callMethod(null, functionVar, params) : functionVar();
	}

	public function getValue(name:String)
		return (isBlank) ? blankVars.get(name) : interp.variables.get(name);

	public function setValue(name:String, value:Dynamic)
		if (isBlank)
			blankVars.set(name, value)
		else
			interp.variables.set(name, value);
	#else
	public var interp:Null<Dynamic> = null;
	public var expr:Null<Dynamic> = null;

	public function new(scriptPath:String) {
		blankVars = new Map();
		isBlank = true;
	}

	public function callFunction(name:String, ?params:Array<Dynamic>) {
		var functionVar = blankVars.get(name);
		var hasParams = (params != null && params.length > 0);
		if (functionVar == null || !Reflect.isFunction(functionVar))
			return null;
		return hasParams ? Reflect.callMethod(null, functionVar, params) : functionVar();
	}

	public function getValue(name:String)
		return blankVars.get(name);

	public function setValue(name:String, value:Dynamic)
		blankVars.set(name, value);
	#end
}
