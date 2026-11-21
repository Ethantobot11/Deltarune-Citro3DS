package deltarune.game;

import citro.CitroG;
import citro.object.CitroGroup;
import citro.object.CitroSprite;
import citro.object.CitroTypeText;
import deltarune.game.DialogueData;

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
			var jsonStr = sys.io.File.getContent(Std.string(dialogueFile));
			niceDialogue = haxe.Json.parse(jsonStr);
		}
		else
		{
			niceDialogue = dialogueFile;
		}

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
			typeText.resetText(line.text);
			typeText.start(line.speed / 30, true, false, dialogueLineFinished);
		}
	}

	function dialogueLineFinished()
	{
		linefinished = true;
		if (niceDialogue.dialogue[dialogueIndex].autocontinue)
			continueDialogue();
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
