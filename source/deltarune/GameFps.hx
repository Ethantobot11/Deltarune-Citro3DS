package deltarune;

import citro.CitroG;
import citro.object.CitroText;
import citro.util.CitroStringUtil;

class GameFps extends CitroText
{
	public static var memoryPeak:Int = 0;

	private var cachedMem:Int = 0;
	private var times:Array<Float> = [];
	private var currentTime:Float = 0;
	private var currentFPS:Int = 0;
	private var cacheCount:Int = 0;

	public function new()
	{
		super(10, 8, "FPS: 0");
		loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
	}

	public function updateFPS(delta:Float)
	{
		currentTime += delta;
		times.push(currentTime);
		while (times.length > 0 && times[0] < currentTime - 1000)
		{
			times.shift();
		}
		currentFPS = Math.round((times.length + cacheCount) / 2);
		var memoryUsed:Int = 0;

		text = 'FPS: $currentFPS\nMem: ${CitroStringUtil.formatBytes(memoryUsed)}\nPeak: ${CitroStringUtil.formatBytes(memoryPeak)}';
		cachedMem = memoryUsed;
		cacheCount = times.length;
	}
}