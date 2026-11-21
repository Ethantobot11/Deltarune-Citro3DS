package deltarune.game.objects;

import citro.object.CitroObject;
import citro.object.CitroSprite;
import deltarune.game.states.PlayState;

class InteractableSprite extends CitroSprite
{
	public var interactionHitbox:CitroObject;
	public var autoTriggered:Bool;
	public var interactionCount:Int;
	public var objectValues:Dynamic;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		autoTriggered = false;
		interactionCount = 0;
		objectValues = {};
		interactionHitbox = new CitroObject();
		interactionHitbox.x = x;
		interactionHitbox.y = y;
		interactionHitbox.width = 32;
		interactionHitbox.height = 32;
	}

	public function onInteraction()
	{
		interactionCount++;
	}

	override public function update():Bool
	{
		interactionHitbox.x = x;
		interactionHitbox.y = y;
		return super.update();
	}

	override public function destroy()
	{
		if (interactionHitbox != null)
			interactionHitbox.destroy();
		super.destroy();
	}
}

class Sign extends InteractableSprite
{
	public function new(x:Float, y:Float)
	{
		super(x - 10, y - 10);
		loadGraphic('romfs:/assets/images/commonObjects.t3x', 20, 20);
		scale.x = 2;
		scale.y = 2;
	}

	override public function onInteraction()
	{
		super.onInteraction();
		if (PlayState.instance != null)
		{
			PlayState.instance.startDialogue('room_${PlayState.instance.levelString}_sign${objectValues.dialouge}');
		}
	}
}

class InvisibleSign extends InteractableSprite
{
	public function new(X:Float, Y:Float, WIDTH:Float, HEIGHT:Float)
	{
		super(X, Y);
		interactionHitbox = new CitroObject();
		interactionHitbox.x = X;
		interactionHitbox.y = Y;
		interactionHitbox.width = 10 * WIDTH;
		interactionHitbox.height = 10 * HEIGHT;
	}

	override public function update():Bool
	{
		super.update();
		interactionHitbox.x = x;
		interactionHitbox.y = y;
		return true;
	}

	override public function onInteraction()
	{
		super.onInteraction();
		if (PlayState.instance != null)
		{
			PlayState.instance.startDialogue('room_${PlayState.instance.levelString}_sign${objectValues.dialouge}');
		}
	}
}

class SavePoint extends InteractableSprite
{
	public function new(X:Float, Y:Float)
	{
		super(X - 10, Y - 10);
		interactionHitbox = new CitroObject();
		interactionHitbox.x = X - 2;
		interactionHitbox.y = Y - 2;
		interactionHitbox.width = 44;
		interactionHitbox.height = 44;
		loadGraphic('romfs:/assets/images/commonObjects.t3x', 20, 20);
		scale.x = 2;
		scale.y = 2;
	}

	override public function update():Bool
	{
		super.update();
		interactionHitbox.x = x - 2;
		interactionHitbox.y = y - 2;
		return true;
	}

	override public function onInteraction()
	{
		super.onInteraction();
		if (PlayState.instance != null)
		{
			PlayState.instance.startDialogue('room_${PlayState.instance.levelString}_save');
		}
	}
}

class WarpPoint extends InteractableSprite
{
	public function new(X:Float, Y:Float, WIDTH:Float, HEIGHT:Float)
	{
		super(X, Y);
		visible = false;
		interactionHitbox = new CitroObject();
		interactionHitbox.x = X;
		interactionHitbox.y = Y;
		interactionHitbox.width = WIDTH;
		interactionHitbox.height = HEIGHT;
	}

	override public function update():Bool
	{
		super.update();
		autoTriggered = true;
		interactionHitbox.x = x;
		interactionHitbox.y = y;
		return true;
	}

	override public function onInteraction()
	{
		if (interactionCount == 0)
		{
			super.onInteraction();
			if (PlayState.instance != null && objectValues != null)
			{
				PlayState.instance.changeRoom(objectValues.targetRoom, objectValues.entranceTag, PlayState.instance.player.x - x,
					PlayState.instance.player.y - y);
			}
		}
	}
}

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