package deltarune.assets;

import openfl.display.BitmapData;

using StringTools;

#if sys
import sys.io.File;
#end

class Paths
{
	public static var currentMusic:String = null;

	public static inline function getCharacterImage(char:String):String
		return 'romfs:/assets/images/characters/$char/spritesheet.t3x';

	public static inline function getFont(font:String):String
		return 'romfs:/assets/fonts/$font.bcfnt';

	public static inline function getImage(image:String, format:String = 't3x'):String
		return 'romfs:/assets/images/$image.$format';

	public static inline function getDialogue(file:String):String
		return 'romfs:/assets/data/dialogue/$file.json';

	public static inline function getMusic(file:String):String
	{
		currentMusic = file;
		return 'romfs:/assets/music/$file.cwav';
	}

	public static inline function getSound(file:String):String
			return 'romfs:/assets/sounds/$file.cwav';
	}

	//why does this exist?
	public static inline function getPortrait(character:String)
		return 'romfs:/assets/images/dialogue/$character.t3x';

	public static function getBitmapSys(image:String)
	{
		if (GameAssets.exists('/images/$image.t3x'))
			return GameAssets.bitmap('/images/' + image + '.t3x');
		return null;
	}

	public static function getJSON(file:String, folder:String = 'data', ext:String = 'json'):Dynamic
	{
		var coolContent = '{"vthrow":"Error occured while loading JSON"}';
		var json = {vthrow: "Failed to parse JSON"};
		if (GameAssets.exists('$folder/$file.$ext'))
			coolContent = GameAssets.text('$folder/$file.$ext');
		try
		{
			json = haxe.Json.parse(coolContent);
		}
		catch (e)
		{
			trace('failed to parse JSON');
			trace('throw error:' + e.message);
			return null;
		}
		return json;
	}

	//note: this will be removed along with all things relating to the ogmo editor
	/**
	 * [Description]
	 * @param ogmopath the path according to ogmo editor eg: ../images/cyberassetsmini.png to C:/gamedir/assets/images/cyberassetsmini.png
	 * @return a String of the path
	 */
	public static function getOgmoBitmap(path:String, fileLocation:String)
	{
		var fixedPath = Sys.getCwd() + path.replace('../', '/assets/');
		if (GameAssets.exists(fixedPath))
		{
			return GameAssets.bitmap(fixedPath);
		}
		return null;
	}

	//why does this exist?
	public static function getTextSound(character:String = 'default')
	{
		var fixedPath = 'sounds/text_' + character.split('-')[0] + '.cwav';
		if (!GameAssets.exists(fixedPath))
			fixedPath = 'sounds/text_default.cwav';
		return fixedPath;
	}
}
