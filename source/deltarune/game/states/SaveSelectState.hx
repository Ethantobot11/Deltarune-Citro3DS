package deltarune.game.states;

import citro.state.CitroState;
import citro.object.CitroText;
import citro.object.CitroSprite;
import citro.CitroG;
import deltarune.Controls;
import deltarune.Game;
import deltarune.tools.LocalSave;
import deltarune.game.states.substates.Options;
import deltarune.game.states.substates.Options.NoSuccess;

class SaveSelectState extends CitroState
{
	public static var instance:SaveSelectState;

	public var saveSelected:Int = 0;
	var saveBox:CitroSprite;
	var slotTexts:Array<CitroText> = [];
	var titleText:CitroText;
	var promptText:CitroText;
	var chapterId:String;

	override public function create()
	{
		super.create();
		instance = this;
		chapterId = Game.currentChapterId;

		CitroG.sound.playMusic('romfs:/assets/music/DRONE.cwav', 0.8, true);
		var bg = new CitroSprite(0, 0);
		bg.makeGraphic(400, 240, 0xFF000000);
		add(bg);

		titleText = new CitroText(20, 8, 'Select a save file');
		titleText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		titleText.alignment = LEFT;
		add(titleText);
		for (i in 0...3) {
			var t = new CitroText(20, 60 + (i * 50), "");
			t.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
			t.alignment = LEFT;
			slotTexts.push(t);
			add(t);
		}

		promptText = new CitroText(20, 210, "A: Start   X: Erase   B: Back");
		promptText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		promptText.alignment = LEFT;
		promptText.color = 0xFF808080;
		add(promptText);
		if (Game.framerateDisplay != null) add(Game.framerateDisplay);

		refreshSlots();
	}

	function refreshSlots()
	{
		for (i in 0...3) {
			var name = Options.grabSaveData('name', chapterId, i);
			var rawTime = Options.grabSaveData('play_time', chapterId, i);

			var nameStr = (name == NoSuccess.NoSaveData || name == null) ? "EMPTY" : Std.string(name);
			var timeStr = (rawTime == NoSuccess.NoSaveData || rawTime == null) ? "N/A" : formatTime(Std.parseFloat(Std.string(rawTime)));

			slotTexts[i].text = 'FILE $i - ${nameStr}  |  ${timeStr}';
			slotTexts[i].color = (i == saveSelected) ? 0xFFFFFF00 : 0xFFFFFFFF;
		}
	}

	function formatTime(seconds:Float):String
	{
		var s = Std.int(seconds);
		var h = Std.int(s / 3600);
		var m = Std.int((s % 3600) / 60);
		var sec = s % 60;
		var mStr = m < 10 ? "0" + m : Std.string(m);
		var secStr = sec < 10 ? "0" + sec : Std.string(sec);
		return '$h:$mStr:$secStr';
	}

	override public function update(delta:Int)
	{
		super.update(delta);
		if (Game.framerateDisplay != null) Game.framerateDisplay.updateFPS(delta / 1000.0);

		if (Controls.up.justPressed) {
			saveSelected = (saveSelected + 2) % 3;
			//CitroG.sound.play('romfs:/assets/sounds/menumove.cwav');
			refreshSlots();
		}
		if (Controls.down.justPressed) {
			saveSelected = (saveSelected + 1) % 3;
			refreshSlots();
		}

		if (Controls.primary.justPressed) {
			Options.save_destination = chapterId;
			Options.save_id = saveSelected;
			Options.loadNewSave(chapterId, saveSelected);
			//CitroG.sound.play('romfs:/assets/sounds/save.cwav');
			CitroG.switchState(new TransitionState(() -> new PlayState(Options.currentData.room_name)));
		}

		if (Controls.secondary.justPressed) {
			var temp = new LocalSave();
			temp.bind('${chapterId}_${saveSelected}', 'savedata');
			temp.erase();
			refreshSlots();
		}

		if (Controls.back.justPressed) {
			//CitroG.sound.play('romfs:/assets/sounds/hurt.cwav');
			CitroG.switchState(new ChapterSelectState());
		}
		CitroG.sound.play('romfs:/assets/sounds/menumove.cwav');
	}
}
