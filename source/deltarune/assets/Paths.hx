package deltarune.assets;

using StringTools;

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

	public static inline function getPortrait(character:String):String
		return 'romfs:/assets/images/dialogue/$character.t3x';

	public static function getBitmapSys(image:String):String
	{
		var path = 'romfs:/assets/images/$image.t3x';
		if (GameAssets.exists(path))
			return path;
		return null;
	}

	public static function getJSON(file:String, folder:String = 'data', ext:String = 'json'):Dynamic
	{
		var path = 'romfs:/assets/$folder/$file.$ext';
		if (GameAssets.exists(path))
		{
			try
			{
				return haxe.Json.parse(GameAssets.text(path));
			}
			catch (e:Dynamic)
			{
				trace('failed to parse JSON: $e');
				return null;
			}
		}
		trace('JSON file not found: $path');
		return null;
	}

	/**
	 * Converts an Ogmo editor relative path (e.g., "../images/cyberassetsmini.png") 
	 * to a 3DS romfs absolute path (e.g., "romfs:/assets/images/cyberassetsmini.t3x").
	 */
	public static function getOgmoBitmap(ogmoPath:String, fileLocation:String):String
	{
		var cleanPath = ogmoPath.replace('../', '').replace('./', '');
		if (cleanPath.endsWith('.png'))
		{
			cleanPath = cleanPath.substr(0, cleanPath.length - 4) + '.t3x';
		}

		var fixedPath = 'romfs:/assets/' + cleanPath;

		if (GameAssets.exists(fixedPath))
		{
			return fixedPath;
		}

		trace('Ogmo asset not found at: $fixedPath (original: $ogmoPath)');
		return fixedPath;
	}

	public static function getTextSound(character:String = 'default'):String
	{
		var fixedPath = 'romfs:/assets/sounds/text_' + character.split('-')[0] + '.cwav';
		if (!GameAssets.exists(fixedPath))
			fixedPath = 'romfs:/assets/sounds/text_default.cwav';
		return fixedPath;
	}
}