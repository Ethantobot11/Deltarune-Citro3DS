package;

import citro.CitroGame;
import deltarune.Game;
import deltarune.Controls;

class Main
{
	public function new()
	{
		Game.consoleArguments = [];
		Game.enviromentVariables = new Map<String, String>();
		Game.initialize();
		Controls.addControllerToast();
		var initialState = new deltarune.game.states.ChapterSelectState();
		CitroGame.start(initialState);
	}

	public static function main()
	{
		new Main();
	}
}