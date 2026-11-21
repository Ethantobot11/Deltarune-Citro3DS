package deltarune.game.states.substates;

import citro.state.CitroSubState;
import citro.object.CitroText;

class SavingState extends CitroSubState
{
	var _temp_save_text:CitroText;
	var save_id:Int;

	override public function create()
	{
		super.create();
		_temp_save_text = new CitroText(16, 16, 'Selected < $save_id >, Press [A] to save');
		_temp_save_text.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		add(_temp_save_text);
	}

	override public function update(delta:Int)
	{
		super.update(delta);
	}

	public function createTestSaveString(id:Int):String
	{
		var save_name = Options.grabSaveData('name', null, id);
		var raw_time = Options.grabSaveData('play_time', null, id);
		var save_text = "";

		if (save_name == NoSuccess.NoSaveData || save_name == null)
		{
			save_text = Options.defaultData.name;
		}
		else
		{
			save_text = Std.string(save_name);
		}

		save_text += " | Time : ";

		if (raw_time == NoSuccess.NoSaveData || raw_time == null)
		{
			save_text += "N/A";
		}
		else
		{
			var seconds = Std.int(Std.parseFloat(Std.string(raw_time)));
			var mins = Std.int(seconds / 60);
			var secs = seconds % 60;
			save_text += mins + ":" + (secs < 10 ? "0" + secs : Std.string(secs));
		}
		return save_text;
	}
}