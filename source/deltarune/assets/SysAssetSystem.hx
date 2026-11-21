package deltarune.assets;

import haxe.io.Bytes;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class SysAssetSystem implements IAssetSystem
{
	public var label:String;
	public var root:String;

	public function new(label:String, ?root:String)
	{
		this.label = label;
		if (root == null)
		{
			#if sys
			#if (CITRO_ENGINE && IS_CIAbytes)
			this.root = 'romfs:/assets';
			#elseif android
			this.root = Sys.programPath();
			#else
			this.root = Sys.getCwd() + '/assets';
			#end
			#else
			this.root = '';
			#end
		}
		else
		{
			this.root = root;
		}
	}

	public function list(directory:String, subdirectory:Bool = false):Array<String>
	{
		#if sys
		var dirs:Array<String> = [];
		try
		{
			dirs = FileSystem.readDirectory('$root/$directory');
			var i:Int = 0;
			while (dirs.length > i)
			{
				if (FileSystem.isDirectory('$root/$directory/${dirs[i]}'))
				{
					if (subdirectory)
						dirs = dirs.concat(FileSystem.readDirectory('$root/$directory/${dirs[i]}'));
					dirs.splice(i, 1);
				}
				else
				{
					i++;
				}
			}
		}
		catch (e:Dynamic) {}
		return dirs;
		#else
		return [];
		#end
	}

	public function exists(file:String):Bool
	{
		#if sys
		return FileSystem.exists('${root}/${file}') && !FileSystem.isDirectory('${root}/${file}');
		#else
		return false;
		#end
	}

	public function directoryExists(directory:String):Bool
	{
		#if sys
		return FileSystem.isDirectory('${root}/${directory}');
		#else
		return false;
		#end
	}

	public function text(file:String):String
	{
		#if sys
		return File.getContent('${root}/${file}');
		#else
		return null;
		#end
	}

	public function bytes(file:String):Bytes
	{
		#if sys
		return File.getBytes('${root}/${file}');
		#else
		return null;
		#end
	}

	public function font(file:String):Dynamic
	{
		return file;
	}

	public function bitmap(image:String):Dynamic
	{
		return image;
	}

	public function sound(sound:String):Dynamic
	{
		return sound;
	}
}