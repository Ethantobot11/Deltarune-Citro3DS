package deltarune.game.objects;

import citro.object.CitroObject;

/**
 * Used for pre-defined collision in the room
 */
class CollisionObject extends CitroObject
{
	public function new(X:Float, Y:Float, Width:Float, Height:Float)
	{
		super();
		this.x = X;
		this.y = Y;
		this.width = Width;
		this.height = Height;
	}
}