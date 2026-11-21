package deltarune.editors;

import citro.state.CitroState;
import citro.object.CitroText;
import citro.CitroG;
import haxe3ds.services.HID;
import haxe3ds.services.HID.HIDKey;
import deltarune.game.BattleBox;
import deltarune.game.Point;
import deltarune.Controls;

class BattleBoxTestState extends CitroState
{
	var box:BattleBox;
	var movingPoint:Point<Float>;
	var infoText:CitroText;

	override function create()
	{
		super.create();

		box = new BattleBox();
		box.bottom = true;
		add(box);

		infoText = new CitroText(10, 10, "Touch corners to move\nA: Toggle Middle\nX: Reset Box\nB: Back");
		infoText.bottom = true;
		infoText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		add(infoText);
	}

	override function update(delta:Int)
	{
		super.update(delta);

		if (Controls.back.justPressed)
		{
			CitroG.switchState(new deltarune.game.states.MenuState());
		}

		if (Controls.primary.justPressed)
		{
			box.showMiddle = !box.showMiddle;
		}

		if (Controls.secondary.justPressed)
		{
			box.resetBox();
		}

		if (HID.keyPressed(HIDKey.TOUCH))
		{
			var touch = HID.touch;
			var lowestDist = 1000.0;
			movingPoint = null;

			var corners = [box.tlCorner, box.blCorner, box.trCorner, box.brCorner];
			var touchPoint = new Point<Float>(touch.px, touch.py, 0);

			for (corner in corners)
			{
				var dist = Point.distance2D(corner, touchPoint);
				if (dist < lowestDist)
				{
					lowestDist = dist;
					movingPoint = corner;
				}
			}

			if (lowestDist > 30.0)
			{
				movingPoint = null;
			}
		}

		if (HID.keyHeld(HIDKey.TOUCH) && movingPoint != null)
		{
			var touch = HID.touch;
			movingPoint.x = touch.px;
			movingPoint.y = touch.py;
		}

		if (HID.keyUp(HIDKey.TOUCH))
		{
			movingPoint = null;
		}
	}
}