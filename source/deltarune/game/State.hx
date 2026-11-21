package deltarune.game;

import citro.state.CitroState;

class State extends CitroState
{
	override public function create()
	{
		Game.initialize();
		super.create();
	}
}