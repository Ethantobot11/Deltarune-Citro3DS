package deltarune.game.states.substates;

import citro.state.CitroSubState;
import citro.object.CitroText;
import citro.object.CitroButton;
import citro.object.CitroSprite;
import citro.backend.CitroTween;
import citro.CitroG;
import deltarune.assets.GameAssets;
import deltarune.game.MenuBackground;
import deltarune.Controls;
import deltarune.Game;

class Credits extends CitroSubState
{
	var debugMode:CitroButton;
	var coolCredits:CitroText;
	var pressEsc:CitroText;

	var returning:Bool;
	var timeAfterPress:Float;
	var maxScrollPower:Float = 60;
	var scrollY:Float = 0;
	var baseCreditsY:Float = 240;

	override public function create()
	{
		super.create();
        
       var bg = new MenuBackground();
		add(bg);

		returning = false;
		var coolText = GameAssets.text('romfs:/assets/data/credits/Chapter 1.txt');

		coolCredits = new CitroText(8, baseCreditsY, "");
		coolCredits.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		coolCredits.alignment = LEFT;
		
		if (coolText != null && coolText != '') {
			coolCredits.text = coolText.split("%y%").join("").split("%gry%").join("").split("%r%").join("");
		} else {
			coolCredits.text = "The Spriter's Resource - Sprite Rips\nHaxeFlixel Demos - Shader Code\nBendy Gaming - Created The Port";
		}
		add(coolCredits);

		pressEsc = new CitroText(8, 200, "Press B/Back to go back");
		pressEsc.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		pressEsc.alignment = LEFT;
		pressEsc.setBorderStyle(0xFF000000, 2, OUTLINE);
		pressEsc.alpha = 0;
		add(pressEsc);

		if (!Game.developerMode) {
			debugMode = new CitroButton(140, -75, 120, 30, "Debug Mode", function() {
				Game.developerMode = true;
				close();
			});
			add(debugMode);
		}

		scrollY = 0;
		CitroTween.tween(pressEsc, {alpha: 1}, 2);
		
		if (MenuState.instance != null) {
			if (MenuState.instance.playButton != null) CitroTween.tween(MenuState.instance.playButton, {alpha: 0}, 1);
			if (MenuState.instance.credsButton != null) CitroTween.tween(MenuState.instance.credsButton, {alpha: 0}, 1);
			if (MenuState.instance.optButton != null) CitroTween.tween(MenuState.instance.optButton, {alpha: 0}, 1);
		}
	}

	override public function update(delta:Int)
	{
		super.update(delta);
		final elapsed = delta / 1000.0;
		timeAfterPress += elapsed;

		if (timeAfterPress > 1.5 && !returning) {
			scrollY += (maxScrollPower - scrollY) * elapsed;
			coolCredits.y -= scrollY * elapsed;
			if (debugMode != null) debugMode.y -= scrollY * elapsed;
		}

		if (!returning) {
			if (Controls.back.justPressed) {
				returning = true;
				CitroTween.tween(pressEsc, {alpha: 0}, 1, {
					onComplete: function() {
						if (MenuState.instance != null) MenuState.instance.exitCredits();
						else close();
					}
				});
			}
			if (Controls.up.pressed) {
				timeAfterPress = 0; scrollY = 0;
				coolCredits.y -= 300 * elapsed;
				if (debugMode != null) debugMode.y -= 300 * elapsed;
			}
			if (Controls.down.pressed) {
				timeAfterPress = 0; scrollY = 0;
				coolCredits.y += 300 * elapsed;
				if (debugMode != null) debugMode.y += 300 * elapsed;
			}

			var bottomLimit = (baseCreditsY + coolCredits.height) - CitroG.HEIGHT;
			if (coolCredits.y < -bottomLimit) coolCredits.y = -bottomLimit;
			if (coolCredits.y > 0) coolCredits.y = 0;
		}
		pressEsc.y = 200;

		super.update(delta);
	}
}
