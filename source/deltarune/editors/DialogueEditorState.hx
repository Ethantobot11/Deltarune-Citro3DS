package deltarune.editors;

import citro.state.CitroState;
import citro.object.CitroText;
import citro.CitroG;
import deltarune.game.LegacyDialogueBox;
import deltarune.Controls;

class DialogueEditorState extends CitroState
{
	var dialogueBox:LegacyDialogueBox;
	var infoText:CitroText;
	var file:Dynamic;

	public function new(?dialogueData:Dynamic)
	{
		super();
		file = dialogueData != null ? dialogueData : {
			style: "darkworld",
			dialogue: [
				{
					portrait: "none",
					text: "lorum ipsum",
					speed: 1,
					pausespeed: 1,
					autocontinue: false,
					skippable: true
				}
			]
		};
	}

	override function create()
	{
		super.create();

		dialogueBox = new LegacyDialogueBox(0, 400, file);
		dialogueBox.bottom = true;
		add(dialogueBox);
		dialogueBox.activated = true;

		infoText = new CitroText(10, 10, "");
		infoText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		add(infoText);

		updateInfo();
	}

	function updateInfo()
	{
		var line = dialogueBox.getCurrentLine();
		var idx = dialogueBox.dialogueIndex + 1;
		var total = file.dialogue.length;
		infoText.text = 'Line: $idx/$total\nSpeed: ${line.speed}\nAuto: ${line.autocontinue ? "Yes" : "No"}\nSkip: ${line.skippable ? "Yes" : "No"}\n\nUP/DOWN: Change Line\nLEFT/RIGHT: Speed\nA: Toggle Auto\nY: Toggle Skip\nX: Add Line\nSelect: Remove Line\nB: Back';
	}

	override function update(delta:Int)
	{
		super.update(delta);

		if (Controls.back.justPressed)
		{
			CitroG.switchState(new deltarune.game.states.MenuState());
		}

		var line = dialogueBox.getCurrentLine();

		if (Controls.up.justPressed)
		{
			changeLine(-1);
		}
		if (Controls.down.justPressed)
		{
			changeLine(1);
		}

		if (Controls.left.justPressed)
		{
			line.speed = Math.max(0.1, line.speed - 0.1);
			dialogueBox.continueDialogue(true);
			updateInfo();
		}
		if (Controls.right.justPressed)
		{
			line.speed = Math.min(5.0, line.speed + 0.1);
			dialogueBox.continueDialogue(true);
			updateInfo();
		}

		if (Controls.primary.justPressed)
		{
			line.autocontinue = !line.autocontinue;
			updateInfo();
		}
		if (Controls.tetritary.justPressed)
		{
			line.skippable = !line.skippable;
			updateInfo();
		}

		if (Controls.secondary.justPressed)
		{
			file.dialogue.insert(dialogueBox.dialogueIndex + 1, {
				portrait: "none",
				text: "New Line",
				speed: 1,
				pausespeed: 1,
				autocontinue: false,
				skippable: true
			});
			changeLine(1);
		}

		if (Controls.back.pressed && Controls.secondary.justPressed)
		{
			
		}
	}

	function changeLine(change:Int)
	{
		dialogueBox.dialogueIndex += change;
		if (dialogueBox.dialogueIndex >= file.dialogue.length)
			dialogueBox.dialogueIndex = 0;
		if (dialogueBox.dialogueIndex < 0)
			dialogueBox.dialogueIndex = file.dialogue.length - 1;

		dialogueBox.continueDialogue(true);
		updateInfo();
	}
}