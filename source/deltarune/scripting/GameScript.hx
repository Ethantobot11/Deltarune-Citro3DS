package deltarune.scripting;

import haxe.Exception;
#if hscript
import hscript.*;
#end

class GameScript #if hscript extends Interp #end
{
	public static var extensions(default, null):Array<String> = [".hx", ".hxc", ".hxs", ".hscript", ".hxscript", ".haxescript"];

	public var compiled(default, null):Bool = false;
	public var canceled:Bool = false;

	#if hscript
	var parser:Parser;
	var expression:Expr;
	#end

	public function new()
	{
		#if hscript
		super();
		parser = new Parser();
		setVariable("cancelFunction", function()
		{
			canceled = true;
		});
		#end
	}

	public function loadFile(path:String):Dynamic
	{
		#if hscript
		if (haxe.io.Path.extension(path) == '' && !fileExists(path))
		{
			for (ext in extensions)
				if (fileExists(path + ext))
					path += ext;
		}
		if (fileExists(path))
			return loadString(getContents(path));
		throw new Exception("Script File doesn't exist");
		#else
		return null;
		#end
	}

	public function loadString(str:String):Dynamic
	{
		#if hscript
		try
		{
			expression = parser.parseString(str);
			var toReturn:Dynamic = execute(expression);
			compiled = true;
			return toReturn;
		}
		catch (e)
		{
			trace('Failed to compile HScript: ${e.message}');
			return e;
		}
		#else
		return null;
		#end
	}

	public function callFunction(functionName:String, arguments:Array<Dynamic>):Dynamic
	{
		#if hscript
		canceled = false;
		var func:Dynamic = getVariable(functionName);
		try
		{
			if (func != null)
				return func(arguments);
		}
		catch (e)
		{
			trace('Error: ${e.message}');
		}
		return null;
		#else
		return null;
		#end
	}

	public function setVariable(field:String, value:Dynamic):Void
	{#if hscript setVar(field, value); #end
	}

	public function getVariable(field:String):Dynamic
	{#if hscript return variables.get(field); #else return null; #end
	}

	function fileExists(path:String):Bool
	{#if sys return sys.FileSystem.exists(Sys.getCwd() + '/' + path) || sys.FileSystem.exists('romfs:/' + path); #else return false; #end
	}

	function getContents(path:String):String
	{#if sys if (sys.FileSystem.exists('romfs:/' + path))
		return sys.io.File.getContent('romfs:/' + path);
		return sys.io.File.getContent(Sys.getCwd() + '/' + path); #else return ""; #end
	}
}