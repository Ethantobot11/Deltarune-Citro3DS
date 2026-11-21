package deltarune.game;

import citro.object.CitroAnimate;
import citro.object.CitroObject;
import deltarune.Controls;
import citro.CitroG;

class Player extends CitroAnimate
{
	public var baseSpeed:Float = 180;
	public var runningTime:Float = 0;

	public var collider:LinkedCollider;
	public var colliderOffset:Array<Int> = [12, 42];
	public var colliderSize:Array<Int> = [18, 36];
	public var interactionCollider:CitroObject;

	public var controlArray:Array<String> = [];
	public var lastAnimation:String = '_';
	public var warped:Bool = false;
	public var running:Bool = false;

	public static inline var UP:Int = 0;
	public static inline var DOWN:Int = 1;
	public static inline var LEFT:Int = 2;
	public static inline var RIGHT:Int = 3;

	public var facing:Int = DOWN;

	public function new(x:Float, y:Float, character:String = 'KrisDarkworld')
	{
		super();
		this.x = x;
		this.y = y;
		var ceaPath = 'romfs:/assets/images/characters/$character/spritesheet.cea';
		loadCEA(ceaPath, "down");

		collider = new LinkedCollider(x + colliderOffset[0], y + colliderOffset[1], colliderSize[0], colliderSize[1]);
		interactionCollider = new CitroObject();
		interactionCollider.width = 32;
		interactionCollider.height = 52;

		collider.linkedObjects.set(this, {x: colliderOffset[0], y: colliderOffset[1]});
		collider.linkedObjects.set(interactionCollider, {x: 8, y: 16});

		reverseposition();
	}

	public function playAnimation(?anim:String)
	{
		if (anim == null)
			anim = lastAnimation;

		if (curAnim != anim || finished)
		{
			play(anim);
		}
		lastAnimation = anim;
	}

	public function reverseposition()
	{
		collider.x = this.x + colliderOffset[0];
		collider.y = this.y + colliderOffset[1];
		interactionCollider.x = collider.x - 8;
		interactionCollider.y = collider.y - 16;
	}

	override public function update():Bool
	{
		if (controlArray.length <= 0)
		{
			updateMovement();
		}
		return super.update();
	}

	function updateMovement()
	{
		var up = Controls.up.pressed;
		var down = Controls.down.pressed;
		var left = Controls.left.pressed;
		var right = Controls.right.pressed;
		running = Controls.secondary.pressed;

		if (up && down)
		{
			up = false;
			down = false;
		}
		if (left && right)
		{
			left = false;
			right = false;
		}

		if (up || down || left || right)
		{
			var speed = running ? baseSpeed * 1.5 : baseSpeed;
			runningTime += CitroG.deltaTime / 1000.0;

			var vx:Float = 0, vy:Float = 0;
			if (up)
			{
				vy = -speed;
				facing = UP;
			}
			if (down)
			{
				vy = speed;
				facing = DOWN;
			}
			if (left)
			{
				vx = -speed;
				facing = LEFT;
			}
			if (right)
			{
				vx = speed;
				facing = RIGHT;
			}

			if (vx != 0 && vy != 0)
			{
				vx *= 0.707;
				vy *= 0.707;
			}

			collider.x += vx * (CitroG.deltaTime / 1000.0);
			collider.y += vy * (CitroG.deltaTime / 1000.0);

			var dirStr = switch (facing)
			{
				case LEFT: "left";
				case RIGHT: "right";
				case UP: "up";
				default: "down";
			}

			framerate = running ? 16 : 8;
			playAnimation("walk-" + dirStr);
		}
		else
		{
			runningTime = 0;
			framerate = 8;
			var dirStr = switch (facing)
			{
				case LEFT: "left";
				case RIGHT: "right";
				case UP: "up";
				default: "down";
			}
			playAnimation(dirStr);
		}

		this.x = collider.x - colliderOffset[0];
		this.y = collider.y - colliderOffset[1];
		interactionCollider.x = collider.x - 8;
		interactionCollider.y = collider.y - 16;
	}

	override public function destroy()
	{
		if (collider != null)
			collider.destroy();
		if (interactionCollider != null)
			interactionCollider.destroy();
		super.destroy();
	}
}

class LinkedCollider extends CitroObject
{
	public var linkedObjects:Map<CitroObject, {x:Float, y:Float}> = new Map();

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		super();
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	override public function set_x(value:Float):Float
	{
		for (obj => offset in linkedObjects)
		{
			obj.x = value - offset.x;
		}
		return x = value;
	}

	override public function set_y(value:Float):Float
	{
		for (obj => offset in linkedObjects)
		{
			obj.y = value - offset.y;
		}
		return y = value;
	}
}