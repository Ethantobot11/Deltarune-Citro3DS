package citro.object;

import citro.CitroG;
import citro.backend.CitroColor;
import haxe3ds.services.HID;
import haxe3ds.services.HID.HIDKey;

class CitroButton extends CitroSprite
{
	public var label:CitroText;
	public var onClicked:Void->Void;

	private var isHovered:Bool = false;
	private var baseColor:CitroColor;
	private var hoverColor:CitroColor;

	public function new(X:Float, Y:Float, Width:Float, Height:Float, LabelText:String, ?OnClick:Void->Void)
	{
		super(X, Y);
		this.bottom = true;
		makeGraphic(Width, Height, 0xFF444444);
		baseColor = 0xFF444444;
		hoverColor = 0xFFFFD700;
		label = new CitroText(X, Y, LabelText);
		label.alignment = LEFT;
		label.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		label.bottom = this.bottom;
		onClicked = OnClick;
	}

	override public function update():Bool
	{
		label.bottom = this.bottom;
		label.alpha = this.alpha;
		label.color = 0xFFFFFFFF;
		var res = super.update();
		label.x = this.x + (width - label.width) / 2;
		label.y = this.y + (height - label.height) / 2;
		if (!label.isDestroyed)
			label.update();
		if (bottom && HID.keyHeld(HIDKey.TOUCH))
		{
			var t = HID.touch;
			isHovered = (t.px >= x && t.px <= x + width && t.py >= y && t.py <= y + height);
		}
		else
		{
			isHovered = false;
		}
		if (isHovered && (HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.TOUCH)))
		{
			if (onClicked != null)
				onClicked();
		}
		color = isHovered ? hoverColor : baseColor;
		return res;
	}
}