package deltarune.game;

import citro.object.CitroAnimate;
import citro.object.CitroObject;
import citro.CitroG;
import deltarune.Controls;
import deltarune.assets.GameAssets;
import haxe.Json;

typedef PlayerSpeeds = {
	var ?normal:Float;
	var ?shortrun:Float;
	var ?mediumruntime:Float;
	var ?mediumrun:Float;
	var ?longruntime:Float;
	var ?longrun:Float;
}

typedef PlayerAnims = {
	var sheetType:String;
	var width:Int;
	var height:Int;
	var colliderData:{x:Int, y:Int, even:Bool};
	var animations:Array<AnimationJSON>;
}

typedef AnimationJSON = {
	var name:String;
	var indicies:Array<Int>;
	var framerate:Null<Int>;
	var looped:Bool;
}

class Player extends CitroAnimate
{
	public var baseSpeed:Float = 180;
	public var speeds:PlayerSpeeds = {
		normal: 120,
		shortrun: 180,
		mediumruntime: 0.3,
		mediumrun: 240,
		longruntime: 2.0,
		longrun: 270
	};
	public var runningTime:Float = 0;
	public var collider:LinkedCollider;
	public var colliderOffset:Array<Int> = [12, 42];
	public var colliderSize:Array<Int> = [18, 36];
	public var interactionCollider:CitroObject;
	public var controlArray:Array<String> = [];
	public var lastAnimation:String = '_';
	public var hasLeftRightAnims:Bool = false;
	public var warped:Bool = false;
	public var running:Bool = false;
	public var JSON:PlayerAnims;

	private var intColOffs:Array<Int> = [8, 16];
	private var animFramerates:Map<String, Float> = new Map();
	
	public static inline var UP:Int = 0;
	public static inline var DOWN:Int = 1;
	public static inline var LEFT:Int = 2;
	public static inline var RIGHT:Int = 3;
	
	public var facing:Int = DOWN;
	var lastMoveDirection:Int = DOWN;

	public function new(x:Float, y:Float, character:String = 'KrisDarkworld')
	{
		super();
		this.x = x;
		this.y = y;

		loadAnimations(character);

		collider = new LinkedCollider(x + colliderOffset[0], y + colliderOffset[1], colliderSize[0], colliderSize[1]);
		interactionCollider = new CitroObject();
		interactionCollider.width = 32;
		interactionCollider.height = 52;
		
		collider.linkedObjects.set(this, {x: colliderOffset[0], y: colliderOffset[1]});
		collider.linkedObjects.set(interactionCollider, {x: intColOffs[0], y: intColOffs[1]});
		
		reverseposition();
	}

	function loadAnimations(folder:String)
	{
		JSON = cast JsonUtil.trimKeys(GameAssets.getJSON('romfs:/assets/data/characters/$folder/animations.json'));
		var cfg = JsonUtil.trimKeys(GameAssets.getJSON('romfs:/assets/data/characters/$folder/config.json'));

		if (JSON == null && folder != 'KrisDarkworld')
		{
			loadAnimations('KrisDarkworld');
			return;
		}

		colliderOffset[0] = JSON.colliderData.x * 2;
		colliderOffset[1] = JSON.colliderData.y * 2;

		if (JSON.colliderData.even)
		{
			colliderSize[0] = 16;
		}
		else
		{
			colliderSize[0] = 18;
		}

		var fw:Float = JSON.width;
		var fh:Float = JSON.height;

		var defs:Map<String, Array<Int>> = new Map();
		for (anim in JSON.animations)
		{
			defs.set(anim.name, anim.indicies);
			animFramerates.set(anim.name, anim.framerate != null ? anim.framerate : 8);

			if (anim.name == 'left' || anim.name == 'right')
			{
				hasLeftRightAnims = true;
			}
		}

		loadFromT3XWithAnims('romfs:/assets/images/characters/$folder/spritesheet.t3x', fw, fh, defs);
		playAnimation("up");
	}

	public function playAnimation(?anim:String)
	{
		if (anim == null) anim = lastAnimation;
		if (animFramerates.exists(anim)) framerate = animFramerates[anim];
		if (hasLeftRightAnims && atlasSprite != null) {
			atlasSprite.flipX = (facing == RIGHT);
		}

		if (curAnim != anim || finished) play(anim);
		lastAnimation = anim;
	}

	public function reverseposition()
	{
		collider.x = this.x + colliderOffset[0];
		collider.y = this.y + colliderOffset[1];
		interactionCollider.x = collider.x - intColOffs[0];
		interactionCollider.y = collider.y - intColOffs[1];
	}

	override public function update():Bool
	{
		if (controlArray.length <= 0) updateMovement();
		return super.update();
	}

	function updateMovement()
	{
		var keys:Array<Bool> = [
			Controls.left.pressed,
			Controls.down.pressed,
			Controls.up.pressed,
			Controls.right.pressed,
		];

		running = Controls.secondary.pressed;

		if (keys[1] && keys[2]) keys[1] = keys[2] = false;
		if (keys[0] && keys[3]) keys[0] = keys[3] = false;

		if (keys.contains(true))
		{
			var diagonal = (keys[0] || keys[3]) && (keys[1] || keys[2]);
			var speed:Float = speeds.normal;
			
			if (running)
			{
				if (runningTime >= speeds.longruntime) speed = speeds.longrun;
				else if (runningTime >= speeds.mediumruntime) speed = speeds.mediumrun;
				else speed = speeds.shortrun;
				runningTime += CitroG.deltaTime / 1000.0;
			}
			else
			{
				runningTime = 0;
			}

			var vx:Float = 0, vy:Float = 0;

			if (keys[2])
			{
				vy = -speed;
				facing = UP;
				if (!diagonal) lastMoveDirection = UP;
			}
			else if (keys[1])
			{
				vy = speed;
				facing = DOWN;
				if (!diagonal) lastMoveDirection = DOWN;
			}
			else if (keys[0])
			{
				vx = -speed;
				facing = LEFT;
				if (!diagonal) lastMoveDirection = LEFT;
			}
			else
			{
				vx = speed;
				facing = RIGHT;
				if (!diagonal) lastMoveDirection = RIGHT;
			}

			if (diagonal)
			{
				vx *= 0.707;
				vy *= 0.707;
			}

			collider.x += vx * (CitroG.deltaTime / 1000.0);
			collider.y += vy * (CitroG.deltaTime / 1000.0);

			switch (lastMoveDirection)
			{
				case LEFT:
					if (animFramerates.exists("walk-left")) playAnimation("walk-left");
					else if (hasLeftRightAnims) playAnimation("walk-right");
					else playAnimation("walk-side");
				case RIGHT:
					if (animFramerates.exists("walk-right")) playAnimation("walk-right");
					else if (hasLeftRightAnims) playAnimation("walk-left");
					else playAnimation("walk-side");
				case UP:
					playAnimation("walk-up");
				case DOWN:
					playAnimation("walk-down");
			}
		}
		else
		{
			runningTime = 0;
			switch (lastMoveDirection)
			{
				case LEFT:
					if (animFramerates.exists("left")) playAnimation("left");
					else if (hasLeftRightAnims) playAnimation("right");
					else playAnimation("side");
				case RIGHT:
					if (animFramerates.exists("right")) playAnimation("right");
					else if (hasLeftRightAnims) playAnimation("left");
					else playAnimation("side");
				case UP:
					playAnimation("up");
				case DOWN:
					playAnimation("down");
			}
		}
        
		this.x = collider.x - colliderOffset[0];
		this.y = collider.y - colliderOffset[1];
		interactionCollider.x = collider.x - intColOffs[0];
		interactionCollider.y = collider.y - intColOffs[1];
	}

	override public function destroy()
	{
		if (collider != null) collider.destroy();
		if (interactionCollider != null) interactionCollider.destroy();
		super.destroy();
	}
}

class LinkedCollider extends CitroObject
{
	public var linkedObjects:Map<CitroObject, {x:Float, y:Float}> = new Map();

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		super();
		this.x = x; this.y = y; this.width = width; this.height = height;
	}
}
