package deltarune.game.states;

import citro.state.CitroState;
import citro.CitroG;
import citro.backend.CitroTimer;

class TransitionState extends CitroState
{
	public var nextState:Void->CitroState;

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
		CitroTimer.start(0.5,function()
		{
			CitroG.switchState(nextState());
		});
	}
}