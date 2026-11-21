package deltarune;

import citro.object.CitroText;
import citro.CitroG;
import deltarune.game.states.substates.Options;

@:headerInclude("3ds.h")
@:headerInclude("3ds/os.h")
class GameFps extends CitroText
{
	public static var memoryPeak:Int = 0;

	public function new()
	{
		super(10, 8, "");
		loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		this.bottom = true;
	}

	public function updateFPS(delta:Float)
	{
		var dt = CitroG.deltaTime > 0 ? CitroG.deltaTime : 16;
		var currentFPS:Int = Math.round(1000.0 / dt);
		var memoryUsed:Int = untyped __cpp__("osGetMemRegionUsed(MEMREGION_APPLICATION)");

		if (memoryUsed > memoryPeak) memoryPeak = memoryUsed;

		if (Options.generalData.show_fps || Options.generalData.show_memory)
		{
			var displayText = "";
			if (Options.generalData.show_fps) displayText += "FPS: " + currentFPS + "\n";
			if (Options.generalData.show_memory)
				displayText += "RAM: " + formatBytes(memoryUsed) + "\nPeak: " + formatBytes(memoryPeak);
			text = displayText;
		}
		else text = "";
	}

	public static function formatBytes(bytes:Int):String
	{
		if (bytes > 1000000000) return Std.string(Math.round(bytes / 1000000000 * 100) / 100) + " GB";
		else if (bytes > 1000000) return Std.string(Math.round(bytes / 1000000 * 100) / 100) + " MB";
		else if (bytes > 1000) return Std.string(Math.round(bytes / 1000 * 100) / 100) + " KB";
		else return bytes + " B";
	}
}
