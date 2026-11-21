package;

import citro.CitroGame;
import deltarune.CrashHandler;
import deltarune.Game;
import deltarune.Controls;
import deltarune.GameFps;
import deltarune.assets.GameAssets;
import deltarune.assets.SysAssetSystem;
import deltarune.game.states.ChapterSelectState;

class Main
{
	public function new()
	{
		CrashHandler.init();
		#if sys
		Game.consoleArguments = Sys.args();
		Game.enviromentVariables = Sys.environment();
		#else
		Game.consoleArguments = [];
		Game.enviromentVariables = new Map<String, String>();
		#end

		GameAssets.assetSystems.push(new SysAssetSystem('default', 'romfs:/assets'));
		Game.initialize();
		Controls.addControllerToast();
		Game.framerateDisplay = new GameFps();

		var initialState = new ChapterSelectState();
		CitroGame.start(initialState);
	}

	public static function main()
	{
		new Main();
	}
}