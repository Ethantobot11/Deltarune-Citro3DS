package deltarune.editors;

import deltarune.game.LegacyDialogueBox;
import citro.state.CitroState;

class DialogueTestSState extends CitroState
{
	override function create()
	{
		super.create();
		CitroG.switchState(new deltarune.game.states.MenuState());
	}
}
