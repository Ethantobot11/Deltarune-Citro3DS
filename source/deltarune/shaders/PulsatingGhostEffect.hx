package deltarune.shaders;

import citro.object.CitroGroup;
import citro.object.CitroSprite;
import citro.CitroG;

/**
 * CPU-based approximation of the Pulsating Ghost effect.
 * Replicates multi-sample additive blending by drawing multiple scaled/alpha-adjusted copies.
 */
class PulsatingGhostEffect extends CitroGroup
{
	public var size(default, set):Float = 0.33;
	public var power(default, set):Float = 0.3;
	public var speed(default, set):Float = 1.0;
	public var count(default, set):Int = 6;

	public var sprites:Array<CitroSprite>;
	public var time:Float = 0;
	public var baseX:Float = 0;
	public var baseY:Float = 0;

	public function new(x:Float = 0, y:Float = 0)
	{
		super();
		this.x = x;
		this.y = y;
		baseX = x;
		baseY = y;
		sprites = [];
		for (i in 0...count)
		{
			var spr = new CitroSprite();
			sprites.push(spr);
			add(spr);
		}
	}

	public function loadGraphic(path:String, frameWidth:Float = 0, frameHeight:Float = 0)
	{
		for (i in 0...count)
		{
			sprites[i].loadGraphic(path, frameWidth, frameHeight);
		}
	}

	override public function update():Bool
	{
		time += (CitroG.deltaTime / 1000.0) * speed;
		var PI = 3.14159265;

		for (i in 0...count)
		{
			var spr = sprites[i];
			if (spr == null || !spr.exists)
				continue;

			var modVal = (time + i) % count;
			var currentPower = Math.sin(modVal * (PI / count)) * this.power;
			var shift = (1.0 - (modVal / count)) * -size;
			var scaleMult = 1.0 + (shift * 2.0);
			spr.scale.x = scaleMult;
			spr.scale.y = scaleMult;
			spr.alpha = Math.max(0.0, Math.min(1.0, currentPower));
			var w = spr.width;
			var h = spr.height;
			spr.x = baseX + (w - (w * scaleMult)) / 2;
			spr.y = baseY + (h - (h * scaleMult)) / 2;
		}
		return super.update();
	}

	function set_size(v:Float):Float
	{
		size = v;
		return v;
	}

	function set_power(v:Float):Float
	{
		power = v;
		return v;
	}

	function set_count(v:Int):Int
	{
		count = v;
		return v;
	}

	function set_speed(v:Float):Float
	{
		speed = v;
		return v;
	}
}