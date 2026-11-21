package deltarune;

import citro.CitroG;
import citro.object.CitroSprite;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;
import citro.backend.CitroEase;
import haxe3ds.services.HID;
import haxe3ds.services.HID.HIDKey;

using StringTools;

typedef HIDKeys = Array<UInt32>;

class Controls
{
	public static var primary(default, never):DigitalButton = new DigitalButton([HIDKey.A, HIDKey.START], [HIDKey.A]);
	public static var secondary(default, never):DigitalButton = new DigitalButton([HIDKey.X, HIDKey.SELECT], [HIDKey.X, HIDKey.L]);
	public static var tetritary(default, never):DigitalButton = new DigitalButton([HIDKey.Y, HIDKey.R], [HIDKey.Y, HIDKey.R]);
	public static var back(default, never):DigitalButton = new DigitalButton([HIDKey.B, HIDKey.SELECT], [HIDKey.B]);

	public static var left(default, never):DigitalButton = new DigitalButton([HIDKey.LEFT, HIDKey.CPAD_LEFT], [HIDKey.DLEFT, HIDKey.CPAD_LEFT]);
	public static var down(default, never):DigitalButton = new DigitalButton([HIDKey.DOWN, HIDKey.CPAD_DOWN], [HIDKey.DDOWN, HIDKey.CPAD_DOWN]);
	public static var up(default, never):DigitalButton = new DigitalButton([HIDKey.UP, HIDKey.CPAD_UP], [HIDKey.DUP, HIDKey.CPAD_UP]);
	public static var right(default, never):DigitalButton = new DigitalButton([HIDKey.RIGHT, HIDKey.CPAD_RIGHT], [HIDKey.DRIGHT, HIDKey.CPAD_RIGHT]);

	static var activeToast:CitroSprite;
	static var inactiveToast:CitroSprite;

	public static function addControllerToast()
	{
		activeToast = new CitroSprite();
		activeToast.loadGraphic("romfs:/assets/images/controllerConnected.t3x");
		activeToast.x = CitroG.WIDTH - 80;
		activeToast.y = CitroG.HEIGHT;

		inactiveToast = new CitroSprite();
		inactiveToast.loadGraphic("romfs:/assets/images/controllerRemoved.t3x");
		inactiveToast.x = CitroG.WIDTH - 80;
		inactiveToast.y = CitroG.HEIGHT;
	}

	public static function controllerConnectToast()
	{
		if (activeToast == null)
			return;
		CitroG.state.add(activeToast);
		CitroTween.tween(activeToast, {y: CitroG.HEIGHT - 64}, 0.5, {
			ease: CitroEase.CIRC_OUT,
			onComplete: function()
			{
				CitroTimer.start(0.5, function()
				{
					CitroTween.tween(activeToast, {y: CitroG.HEIGHT}, 0.5, {
						ease: CitroEase.CIRC_IN,
						onComplete: function()
						{
							CitroG.state.remove(activeToast);
							activeToast.destroy();
						}
					});
				});
			}
		});
	}

	public static function controllerRemoveToast()
	{
		if (inactiveToast == null)
			return;
		CitroG.state.add(inactiveToast);
		CitroTween.tween(inactiveToast, {y: CitroG.HEIGHT - 64}, 0.5, {
			ease: CitroEase.CIRC_OUT,
			onComplete: function()
			{
				CitroTimer.start(0.5, function()
				{
					CitroTween.tween(inactiveToast, {y: CitroG.HEIGHT}, 0.5, {
						ease: CitroEase.CIRC_IN,
						onComplete: function()
						{
							CitroG.state.remove(inactiveToast);
							inactiveToast.destroy();
						}
					});
				});
			}
		});
	}
}

class DigitalButton
{
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	public var justReleased(get, never):Bool;

	var keys:HIDKeys;
	var buttons:HIDKeys;

	public function new(keybindings:HIDKeys, buttonss:HIDKeys)
	{
		keys = keybindings;
		buttons = buttonss;
	}

	function get_pressed():Bool
	{
		for (k in keys)
			if (HID.keyHeld(k))
				return true;
		for (b in buttons)
			if (HID.keyHeld(b))
				return true;
		return false;
	}

	function get_justPressed():Bool
	{
		for (k in keys)
			if (HID.keyPressed(k))
				return true;
		for (b in buttons)
			if (HID.keyPressed(b))
				return true;
		return false;
	}

	function get_justReleased():Bool
	{
		for (k in keys)
			if (HID.keyUp(k))
				return true;
		for (b in buttons)
			if (HID.keyUp(b))
				return true;
		return false;
	}

	public function changeControls(keybindings:HIDKeys, buttonss:HIDKeys)
	{
		keys = keybindings;
		buttons = buttonss;
	}
}