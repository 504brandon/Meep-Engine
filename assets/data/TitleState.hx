import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxTimer;
import TitleState;

var logoBl:FlxSprite;
var gfDance:FlxSprite;
var danceLeft:Bool = false;
var titleText:FlxSprite;
var initialized:Bool = false;

function create() {
	var logo:FlxSprite = new FlxSprite().loadGraphic('assets/images/logo.png');
	logo.screenCenter();
	logo.antialiasing = true;
	// add(logo);

	logoBl = new FlxSprite(-150, -100);
	logoBl.frames = FlxAtlasFrames.fromSparrow('assets/images/logoBumpin.png', 'assets/images/logoBumpin.xml');
	logoBl.antialiasing = true;
	logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
	logoBl.animation.play('bump');
	logoBl.updateHitbox();
	// logoBl.screenCenter();
	// logoBl.color = FlxColor.BLACK;

	gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
	gfDance.frames = FlxAtlasFrames.fromSparrow('assets/images/gfDanceTitle.png', 'assets/images/gfDanceTitle.xml');
	gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
	gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
	gfDance.antialiasing = true;
	add(gfDance);
	add(logoBl);

	titleText = new FlxSprite(100, FlxG.height * 0.8);
	titleText.frames = FlxAtlasFrames.fromSparrow('assets/images/titleEnter.png', 'assets/images/titleEnter.xml');
	titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
	titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
	titleText.antialiasing = true;
	titleText.animation.play('idle');
	titleText.updateHitbox();
	// titleText.screenCenter(X);
	add(titleText);
}

function startIntro() {
	if (!initialized) {
		FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt, 0);

		FlxG.sound.music.fadeIn(4, 0, 0.7);
	}
}

function pressedEnter() {
	titleText.animation.play('press');
}

function beatHit() {
	logoBl.animation.play('bump');
	danceLeft = !danceLeft;

	if (danceLeft)
		gfDance.animation.play('danceRight');
	else
		gfDance.animation.play('danceLeft');
}
