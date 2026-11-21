package deltarune;

import citro.CitroG;
import citro.object.CitroSprite;

class ConsoleBorder extends CitroSprite
{
	public static var ids:Map<String, Int> = new Map();
	public static var names:Map<Int, String> = new Map();
	public static var borderName:String;

	public var curId(default, null):Int;

	var nextId:Null<Int>;
	var state:String = 'done';
	var fadeTimer:Float = 0;

	public function new()
	{
		super();
		loadGraphic("romfs:/assets/images/borders.t3x");

		addBorder('default', 0);
		addBorder('forest', 1);
		addBorder('dark_castle', 2);
		addBorder('castle', 2);
		addBorder('sunset', 3);
		addBorder('cyber', 4);
		addBorder('queen_castle', 5);
		addBorder('queen', 5);
		curId = 0;
	}

	public function switchToId(id:Int = 0)
	{
		nextId = id;
		state = 'fadeOut';
		fadeTimer = 0;
	}

	public function switchTo(id:String = 'default')
	{
		if (ids.get(id) == curId)
			return;
		nextId = ids.get(id);
		if (nextId == null)
			nextId = 0;
		state = 'fadeOut';
		fadeTimer = 0;
	}

	function addBorder(name:String, id:Int)
	{
		ids.set(name, id);
		names.set(id, name);
	}

	override function update():Bool
	{
		var elapsed = CitroG.deltaTime / 1000.0;
		var scale = Math.max(CitroG.WIDTH / 400.0, CitroG.HEIGHT / 240.0);
		this.scale.x = scale;
		this.scale.y = scale;
		this.x = (CitroG.WIDTH - (400 * scale)) / 2;
		this.y = (CitroG.HEIGHT - (240 * scale)) / 2;
		this.srcY = 240 * curId;
		this.srcHeight = 240;
		this.useSrcRect = true;

		switch (state)
		{
			case 'fadeOut':
				fadeTimer += elapsed;
				this.alpha = 1.0 - (fadeTimer / 0.6);
				if (this.alpha <= 0)
				{
					this.alpha = 0;
					state = 'fadeIn';
					curId = nextId;
				}
			case 'fadeIn':
				fadeTimer += elapsed;
				this.alpha = fadeTimer / 0.6;
				if (this.alpha >= 1)
				{
					this.alpha = 1;
					state = 'done';
				}
			default:
				this.alpha = 1;
		}
		return super.update();
	}
}

class SingleBorder extends CitroSprite
{
	var name(get, set):String;

	inline function get_name()
		return ConsoleBorder.names.get(Std.int(frame));

	inline function set_name(value:String)
	{
		frame = ConsoleBorder.ids.get(value);
		return value;
	}
}