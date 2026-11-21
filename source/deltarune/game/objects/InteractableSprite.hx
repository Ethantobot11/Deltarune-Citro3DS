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
				trace('going to room:' + objectValues.targetRoom + ' with tag:' + objectValues.entranceTag);
				PlayState.instance.changeRoom(objectValues.targetRoom, objectValues.entranceTag, PlayState.instance.player.x - x,
					PlayState.instance.player.y - y);
			}
		}
	}
}

#if hscript
import deltarune.scripting.GameScript;

class ScriptObject extends InteractableSprite
{
	public var script:GameScript;
	public var entity:Dynamic;

	public function new(X:Float, Y:Float, Entity:Dynamic, Values:Dynamic, Script:GameScript)
	{
		super(X, Y);
		objectValues = Values;
		entity = Entity;
		script = Script;
		script.setVariable('object', this);
		script.callFunction('objectCreate', [X, Y, Entity, Values]);

		if (interactionHitbox == null)
		{
			interactionHitbox = new CitroObject();
			interactionHitbox.x = X;
			interactionHitbox.y = Y;
		}
	}

	override public function update():Bool
	{
		if (script != null)
			script.callFunction('update', [CitroG.deltaTime / 1000.0]);
		super.update();
		if (script != null)
			script.callFunction('updatePost', [CitroG.deltaTime / 1000.0]);
		return true;
	}

	override public function destroy()
	{
		if (script != null)
			script.callFunction('destroy', []);
		super.destroy();
	}

	override public function onInteraction()
	{
		super.onInteraction();
		if (script != null)
			script.callFunction('onInteraction', [interactionCount]);
	}
}
#end