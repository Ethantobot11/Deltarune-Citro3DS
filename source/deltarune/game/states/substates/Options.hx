package deltarune.game.states.substates;

import citro.CitroG;
import citro.state.CitroSubState;
import citro.object.CitroText;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;
import citro.backend.CitroTween.CitroEase;
import citro.backend.CitroColor;
import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import deltarune.game.states.MenuState;
import deltarune.tools.LocalSave;
import deltarune.Game;
import deltarune.Controls;

class Options extends CitroSubState
{
	var returning:Bool;
	var entering:Bool;

	public static var generalData:Dynamic = {
		fps: 30,
		show_fps: false,
		show_memory: false,
		auto_run: false,
		music_volume: 1.0,
		sound_volume: 1.0
	};

	public static var currentData:Dynamic = {
		play_time: 0.0,
		name: 'None',
		vessel_name: 'None',
		room_name: "001",
		room_x: 0,
		room_y: 0
	};

	public static var defaultData(default, never):Dynamic = {
		play_time: 0.0,
		name: 'EMPTY',
		vessel_name: 'Vessel',
		room_name: "001",
		room_x: 0,
		room_y: 0
	};

	public static var save_destination:String;
	public static var save_id:Int;

	public static function initialize()
	{
		if (Game.globalSave != null && Game.globalSave.data.general != null)
		{
			generalData = Game.globalSave.data.general;
		}
		else if (Game.globalSave != null)
		{
			Game.globalSave.data.general = generalData;
			Game.globalSave.flush();
		}

		if (Game.chapterSave != null && Game.chapterSave.data.general == null)
		{
			Game.chapterSave.data.general = defaultData;
		}

		if (Game.chapterSave != null)
		{
			currentData = Game.chapterSave.data.general;
		}
	}

	public static function loadNewSave(target_save_destination:String = null, target_save_id:Int = null)
	{
		if (Game.chapterSave != null)
		{
			Game.chapterSave.bind('${Game.nullSwitch(target_save_destination, save_destination)}_${Game.nullSwitch(target_save_id, save_id)}', 'savedata');
			if (Game.chapterSave.data.general == null)
			{
				Game.chapterSave.data.general = defaultData;
			}
			currentData = Game.chapterSave.data.general;
		}
	}

	public static function saveCurrentSave()
	{
		if (Game.chapterSave != null)
		{
			Game.chapterSave.bind('${save_destination}_${save_id}', 'savedata');
			Game.chapterSave.data.general = currentData;
			Game.chapterSave.flush();
		}
	}

	public static function grabSaveData(data:String, target_save_destination:String = null, target_save_id:Int = null):Dynamic
	{
		var temp_save = new LocalSave();
		temp_save.bind('${Game.nullSwitch(target_save_destination, save_destination)}_${Game.nullSwitch(target_save_id, save_id)}');

		if (temp_save.data == null || !Reflect.hasField(temp_save.data, "general") || Reflect.field(temp_save.data, "general") == null)
			return NoSuccess.NoSaveData;

		var general = Reflect.field(temp_save.data, "general");
		if (!Reflect.hasField(general, data))
			return NoSuccess.NoData;

		return Reflect.field(general, data);
	}

	public static function plopDataIntoSave(data:Dynamic, field:String)
	{
		if (Game.chapterSave != null)
		{
			if (Game.chapterSave.data.general == null)
				Game.chapterSave.data.general = {};
			Reflect.setField(Game.chapterSave.data.general, field, data);
			Game.chapterSave.flush();
		}
		return data;
	}

	public static function selectSaveDestination(target_destination:String, target_id:Int)
	{
		save_destination = target_destination;
		save_id = target_id;
	}

	public static function saveToOtherSave(revert:Bool = false, target_destination:String, save_id:Int)
	{
		var prevSaveDest = save_destination;
		var prevSaveId = save_id;

		selectSaveDestination(save_destination, save_id);
		saveCurrentSave();

		if (revert)
			selectSaveDestination(prevSaveDest, prevSaveId);
	}

	public static function copySaveToSave(copyFrom:LocalSave, copyTo:LocalSave):Bool
	{
		try
		{
			var fields:Array<String> = Reflect.fields(copyFrom.data);
			copyTo.erase();
			for (field in fields)
			{
				Reflect.setField(copyTo.data, field, Reflect.field(copyFrom.data, field));
			}
			copyTo.flush();
			return true;
		}
		catch (e)
		{
			trace('failed to copy save data, cloned data may be corrupt or empty');
			return false;
		}
	}

	public static function setGeneralData(field:String, value:Dynamic, ?flush:Bool = true)
	{
		trace('setting $field to $value');
		Reflect.setField(generalData, field, value);
		if (Reflect.field(generalData, field) == value)
		{
			trace('success!');
		}
		if (Game.globalSave != null)
		{
			Game.globalSave.data.general = generalData;
			if (flush)
				Game.globalSave.flush();
		}
	}

	var options:Array<Option> = [];

	static var index:Int = 0;

	override public function create()
	{
		super.create();

		returning = false;
		entering = true;

		if (MenuState.instance != null)
		{
			if (MenuState.instance.playButton != null)
				CitroTween.tween(MenuState.instance.playButton, {alpha: 0}, 0.5);
			if (MenuState.instance.credsButton != null)
				CitroTween.tween(MenuState.instance.credsButton, {alpha: 0}, 0.5);
			if (MenuState.instance.optButton != null)
				CitroTween.tween(MenuState.instance.optButton, {alpha: 0}, 0.5);
		}

		CitroTimer.start(0.5, postCreate);

		var maxFpsOption = new Option(options.length, 'FPS', generalData.fps, 'fps', 'int', {
			change: 5,
			min: 30,
			max: 60,
			change_func: function(value, change)
			{
				Options.setGeneralData('fps', value);
				//CitroG.setFPS(value);
			},
			current: false
		});
		options.push(maxFpsOption);
		add(maxFpsOption);

		var showFramerateOption = new Option(options.length, 'Show Fps?', generalData.show_fps, 'show_fps', 'bool', {current: false});
		options.push(showFramerateOption);
		add(showFramerateOption);

		var showMemOption = new Option(options.length, 'Show Memory?', generalData.show_memory, 'show_memory', 'bool', {current: false});
		options.push(showMemOption);
		add(showMemOption);

		bgColor = 0x00000000;
		changeIndex();
	}

	public function postCreate()
	{
		entering = false;
	}

	override public function update(delta:Int)
	{
		super.update(delta);
		final elapsed = delta / 1000.0;

		if (!returning && !entering)
		{
			if (Controls.back.justPressed)
			{
				returning = true;
				if (MenuState.instance != null)
				{
					MenuState.instance.exitCredits();
				}
				else
				{
					close();
				}
			}

			if (Controls.left.justPressed)
				options[index].change(-1);
			if (Controls.right.justPressed)
				options[index].change(1);

			if (Controls.up.justPressed)
				changeIndex(-1);
			if (Controls.down.justPressed)
				changeIndex(1);

			if (Controls.primary.justPressed)
				options[index].select();
		}

		for (opt in options)
		{
			opt.alpha = 0.75;
			if (opt.index == index)
			{
				opt.alpha = 1.0;
			}
		}
	}

	function changeIndex(chng:Int = 0)
	{
		index += chng;
		if (index < 0)
			index = options.length - 1;
		if (index >= options.length)
			index = 0;
	}
}

class Option extends CitroText
{
	public var index:Int;
	public var optLabel:String;
	public var value:Dynamic;

	var field:String;
	var type:String;
	var properties:OptionConfig;

	public function new(index:Int, text:String, value:Dynamic, field:String, type:String, ?properties:OptionConfig)
	{
		// Adapted for 3DS Top Screen (400px width)
		super((CitroG.WIDTH) - (160 + 10), (index * 30) + 20, text);
		loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");

		alignment = RIGHT;
		this.properties = properties;
		this.index = index;
		this.value = value;
		this.field = field;
		this.type = type;
		optLabel = text;
		updateText();
	}

	function updateText()
	{
		switch (type)
		{
			case 'int', 'float':
				text = '< ' + value + ' > - ' + optLabel;
			case 'bool':
				text = '< ' + (value ? 'Yes' : 'No') + ' > - ' + optLabel;
			default:
				text = optLabel;
		}
	}

	public function select()
	{
		switch (type)
		{
			case 'int', 'float':
				trace('cant select int/float directly, use left/right');
			case 'bool':
				value = !value;
				if (!properties.current)
				{
					Options.setGeneralData(field, value);
				}
			default:
				trace('invalid');
		}
		updateText();
	}

	public function change(change:Int)
	{
		switch (type)
		{
			case 'int':
				if (value == null || !(value is Int))
					value = 0;
				value += change * Std.int(properties.change);
				if (value < properties.min)
					value = Std.int(properties.min);
				if (value > properties.max)
					value = Std.int(properties.max);
				if (!properties.current)
					Options.setGeneralData(field, value);
			case 'float':
				trace('not complete');
			case 'bool':
				value = !value;
				if (!properties.current)
					Options.setGeneralData(field, value);
			default:
				trace('invalid');
		}
		if (properties.change_func != null)
		{
			properties.change_func(value, change);
		}
		updateText();
	}
}

typedef OptionConfig =
{
	var ?change:Float;
	var ?change_func:Dynamic->Int->Void;
	var ?min:Float;
	var ?max:Float;
	var ?current:Bool;
}

enum NoSuccess
{
	GenericFailure;
	NoSaveData;
	NoData;
}