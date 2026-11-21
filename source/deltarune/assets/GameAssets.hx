package deltarune.assets;

import haxe.io.Bytes;

class GameAssets
{
	public static var assetSystems:Array<IAssetSystem> = [];

	public static final supportedAudio:Array<String> = ["cwav"];
	public static final supportedImage:Array<String> = ["t3x"];

	public static inline var MUSIC_EXT:String = "cwav";

	public static function text(file:String):String
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(file))
				return assetSystem.text(file);
		return null;
	}

	public static function sound(audio:String):Dynamic
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(audio))
				return assetSystem.sound(audio);
		return null;
	}

	public static function music(audio:String):Dynamic
	{
		var path = '$audio.$MUSIC_EXT';
		for (assetSystem in assetSystems)
			if (assetSystem.exists(path))
				return assetSystem.sound(path);
		return null;
	}

	public static function bytes(file:String):Bytes
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(file))
				return assetSystem.bytes(file);
		return null;
	}

	public static function exists(file:String):Bool
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(file))
				return true;
		return false;
	}

	public static function directoryExists(folder:String):Bool
	{
		for (assetSystem in assetSystems)
			if (assetSystem.directoryExists(folder))
				return true;
		return false;
	}

	public static function list(folder:String, recursive:Bool = false):Array<String>
	{
		var files:Array<String> = [];
		for (assetSystem in assetSystems)
		{
			var assetSysFiles = assetSystem.list(folder, recursive);
			for (file in assetSysFiles)
			{
				if (!files.contains(file))
					files.push(file);
			}
		}
		return files;
	}

	public static function getJSON(file:String):Dynamic
	{
	    var content = text(file);
	    if (content == null) return null;
	    try {
	        return haxe.Json.parse(content);
	    } catch (e:Dynamic) {
	        trace('Failed to parse JSON: $file - $e');
	        return null;
	    }
	}
}
