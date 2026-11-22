package deltarune.game;

import citro.CitroG;
import citro.object.CitroGroup;
import citro.object.CitroSprite;
import citro.object.CitroTypeText;
import citro.editors.ogmo.CitroOgmo3Loader;
import deltarune.game.DialogueData;
import deltarune.Controls;

class LegacyDialogueBox extends CitroGroup
{
	public var activated(default, set):Bool;
	public var finishedCallback:Void->Void;
	public var dialogueProgressedCallback:Int->Void;

	private var background:CitroSprite;
	private var portrait:CitroSprite;
	private var typeText:CitroTypeText;

	public var niceDialogue:DialogueStructure;
	public var dialogueIndex:Int;

	private var linefinished:Bool;

	public function new(x:Float, y:Float, dialogueFile:Dynamic)
	{
		super();
		this.x = x;
		this.y = y;

		background = new CitroSprite(0, 0);
		background.loadGraphic('romfs:/assets/images/darkworldBox.t3x');
		background.scale.x = 2;
		background.scale.y = 2;
		add(background);

		portrait = new CitroSprite(0, 0);
		portrait.scale.x = 2;
		portrait.scale.y = 2;
		add(portrait);

		typeText = new CitroTypeText(52, 24, 200, "");
		typeText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		add(typeText);

		if (Std.isOfType(dialogueFile, String))
		{
			var path = Std.string(dialogueFile);
			#if sys
			if (!sys.FileSystem.exists(path))
			{
				trace("[LegacyDialogueBox] WARNING: dialogue file missing: " + path);
				niceDialogue = {style: "darkworld", dialogue: []};
			}
			else
			{
				var jsonStr = sys.io.File.getContent(path);
				jsonStr = CitroOgmo3Loader.sanitizeJson(jsonStr);
				try
				{
					niceDialogue = haxe.Json.parse(jsonStr);
				}
				catch (e:Dynamic)
				{
					trace("[LegacyDialogueBox] ERROR: failed to parse dialogue JSON: " + path + " | " + e);
					niceDialogue = {style: "darkworld", dialogue: []};
				}
			}
			#else
			niceDialogue = {style: "darkworld", dialogue: []};
			#end
		}
		else
		{
			niceDialogue = dialogueFile;
		}

		if (niceDialogue.dialogue == null)
			niceDialogue.dialogue = [];

		dialogueIndex = -1;
		continueDialogue();
	}

	function set_activated(value:Bool):Bool
	{
		activated = value;
		return value;
	}

	public function continueDialogue(?reset:Bool = false)
	{
		linefinished = false;

		if (niceDialogue.dialogue.length == 0)
		{
			activated = false;
			return;
		}

		if (dialogueIndex + 1 >= niceDialogue.dialogue.length && !reset)
		{
			activated = false;
			if (finishedCallback != null)
				finishedCallback();
		}
		else
		{
			if (!reset)
				dialogueIndex++;
			if (dialogueProgressedCallback != null)
				dialogueProgressedCallback(dialogueIndex);

			var line = niceDialogue.dialogue[dialogueIndex];
			if (line == null || line.text == null)
			{
				activated = false;
				return;
			}
			typeText.resetText(line.text);
			var spd:Float = 1;
			if (Reflect.hasField(line, "speed"))
			{
				var s:Dynamic = Reflect.field(line, "speed");
				if (s != null)
					spd = s;
			}

			typeText.start(spd / 30, true, false, dialogueLineFinished);
		}
	}

	function dialogueLineFinished()
	{
		linefinished = true;
		if (dialogueIndex < niceDialogue.dialogue.length)
		{
			var line = niceDialogue.dialogue[dialogueIndex];
			if (line != null && line.autocontinue)
				continueDialogue();
		}
	}

	override public function update():Bool
	{
		if (activated)
		{
			if (Controls.primary.justPressed && linefinished)
				continueDialogue();
			if (Controls.primary.justPressed && !linefinished)
				typeText.skip();
		}
		return super.update();
	}

	public inline function getCurrentLine():DialogueLine
	{
		return niceDialogue.dialogue[dialogueIndex];
	}
}