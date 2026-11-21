package deltarune.game;

import citro.object.CitroGroup;
import citro.object.CitroSprite;
import citro.CitroG;

class Writer extends CitroGroup
{
	public var awaitingEvent:Bool = false;
	public var lineIndex:Int = 0;
	public var instructionIndex:Int = 0;
	public var canSkip:Bool = true;
	public var autoContinue:Bool = false;
	public var fullOffsetType:WritingOffset = NONE;
	public var typingOffsetType:WritingOffset = NONE;

	public var instructions:Array<WriterInstruction> = [];
	public var usedCharacters:CitroGroup;
	public var heldCharacters:CitroGroup;
	public var writtenText(default, null):String = "";

	public var currentInstruction(get, never):WriterInstruction;

	function get_currentInstruction():WriterInstruction
	{
		return if (instructionIndex >= instructions.length || instructionIndex < 0) null else instructions[instructionIndex];
	}

	public var instructionTime(get, set):Float;

	function get_instructionTime():Float
	{
		return currentInstruction != null ? currentInstruction.time : -1.0;
	}

	function set_instructionTime(time:Float):Float
	{
		if (currentInstruction != null)
			currentInstruction.time = time;
		return -1.0;
	}

	public var instructionProgress(get, set):Float;

	function get_instructionProgress():Float
	{
		return currentInstruction != null ? currentInstruction.progress : -1.0;
	}

	function set_instructionProgress(progress:Float):Float
	{
		if (currentInstruction != null)
			currentInstruction.progress = progress;
		return -1.0;
	}

	public function new(X:Float, Y:Float)
	{
		super();
		this.x = X;
		this.y = Y;
		usedCharacters = new CitroGroup();
		heldCharacters = new CitroGroup();
	}

	override public function update():Bool
	{
		if (currentInstruction != null)
			currentInstruction.update(CitroG.deltaTime / 1000.0);
		return super.update();
	}

	public function addText(text:String, silent:Bool = false)
	{
		for (i in 0...text.length)
		{
			var character:Character = null;
			for (m in heldCharacters.members)
			{
				if (m.exists)
				{
					character = cast m;
					break;
				}
			}
			if (character == null)
			{
				character = new Character();
				usedCharacters.add(character);
				add(character);
			}
			else
			{
				heldCharacters.remove(character);
				usedCharacters.add(character);
				add(character);
			}
			character.setChar(text.charAt(i));
		}
	}

	public function setText(text:String, silent:Bool = false)
	{
		writtenText = text;
	}

	public function clearText()
	{
		for (char in usedCharacters.members)
		{
			if (char.exists)
			{
				remove(char);
				usedCharacters.remove(char);
				heldCharacters.add(char);
			}
		}
	}

	public function setFont(font:String) {}

	public function tryContinue():Bool
	{
		return true;
	}

	public function trySkip():Bool
	{
		return !canSkip;
	}
}

class WriterInstruction
{
	public var data:Dynamic;
	public var instructionData:Map<String, Dynamic> = new Map();
	public var type:String;
	public var time:Float = 0;
	public var progress:Float = -1;
	public var writer:Writer;
	public var dialog:Dynamic;
	public var canSkip:Bool;
	public var skipOver:Bool;
	public var autoContinue:Bool;

	public function new(data:Dynamic)
	{
		this.data = data;
		type = data.type;
		switch (type.toLowerCase())
		{
			case "write":
				canSkip = skipOver = data.skippable != null ? data.skippable : true;
				skipOver = data.skipsOver != null ? data.skipsOver : skipOver;
				autoContinue = data.autoContinue != null ? data.autoContinue : false;
			case "rewrite":
				autoContinue = data.autoContinue != null ? data.autoContinue : true;
			case "color", "effect", "portrait", "sound", "style", "font", "sprchar":
				canSkip = skipOver = true;
				autoContinue = true;
			case "erase":
				canSkip = skipOver = data.skippable != null ? data.skippable : true;
				skipOver = data.skipsOver != null ? data.skipsOver : skipOver;
				autoContinue = data.autoContinue != null ? data.autoContinue : false;
			case "pause":
				canSkip = skipOver = data.skippable != null ? data.skippable : false;
				skipOver = data.skipsOver != null ? data.skipsOver : skipOver;
				autoContinue = data.autoContinue != null ? data.autoContinue : true;
			case "event":
				canSkip = skipOver = false;
				autoContinue = true;
			case "move", "minidialog":
		}
	}

	public function update(elapsed:Float)
	{
		switch (type.toLowerCase())
		{
			case "write":
				time += elapsed;
		}
	}

	public function trySkip(skippingOver:Bool):Bool
	{
		return canSkip;
	}
}

class Character extends CitroSprite
{
	public var char:String = "";
	public var isImage:Bool = false;

	public function setChar(char:String)
	{
		this.char = char;
		if (char == "" || char.trim() == "")
			visible = false;
		else
		{
			visible = true;}
	}
}

enum WritingOffset
{
	NONE;
	WAVE;
	SHAKE;
}