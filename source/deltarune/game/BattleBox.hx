package deltarune.game;

import citro.CitroG;
import citro.object.CitroObject;
import citro.backend.CitroColor;
import citro.c2d.CitroObjectDraw;

class BattleBox extends CitroObject
{
	public var showMiddle:Bool = false;
	public var tlCorner:Point<Float> = new Point<Float>(0, 0, 0);
	public var blCorner:Point<Float> = new Point<Float>(0, 0, 0);
	public var trCorner:Point<Float> = new Point<Float>(0, 0, 0);
	public var brCorner:Point<Float> = new Point<Float>(0, 0, 0);
	public var middlePoint(default, null):Point<Float> = new Point<Float>(0, 0, 0);

	public var fillColor:CitroColor = 0xFF000000;
	public var lineColor:CitroColor = 0xFF00EE11;

	public function new()
	{
		super();
		width = 1;
		height = 1;
		tlCorner.x = blCorner.x = (CitroG.WIDTH * 0.5) - 100;
		trCorner.x = brCorner.x = (CitroG.WIDTH * 0.5) + 100;
		tlCorner.y = trCorner.y = (CitroG.HEIGHT * 0.5) - 100;
		blCorner.y = brCorner.y = (CitroG.HEIGHT * 0.5) + 100;
	}

	public function resetBox()
	{
		tlCorner.x = blCorner.x = (CitroG.WIDTH * 0.5) - 100;
		trCorner.x = brCorner.x = (CitroG.WIDTH * 0.5) + 100;
		tlCorner.y = trCorner.y = (CitroG.HEIGHT * 0.5) - 100;
		blCorner.y = brCorner.y = (CitroG.HEIGHT * 0.5) + 100;
	}

	override public function update():Bool
	{
		if (!visible)
			return false;
		CitroObjectDraw.drawRect(tlCorner.x, tlCorner.y, trCorner.x - tlCorner.x, blCorner.y - tlCorner.y, [lineColor]);
		middlePoint = Point.findMiddle([tlCorner, trCorner, blCorner, brCorner]);
		if (showMiddle)
			CitroObjectDraw.drawRect(middlePoint.x - 2, middlePoint.y - 2, 4, 4, [0xFFFFFFFF]);
		return super.update();
	}
}

class Point<T>
{
	public var x:T;
	public var y:T;
	public var z:T;
	public var r(get, set):T;
	public var g(get, set):T;
	public var b(get, set):T;

	function get_r()
		return x;

	function get_g()
		return y;

	function get_b()
		return z;

	function set_r(value:T)
		return x = value;

	function set_g(value:T)
		return y = value;

	function set_b(value:T)
		return z = value;

	public function new(?x:T, ?y:T, ?z:T)
	{
		if (x != null)
			this.x = x;
		if (y != null)
			this.y = y;
		if (z != null)
			this.z = z;
	}

	public static function fromFlxPoint(flxX:Float, flxY:Float, ?z:Float = 0):Point<Float>
	{
		return new Point<Float>(flxX, flxY, z);
	}

	public static inline function distance(p:Point<Float>, point:Point<Float>):Float
	{
		return Math.sqrt(Math.pow((p.x - point.x), 2) + Math.pow((p.y - point.y), 2) + Math.pow((p.z - point.z), 2));
	}

	public static inline function distance2D(p:Point<Float>, point:Point<Float>):Float
	{
		return Math.sqrt(Math.pow((p.x - point.x), 2) + Math.pow((p.y - point.y), 2));
	}

	public static inline function distanceMouse(p:Point<Float>):Float
	{
		return 0.0;
	}

	public static inline function findMiddle(points:Array<Point<Float>>):Point<Float>
	{
		var totalPoint = new Point<Float>(0, 0, 0);
		for (pnt in points)
		{
			totalPoint.x += pnt.x;
			totalPoint.y += pnt.y;
			totalPoint.z += pnt.z;
		}
		totalPoint.x /= points.length;
		totalPoint.y /= points.length;
		totalPoint.z /= points.length;
		return totalPoint;
	}
}