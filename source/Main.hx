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
import deltarune.game.states.IntroState;
import deltarune.game.states.substates.Options;

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
		CitroG.globalOverlay = Game.framerateDisplay;
		Options.applyDisplaySettings();
		Options.applyBorderSettings()();
		Game.border = new ConsoleBorder();
		CitroG.globalOverlay2 = Game.border; 
		var initialState = new IntroState();
		CitroGame.start(initialState);
	}

	public static function main()
	{
		new Main();
	}
}
