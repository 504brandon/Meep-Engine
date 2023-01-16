package options;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;

class GameplayMenu extends MusicBeatState {
	var menuItems:Array<String> = ['Ghost Tapping', 'Opponent Play'];
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var songText:Alphabet;
	var curSelected:Int = 0;
	var optionText:FlxText;

	public static var gt:Bool = true;
	public static var op:Bool = false;

	override public function create() {
		menuItems.push(CoolUtil.coolStringFile('data/gameplayOptions').toString());

		var bg = new FlxSprite(0, 0, 'assets/images/menuDesat.png');
		bg.color = 0x424242;
		bg.screenCenter();
		add(bg);

		optionText = new FlxText(0, 674, 0, '');
		optionText.setFormat('assets/fonts/vcr.otf', 40, FlxColor.WHITE, null, OUTLINE, FlxColor.BLACK, false);
		optionText.scrollFactor.set();
		optionText.screenCenter(X);
		optionText.updateHitbox();
		add(optionText);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length) {
			songText = new Alphabet(0, (70 * i) + 4, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MainMenuState());

		var daSelected:String = menuItems[curSelected];

		switch (daSelected) {
			case 'Ghost Tapping':
				optionText.text = 'Ghost Tapping: $gt';

				if (accepted) {
					if (gt)
						gt = false;
					else
						gt = true;
				}
			case 'Opponent Play':

				optionText.text = 'Opponent Play: $op';
				if (accepted) {
					if (!op)
						op = true;
					else
						op = false;
				}
			default:
				optionText.text = 'nulloption';
                
				if (accepted) {
					trace('you got a null option');
				}
		}
		if (accepted) {
			SettingConfigs.savesettings();
		}
	}

	function changeSelection(change:Int = 0):Void {
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
