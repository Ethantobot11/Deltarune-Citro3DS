package deltarune.game.states;

import citro.CitroG;
import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.object.CitroButton;
import citro.backend.CitroTween;
import citro.backend.CitroEase;
import deltarune.Controls;
import deltarune.Game;

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
		coolBG.loadGraphic('romfs:/assets/images/menuBG.t3x', 320, 260);
		coolBG.scale.x = 2;
		coolBG.scale.y = 2;
		coolBG.screenCenter(XY);
		add(coolBG);

		playButton = new CitroButton(200, 225, 160, 40, "Play", clickPlay);
		playButton.bottom = true;
		add(playButton);

		credsButton = new CitroButton(200, 275, 160, 40, "Credits", function()
		{
			openSubstate(new Credits());
		});
		credsButton.bottom = true;
		add(credsButton);

		optButton = new CitroButton(200, 325, 160, 40, "Options", function()
		{
			openSubstate(new Options());
		});
		optButton.bottom = true;
		add(optButton);
	}

	function clickPlay()
	{
		if (!leaving)
		{
			leaving = true;
			CitroG.switchState(new PlayState());
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