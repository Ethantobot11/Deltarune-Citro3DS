package deltarune.game.states;

import citro.state.CitroState;

class SaveSelectState extends CitroState
{
	public var selectionOther:Bool = false;
	public var saveSelected:Int = 0;
	public var saveOption:Int = 0;
	public var otherOption:Int = 0;
	public var copying:Bool = false;

	override public function create()
	{
		super.create();
	}

	override public function update(delta:Int)
	{
		super.update(delta);
	}
}