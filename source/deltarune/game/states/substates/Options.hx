package deltarune.game.states.substates;

import citro.CitroG;
import citro.state.CitroSubState;
import citro.object.CitroText;
import citro.object.CitroSprite;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;
import citro.backend.CitroTween.CitroEase;
import citro.backend.CitroColor;
import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import deltarune.game.states.MenuState;
import deltarune.game.MenuBackground;
import deltarune.tools.LocalSave;
import deltarune.Game;
import deltarune.Controls;

class Options extends CitroSubState
{
	var returning:Bool;
	var entering:Bool;

	public static var generalData:Dynamic = {
		fps: 30,
		show_fps: true,
		show_memory: true,
		auto_run: false,
		music_volume: 1.0,
		sound_volume: 1.0,
		show_border: true,
		border_style: "cyber",
		display_screen: "top",
		display_pos: "top-right"
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

	private static function defaultGeneral():Dynamic
		return {
			fps: 30,
			show_fps: true,
			show_memory: true,
			auto_run: false,
			music_volume: 1.0,
			sound_volume: 1.0,
			show_border: true,
			border_style: "cyber",
			display_screen: "top",
			display_pos: "top-right"
		};

	public static var save_destination:String;
	public static var save_id:Int;

	public static function initialize()
	{
		if (Game.globalSave != null && Game.globalSave.data.general != null)
		{
			var merged:Dynamic = {};
			for (f in Reflect.fields(defaultGeneral()))
				Reflect.setField(merged, f, Reflect.field(defaultGeneral(), f));
			for (f in Reflect.fields(Game.globalSave.data.general))
				Reflect.setField(merged, f, Reflect.field(Game.globalSave.data.general, f));
			generalData = merged;
			Game.globalSave.data.general = generalData;
		}
		else if (Game.globalSave != null)
		{
			generalData = defaultGeneral();
			Game.globalSave.data.general = generalData;
			Game.globalSave.flush();
		}
		CitroG.targetFps = (generalData.fps is Int) ? generalData.fps : 60;

		if (Game.chapterSave != null && Game.chapterSave.data.general == null)
			Game.chapterSave.data.general = defaultData;
		if (Game.chapterSave != null)
			currentData = Game.chapterSave.data.general;

		applyDisplaySettings();
	}

	public static function applyDisplaySettings()
	{
		if (Game.framerateDisplay != null)
		{
			Game.framerateDisplay.visible = (generalData.show_fps == true);
			positionOnScreen(Game.framerateDisplay, generalData.display_screen, generalData.display_pos, 0);
		}
		var mem:Dynamic = Reflect.field(Game, "memoryDisplay");
		if (mem != null && Reflect.hasField(mem, "visible"))
		{
			mem.visible = (generalData.show_memory == true);
			positionOnScreen(mem, generalData.display_screen, generalData.display_pos, 16);
		}
	}

	static function positionOnScreen(t:CitroText, screen:String, pos:String, ?extraY:Float = 0)
	{
		var isBottom = (screen == "bottom");
		t.bottom = isBottom;
		var W = isBottom ? CitroG.BOTTOM_WIDTH : CitroG.WIDTH;
		var H = CitroG.HEIGHT;
		var margin = 4;

		switch (pos)
		{
			case "top-left":
				t.x = margin;
				t.y = margin + extraY;
				t.alignment = LEFT;
			case "top-right":
				t.x = W - margin;
				t.y = margin + extraY;
				t.alignment = RIGHT;
			case "bottom-left":
				t.x = margin;
				t.y = H - 22 + extraY;
				t.alignment = LEFT;
			case "bottom-right":
				t.x = W - margin;
				t.y = H - 22 + extraY;
				t.alignment = RIGHT;
			default:
				t.x = W - margin;
				t.y = margin + extraY;
				t.alignment = RIGHT;
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
		if (field == "show_fps" || field == "show_memory" || field == "display_screen" || field == "display_pos")
			applyDisplaySettings();

		if (field == "show_border" || field == "border_style")
			applyBorderSettings();
	}

	public static function applyBorderSettings()
	{
		if (Game.border == null)
			return;
		Game.border.visible = (generalData.show_border == true);
		if (generalData.show_border == true)
			Game.border.switchTo(Std.string(generalData.border_style));
	}

	var options:Array<Option> = [];

	static var index:Int = 0;

	override public function create()
	{
		super.create();

		CitroG.sound.playMusic(Paths.getMusic('Before the Story'), 0.8, true);

		var bg = new MenuBackground();
		add(bg);

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

		var panel = new CitroSprite(0, 0);
		panel.bottom = true;
		panel.makeGraphic(CitroG.BOTTOM_WIDTH, CitroG.HEIGHT, 0xE6000000);
		add(panel);

		var maxFpsOption = new Option(options.length, 'FPS', generalData.fps, 'fps', 'int', {
			change: 5,
			min: 30,
			max: 60,
			change_func: function(value, change)
			{
				Options.setGeneralData('fps', value);
				CitroG.targetFps = (value is Int) ? value : 60;
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

		var borderOnOption = new Option(options.length, 'Show Border', generalData.show_border, 'show_border', 'bool', {current: false});
		options.push(borderOnOption);
		add(borderOnOption);

		var borderStyleOption = new Option(options.length, 'Border Style', generalData.border_style, 'border_style', 'enum', {
			choices: ["simple", "hometown", "castle_town"],
			current: false
		});
		options.push(borderStyleOption);
		add(borderStyleOption);

		var screenOption = new Option(options.length, 'Display Screen', generalData.display_screen, 'display_screen', 'enum', {
			choices: ["top", "bottom"],
			current: false
		});
		options.push(screenOption);
		add(screenOption);

		var posOption = new Option(options.length, 'Display Position', generalData.display_pos, 'display_pos', 'enum', {
			choices: ["top-left", "top-right", "bottom-left", "bottom-right"],
			current: false
		});
		options.push(posOption);
		add(posOption);

		var autoRunOption = new Option(options.length, 'Auto Run', generalData.auto_run, 'auto_run', 'bool', {current: false});
		options.push(autoRunOption);
		add(autoRunOption);

		var musicVolOption = new Option(options.length, 'Music Volume', generalData.music_volume, 'music_volume', 'float', {
			change: 0.1,
			min: 0.0,
			max: 1.0,
			change_func: function(value, change)
			{
				Options.setGeneralData('music_volume', value);
				CitroG.sound.setMusicVolume(value);
			},
			current: false
		});
		options.push(musicVolOption);
		add(musicVolOption);

		var soundVolOption = new Option(options.length, 'Sound Volume', generalData.sound_volume, 'sound_volume', 'float', {
			change: 0.1,
			min: 0.0,
			max: 1.0,
			change_func: function(value, change)
			{
				Options.setGeneralData('sound_volume', value);
				CitroG.sound.setSoundVolume(value);
			},
			current: false
		});
		options.push(soundVolOption);
		add(soundVolOption);

		changeIndex();
		updateOptionLayout();
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
			if (opt.optIndex == index)
			{
				opt.alpha = 1.0;
			}
		}
	}

	var scrollOffset:Int = 0;
	static inline var VISIBLE_ROWS:Int = 8;
	static inline var ROW_HEIGHT:Int = 26;

	function updateOptionLayout()
	{
		for (i in 0...options.length)
		{
			var row = i - scrollOffset;
			options[i].y = 14 + (row * ROW_HEIGHT);
			options[i].visible = (row >= 0 && row < VISIBLE_ROWS);
		}
	}

	function changeIndex(chng:Int = 0)
	{
		index += chng;
		if (index < 0)
			index = options.length - 1;
		if (index >= options.length)
			index = 0;
		if (index < scrollOffset)
			scrollOffset = index;
		if (index > scrollOffset + VISIBLE_ROWS - 1)
			scrollOffset = index - (VISIBLE_ROWS - 1);

		updateOptionLayout();
	}
}

class Option extends CitroText
{
	public var optIndex:Int;
	public var optLabel:String;
	public var value:Dynamic;

	var field:String;
	var type:String;
	var properties:OptionConfig;

	public function new(idx:Int, text:String, value:Dynamic, field:String, type:String, ?properties:OptionConfig)
	{
		super(6, 0, text);
		bottom = true;
		loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		alignment = LEFT;
		this.properties = properties;
		this.optIndex = idx;
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
			case 'int':
				text = '< ' + value + ' > - ' + optLabel;
			case 'float':
				var v:Float = Std.isOfType(value, Float) ? cast value : Std.parseFloat(Std.string(value));
				text = '< ' + Std.string(Std.int(v * 10) / 10) + ' > - ' + optLabel;
			case 'bool':
				text = '< ' + (value ? 'Yes' : 'No') + ' > - ' + optLabel;
			case 'enum':
				text = '< ' + value + ' > - ' + optLabel;
			default:
				text = optLabel;
		}
	}

	public function select()
	{
		switch (type)
		{
			case 'int', 'float', 'enum':
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
				if (value == null)
					value = 0.0;
				var v:Float = Std.isOfType(value, Float) ? cast value : Std.parseFloat(Std.string(value));
				v += change * properties.change;
				if (v < properties.min)
					v = properties.min;
				if (v > properties.max)
					v = properties.max;
				value = Math.round(v * 100) / 100;
				if (!properties.current)
					Options.setGeneralData(field, value);
			case 'enum':
				var choices:Array<String> = properties.choices != null ? properties.choices : [];
				if (choices.length == 0) return;
				var cur = choices.indexOf(Std.string(value));
				if (cur < 0)
					cur = 0;
				cur += change;
				if (cur < 0)
					cur = choices.length - 1;
				if (cur >= choices.length)
					cur = 0;
				value = choices[cur];
				if (!properties.current)
					Options.setGeneralData(field, value);
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
	var ?choices:Array<String>;
}

enum NoSuccess
{
	GenericFailure;
	NoSaveData;
	NoData;
}