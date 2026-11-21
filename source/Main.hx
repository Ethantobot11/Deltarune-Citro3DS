package;

import citro.CitroG;
import citro.CitroGame;
import deltarune.CrashHandler;
import deltarune.Game;
import deltarune.GameFps;
import deltarune.Controls;
import deltarune.ConsoleBorder;
import deltarune.assets.GameAssets;
import deltarune.assets.SysAssetSystem;
import deltarune.game.states.MenuState;

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
		Game.border = new ConsoleBorder();
		Game.initialize();
		Controls.addControllerToast();
		Game.framerateDisplay = new GameFps();
		Game.framerateDisplay.bottom = true;
		CitroG.globalOverlay = Game.framerateDisplay;
		var initialState = new MenuState();
		CitroGame.start(initialState);
	}

	public static function main()
	{
		new Main();
	}
}
