package deltarune.game.states;

import citro.state.CitroState;
import citro.CitroG;
import citro.backend.CitroTimer;
import citro.object.CitroSprite;
import citro.backend.CitroTween;

class TransitionState extends CitroState
{
	public var nextState:Void->CitroState;

	var fadeOverlay:CitroSprite;

	public function new(?nextState:Void->CitroState)
	{
		if (nextState == null)
			nextState = () -> new ChapterSelectState();
		this.nextState = nextState;
		super();
	}

	override public function create()
	{
		super.create();
		fadeOverlay = new CitroSprite(0, 0);
		fadeOverlay.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, 0xFF000000);
		fadeOverlay.alpha = 0;
		add(fadeOverlay);

		CitroTween.tween(fadeOverlay, {alpha: 1}, 0.3, {
			onComplete: function()
			{
				CitroG.switchState(nextState());
			}
		});
	}
}