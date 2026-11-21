package deltarune.game.objects;

import citro.object.CitroObject;
import citro.object.CitroSprite;

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
		PlayState.instance.startDialogue('room_${PlayState.instance.levelString}_sign${objectValues.dialouge}');
	}
}