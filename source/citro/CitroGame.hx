package citro;

#if (!wiiu || !cafe)

import citro.backend.CitroTimer;
import citro.backend.CitroTween;
import citro.state.CitroState;

import haxe3ds.applet.Error;
import haxe3ds.services.APT;
import haxe3ds.services.GFX;
import haxe3ds.services.RomFS;
import haxe3ds.OS;

import cpp.UInt64;

/**
 * Literally everything to set up citro engine.
 */
@:headerCode("
#include <citro2d.h>
#include <citro3d.h>
extern C3D_RenderTarget* topScreen;
extern C3D_RenderTarget* bottomScreen;
")

@:cppFileCode('
C3D_RenderTarget* topScreen = nullptr;
C3D_RenderTarget* bottomScreen = nullptr;
')
class CitroGame {
	@:noCompletion
	public static var _shouldQuit:Bool = false;

	static function renderObjectsForScreen(state:CitroState, bottom:Bool) {
		for (member in state.members) {
			if (member == null) continue;
			if (member.isDestroyed) {
				state.members.remove(member);
				continue;
			}
			if (member.bottom != bottom) continue;
			member.update(); 
		}
	}

	static function renderState(state:CitroState) {
		untyped __cpp__("C2D_SceneBegin(topScreen)");
		renderObjectsForScreen(state, false);
		untyped __cpp__("C2D_SceneBegin(bottomScreen)");
		renderObjectsForScreen(state, true);
	}

	public static function start(state:CitroState) {
		if (state == null) return;

		GFX.init();
		RomFS.init();

		untyped __cpp__('
			C2D_Init(20000);
			C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
			C2D_Prepare();
			topScreen = C2D_CreateScreenTarget(GFX_TOP, GFX_LEFT);
			bottomScreen = C2D_CreateScreenTarget(GFX_BOTTOM, GFX_LEFT);
		');

		(CitroG.state = state).create();

		var lastFrame:Int = OS.time.toInt();

		while (APT.mainLoop() && !_shouldQuit) {
			final now:Int = OS.time.toInt();
			final target = CitroG.targetFps > 0 ? CitroG.targetFps : 60;
			final interval = Std.int(1000 / target);
			var frameDelta = now - lastFrame;
			if (frameDelta < 1) frameDelta = 1;
			if (frameDelta > 100) frameDelta = 100;
			CitroG.deltaTime = frameDelta;
			lastFrame = now;

			untyped __cpp__('
				C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
				C2D_TargetClear(topScreen, 0xFF1D1D24);
				C2D_TargetClear(bottomScreen, 0xFF000000);
			');

			CitroTween.update();
			CitroTimer.update();
			CitroG.sound.update();
			CitroG.state.update(CitroG.deltaTime);

			final sub = CitroG.substate;
			if (sub != null) sub.update(CitroG.deltaTime);

			renderState(CitroG.state);
			if (sub != null) renderState(sub);

			if (CitroG.globalOverlay != null && !CitroG.globalOverlay.isDestroyed) {
				if (CitroG.globalOverlay.bottom) {
					untyped __cpp__("C2D_SceneBegin(bottomScreen)");
				} else {
					untyped __cpp__("C2D_SceneBegin(topScreen)");
				}
				CitroG.globalOverlay.update();
			}

			if (CitroG.globalOverlay2 != null && !CitroG.globalOverlay2.isDestroyed)
			{
				if (CitroG.globalOverlay2.bottom)
				{
					untyped __cpp__("C2D_SceneBegin(bottomScreen)");
				}
				else
				{
					untyped __cpp__("C2D_SceneBegin(topScreen)");
				}
				CitroG.globalOverlay2.update();
			}

			untyped __cpp__('
				C2D_Flush();
				C3D_FrameEnd(0);
			');

			final spent = OS.time.toInt() - now;
			if (spent < interval) {
				Sys.sleep((interval - spent) / 1000.0);
			}
		}

		untyped __cpp__('
			C3D_Fini();
			C2D_Fini();
		');
		RomFS.exit();
		GFX.exit();
	}
	#end
}
