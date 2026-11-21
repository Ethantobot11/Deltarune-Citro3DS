package deltarune.game.states;

import citro.CitroG;
import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroButton;
import citro.backend.CitroTween;
import deltarune.Controls;
import deltarune.Game;
import deltarune.game.states.substates.Credits;
import deltarune.game.states.substates.Options;
import deltarune.game.states.ChapterSelectState;

class MenuState extends CitroState
{
	public static var instance:MenuState;

	public var playButton:CitroButton;
	public var credsButton:CitroButton;
	public var optButton:CitroButton;

	private var coolBG:CitroSprite;
	private var leaving:Bool = false;

	override public function create()
	{
		super.create();
		instance = this;

		coolBG = new CitroSprite(0, 0);
		coolBG.loadGraphic('romfs:/assets/images/menuBG.t3x', 320, 240);
		coolBG.scale.x = 400 / 320;
		coolBG.scale.y = 240 / 240;
		coolBG.screenCenter(XY);
		add(coolBG);

		playButton = new CitroButton(80, 40, 160, 40, "Play", clickPlay);
		playButton.bottom = true;
		add(playButton);

		credsButton = new CitroButton(80, 100, 160, 40, "Credits", function() {
			openSubstate(new Credits());
		});
		credsButton.bottom = true;
		add(credsButton);

		optButton = new CitroButton(80, 160, 160, 40, "Options", function() {
			openSubstate(new Options());
		});
		optButton.bottom = true;
		add(optButton);
	}

	function clickPlay()
	{
		if (!leaving) {
			leaving = true;
			CitroG.switchState(new ChapterSelectState());
			//CitroG.switchState(new PlayState());
		}
	}

	public function exitCredits()
	{
		CitroG.substate = null;
		playButton.alpha = 1;
		credsButton.alpha = 1;
		optButton.alpha = 1;
	}
}
