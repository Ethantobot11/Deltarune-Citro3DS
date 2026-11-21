package deltarune.shaders;

import citro.object.CitroGroup;
import citro.object.CitroSprite;
import citro.CitroG;

enum WiggleEffectType
{
	DREAMY;
	WAVY;
	HEAT_WAVE_HORIZONTAL;
	HEAT_WAVE_VERTICAL;
	FLAG;
}

/**
 * CPU-based approximation of the Wiggle effect using horizontal slice offsetting.
 */
class WiggleEffect extends CitroGroup
{
	public var effectType(default, set):WiggleEffectType = DREAMY;
	public var waveSpeed(default, set):Float = 1.0;
	public var waveFrequency(default, set):Float = 10.0;
	public var waveAmplitude(default, set):Float = 5.0;

	public var slices:Array<CitroSprite>;
	public var time:Float = 0;
	public var numSlices:Int = 20;
	public var sliceHeight:Float = 0;
	public var basePath:String = "";

	public function new(x:Float = 0, y:Float = 0, width:Float = 400, height:Float = 240)
	{
		super();
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		slices = [];
	}

	public function loadGraphic(path:String)
	{
		basePath = path;
		sliceHeight = height / numSlices;
		for (i in 0...numSlices)
		{
			var spr = new CitroSprite();
			spr.loadGraphic(path);
			spr.setSourceRect(0, i * sliceHeight, width, sliceHeight);
			spr.x = x;
			spr.y = y + (i * sliceHeight);
			slices.push(spr);
			add(spr);
		}
	}

	override public function update():Bool
	{
		time += (CitroG.deltaTime / 1000.0) * waveSpeed;

		for (i in 0...numSlices)
		{
			var spr = slices[i];
			if (spr == null || !spr.exists)
				continue;

			var yPos = y + (i * sliceHeight);
			var offset:Float = 0;

			switch (effectType)
			{
				case DREAMY:
					offset = Math.sin(yPos * waveFrequency + time) * waveAmplitude;
					spr.x = x + offset;
					spr.y = yPos;
				case WAVY:
					offset = Math.sin(x * waveFrequency + time) * waveAmplitude;
					spr.y = yPos + offset;
					spr.x = x;
				case HEAT_WAVE_HORIZONTAL:
					offset = Math.sin(yPos * waveFrequency + time) * waveAmplitude;
					spr.x = x + offset;
					spr.y = yPos;
				case HEAT_WAVE_VERTICAL:
					offset = Math.sin(yPos * waveFrequency + time) * waveAmplitude;
					spr.y = yPos + offset;
					spr.x = x;
				case FLAG:
					var flagX = Math.sin(yPos * waveFrequency + 10.0 * x + time) * waveAmplitude;
					var flagY = Math.sin(x * waveFrequency + 5.0 * yPos + time) * waveAmplitude;
					spr.x = x + flagX;
					spr.y = yPos + flagY;
			}
		}
		return super.update();
	}

	function set_effectType(v:WiggleEffectType):WiggleEffectType
	{
		effectType = v;
		return v;
	}

	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		return v;
	}
}