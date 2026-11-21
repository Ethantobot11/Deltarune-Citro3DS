package deltarune;

import deltarune.tools.LocalSave;
import deltarune.game.states.substates.Options;

class Game
{
	public static var consoleArguments:Array<String>;
	public static var enviromentVariables:Map<String, String>;
	public static var developerMode(default, set):Bool = false;
	public static var initialized:Bool = false;

	public static var globalSave:Dynamic;
	public static var chapterSave:Dynamic;
	public static var chapter:Dynamic;
	public static var framerateDisplay:Dynamic;
	public static var border:Dynamic;

	public static function initialize():Void
	{
		if (initialized)
			return;

		if (Game.border != null) {
			Game.border.switchTo();
		}

		globalSave = new LocalSave();
		globalSave.bind('_default', 'savedata/global');

		chapterSave = new LocalSave();
		chapterSave.bind('placeholder_save', 'savedata');

		Options.initialize();

		initialized = true;
	}

	public static inline function nullSwitch<T>(a:T, b:T):T
	{
		return a != null ? a : b;
	}

	public static function set_developerMode(value:Bool):Bool
	{
		return developerMode = value;
	}
}
