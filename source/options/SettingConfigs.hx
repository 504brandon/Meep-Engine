package options;

import flixel.FlxG;

class SettingConfigs{
public static function savesettings() {
    FlxG.save.data.gt = GameplayMenu.gt;
    FlxG.save.data.op = GameplayMenu.op;
    FlxG.save.flush();
}

public static function loadsettings() {
    if (FlxG.save.data.gt != null && FlxG.save.data.gt != GameplayMenu.gt)
        GameplayMenu.gt = FlxG.save.data.gt;

    if (FlxG.save.data.op != null && FlxG.save.data.op != GameplayMenu.op)
        GameplayMenu.op = FlxG.save.data.op;
    trace('settings loaded secsessfully');
}
}