package deltarune.tools;

import haxe.Json;
import haxe3ds.services.FS;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class LocalSave
{
	public var data:Dynamic = {};

	private var filePath:String = null;

	private static var mounted:Bool = false;

	static function ensureMount():Void
	{
		if (mounted)
			return;
		mounted = true;
		FS.mountSaveData("sdmc", 32, 8);
	}

	public function new()
	{
		ensureMount();
	}

	public function bind(name:String, ?path:String):Bool
	{
		ensureMount();
		if (name == null || name == "")
			return false;

		var dir = 'sdmc:/Deltarune-Citro3DS/' + (path != null ? path.replace('\\', '/').trim() : '');
		if (dir.length > 0 && !dir.endsWith('/'))
			dir += '/';
		if (!FileSystem.exists(dir))
		{
			try
				FileSystem.createDirectory(dir)
			catch (e:Dynamic) {}
		}

		filePath = dir + name.replace('/', '#') + '.json';

		if (FileSystem.exists(filePath))
		{
			try
			{
				var content = File.getContent(filePath);
				content = sanitizeSaveJson(content);
				data = (content != null && content.length > 0) ? Json.parse(content) : {};
			}
			catch (e:Dynamic)
			{
				trace('LocalSave: corrupt save reset (file was truncated or invalid): $filePath');
				data = {};
			}
		}
		else
		{
			data = {};
		}
		return true;
	}

	public function flush():Bool
	{
		if (filePath == null)
			return false;
		try
		{
			File.saveContent(filePath, Json.stringify(data));
			FS.flushAndCommit();
			return true;
		}
		catch (e:Dynamic)
		{
			trace('LocalSave flush failed: $e');
			return false;
		}
	}

	public function erase():Void
	{
		if (filePath != null && FileSystem.exists(filePath))
		{
			try
				FileSystem.deleteFile(filePath)
			catch (e:Dynamic) {}
			FS.flushAndCommit();
		}
		data = {};
	}

	static function sanitizeSaveJson(raw:String):String
	{
		if (raw == null || raw.length == 0)
			return "";
		if (raw.length >= 3 && raw.charCodeAt(0) == 0xEF && raw.charCodeAt(1) == 0xBB && raw.charCodeAt(2) == 0xBF)
		{
			raw = raw.substr(3);
		}
		else if (raw.length >= 2 && raw.charCodeAt(0) == 0xFF && raw.charCodeAt(1) == 0xFE)
		{
			raw = raw.substr(2);
		}
		else if (raw.length > 0 && (raw.charCodeAt(0) == 0xFEFF || raw.charCodeAt(0) == 0xFFFE))
		{
			raw = raw.substr(1);
		}
		var buf = new StringBuf();
		for (i in 0...raw.length)
		{
			var c = raw.charCodeAt(i);
			if (c == 9 || c == 10 || c == 13)
			{
				buf.addChar(c);
				continue;
			}
			if (c == 0 || c == 65533 || c == 0xFFFE)
				continue;
			if (c >= 32)
				buf.addChar(c);
		}
		return buf.toString();
	}
}