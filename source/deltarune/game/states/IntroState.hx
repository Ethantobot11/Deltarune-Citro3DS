package deltarune.game.states;

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroButton;
import citro.CitroG;

class IntroState extends CitroState
{
	var background:CitroSprite;
	var playButton:CitroButton;
	var leaving:Bool = false;
	var pulseTime:Float = 0;

	override public function create()
	{
		super.create();

		background = new CitroSprite(0, 0);
		background.loadGraphic('romfs:/assets/images/intro_cutscene/intro_background.t3x');
		background.scale.x = 2.5;
		background.scale.y = 2.5;
		background.screenCenter(XY);
		add(background);

		playButton = new CitroButton((CitroG.WIDTH / 2) - 80, (CitroG.HEIGHT / 2) + 100, 160, 40, "BEGIN", clickPlay);
		add(playButton);
	}

	override public function update(delta:Int)
	{
		super.update(delta);
		final elapsed = delta / 1000.0;
		pulseTime += elapsed;
		var pulse = 1.0 + (Math.sin(pulseTime * 2.0) * 0.05);
		background.scale.x = 2.5 * pulse;
		background.scale.y = 2.5 * pulse;
	}

	function clickPlay()
	{
		if (leaving)
			return;
		leaving = true;
		CitroG.switchState(new TransitionState(new MenuState));
	}
}