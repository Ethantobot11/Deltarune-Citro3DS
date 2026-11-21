package deltarune.game.states;

import citro.CitroG;
import citro.state.CitroState;
import citro.object.CitroTilemap;
import citro.object.CitroGroup;
import citro.editors.ogmo.CitroOgmo3Loader;
import deltarune.game.Player;
import deltarune.game.LegacyDialogueBox;
import deltarune.game.objects.InteractableSprite.*;
import deltarune.game.objects.*;
import deltarune.Controls;
import deltarune.Game;

class PlayState extends CitroState
{
	public static var instance:PlayState;

	public var map:CitroOgmo3Loader;
	public var background:CitroTilemap;
	public var walls:CitroTilemap;

	public var player:Player;
	public var dialogue:LegacyDialogueBox;

	public var interactables:CitroGroup;
	public var collisionLayer:CitroGroup;

	public var levelString:String;
	public var warpTag:String;
	public var xoffset:Float;
	public var yoffset:Float;

	public var quitTimer:Float = 0;
	public var quitLength:Float = 1.5;
	public var doingTheQuit:Bool = false;

	public function new(levelID:String = '001', ?warpPoint:String, Xoffset:Float = 0, Yoffset:Float = 0)
	{
		super();
		levelString = levelID;
		warpTag = warpPoint;
		xoffset = Xoffset;
		yoffset = Yoffset;
	}

	override public function create()
	{
		super.create();
		instance = this;

		map = new CitroOgmo3Loader('romfs:/assets/data/ogmoData.ogmo', 'romfs:/assets/data/levels/level$levelString.json');
		background = map.loadTilemap("romfs:/assets/images/cyberassetsbackgounds.t3x", "background", 16);
		add(background);

		walls = map.loadTilemap("romfs:/assets/images/cyberassetsmini.t3x", "walls", 16);
		add(walls);

		interactables = new CitroGroup();
		collisionLayer = new CitroGroup();
		add(interactables);
		add(collisionLayer);

		player = new Player(20, 20);
		player.scale.x = 2;
		player.scale.y = 2;
		add(player);
		add(player.collider);
		add(player.interactionCollider);
		map.loadEntities(function(entity:Dynamic)
		{
			switch (entity.name)
			{
				case "player":
					if (!player.warped)
					{
						player.x = entity.x;
						player.y = entity.y;
						player.reverseposition();
					}
				case "sign":
					var newSign = new Sign(entity.x, entity.y);
					newSign.objectValues = entity.values;
					interactables.add(newSign);
					add(newSign.interactionHitbox);
				case "invisible-sign":
					var newISign = new InvisibleSign(entity.x, entity.y, entity.width, entity.height);
					newISign.objectValues = entity.values;
					interactables.add(newISign);
					add(newISign.interactionHitbox);
				case "save":
					var newSave = new SavePoint(entity.x, entity.y);
					interactables.add(newSave);
					add(newSave.interactionHitbox);
				case "warpEntrance":
					if (warpTag == entity.values.entranceTag)
					{
						player.x = entity.values.useXoffset ? entity.x + xoffset : entity.x;
						player.y = entity.values.useYoffset ? entity.y + yoffset : entity.y;
						player.reverseposition();
						player.warped = true;
					}
				case "warpExit":
					var newWarp = new WarpPoint(entity.x + entity.values.xOffset, entity.y + entity.values.yOffset, entity.width, entity.height);
					newWarp.objectValues = entity.values;
					interactables.add(newWarp);
					add(newWarp.interactionHitbox);
			}
		}, "entities");

		map.loadEntities(function(entity:Dynamic)
		{
			switch (entity.name)
			{
				case "collision":
					var collider = new CollisionObject(entity.x, entity.y, entity.width, entity.height);
					collisionLayer.add(collider);
			}
		}, "collision");

		dialogue = new LegacyDialogueBox(0, 400, 'romfs:/assets/data/dialogue/testDialogue.json');
		dialogue.bottom = true;
		add(dialogue);
	}

	override public function update(delta:Int)
	{
		super.update(delta);
		if (Controls.back.pressed)
		{
			quitTimer += delta / 1000.0;
		}
		else
		{
			quitTimer = 0;
		}

		if (!doingTheQuit && quitTimer >= quitLength)
		{
			doingTheQuit = true;
			CitroG.switchState(new MenuState());
		}

		resolveCollision(player.collider, collisionLayer);
		resolveCollision(player.collider, interactables);
		if (player.controlArray.length <= 0)
		{
			for (member in interactables.members)
			{
				var interactable:InteractableSprite = cast member;
				if (interactable != null
					&& interactable.exists
					&& CitroG.overlaps(player.interactionCollider, interactable.interactionHitbox))
				{
					if (Controls.primary.justPressed || interactable.autoTriggered)
					{
						interactable.onInteraction();
					}
				}
			}
		}
	}

	public function startDialogue(filename:String)
	{
		remove(dialogue);
		dialogue = new LegacyDialogueBox(0, 400, 'romfs:/assets/data/dialogue/$filename.json');
		dialogue.bottom = true;
		add(dialogue);
		dialogue.activated = true;
	}

	public function changeRoom(Room:String, Entrance:String, X:Float, Y:Float)
	{
		CitroG.switchState(new PlayState(Room, Entrance, X, Y));
	}

	function resolveCollision(obj:Dynamic, group:CitroGroup)
	{
		for (target in group.members)
		{
			if (target.exists && CitroG.overlaps(obj, target))
			{
				var overlapX = (obj.width * obj.scale.x
					+ target.width * target.scale.x) / 2
					- Math.abs((obj.x + (obj.width * obj.scale.x) / 2) - (target.x + (target.width * target.scale.x) / 2));
				var overlapY = (obj.height * obj.scale.y
					+ target.height * target.scale.y) / 2
					- Math.abs((obj.y + (obj.height * obj.scale.y) / 2) - (target.y + (target.height * target.scale.y) / 2));

				if (overlapX < overlapY)
				{
					if (obj.x < target.x)
						obj.x -= overlapX;
					else
						obj.x += overlapX;
				}
				else
				{
					if (obj.y < target.y)
						obj.y -= overlapY;
					else
						obj.y += overlapY;
				}
			}
		}
	}
}