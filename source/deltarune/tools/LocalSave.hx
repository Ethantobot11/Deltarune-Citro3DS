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
		if (mounted) return;
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
		if (name == null || name == "") return false;

		var dir = 'sdmc:/Deltarune-Citro3DS/savedata/global/' + (path != null ? path.replace('\\', '/').trim() : '');
		if (dir.length > 0 && !dir.endsWith('/')) dir += '/';
		if (!FileSystem.exists(dir)) {
			try FileSystem.createDirectory(dir) catch (e:Dynamic) {}
		}

		filePath = dir + name.replace('/', '#') + '.json';

		if (FileSystem.exists(filePath)) {
			try {
				var content = File.getContent(filePath);
				data = (content != null && content.length > 0) ? Json.parse(content) : {};
			} catch (e:Dynamic) {
				trace('LocalSave: corrupt save reset: $filePath');
				data = {};
			}
		} else {
			data = {};
		}
		return true;
	}

	public function flush():Bool
	{
		if (filePath == null) return false;
		try {
			File.saveContent(filePath, Json.stringify(data));
			FS.flushAndCommit();
			return true;
		} catch (e:Dynamic) {
			trace('LocalSave flush failed: $e');
			return false;
		}
	}

	public function erase():Void
	{
		if (filePath != null && FileSystem.exists(filePath)) {
			try FileSystem.deleteFile(filePath) catch (e:Dynamic) {}
			FS.flushAndCommit();
		}
		data = {};
	}
}
