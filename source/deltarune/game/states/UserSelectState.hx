package deltarune.game.states;

import citro.state.CitroState;
import citro.object.CitroText;
import deltarune.Game;
#if sys
import sys.FileSystem;
#end

class UserSelectState extends CitroState
{
	var userListText:CitroText;

	override public function create()
	{
		super.create();
		Game.initialize();

		var users:Array<String> = [];

		#if sys
		var saveDataDir = 'sdmc:/DELTASHIT/savedata/global/';
		
		if (FileSystem.exists(saveDataDir))
		{
			for (saveFile in FileSystem.readDirectory(saveDataDir))
			{
				if (FileSystem.isDirectory(saveDataDir + saveFile)
					|| saveFile == "_userlist"
					|| saveFile == "_default"
					|| saveFile == "save.json")
					continue;

				if (saveFile.endsWith(".json")) {
					users.push(saveFile.substr(0, saveFile.length - 5));
				}
			}
		}
		#end

		users.sort(sortAlphabetically);
		userListText = new CitroText(20, 20, "Found " + users.length + " save files.");
		userListText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		add(userListText);
	}

	private static function sortAlphabetically(a:String, b:String):Int
	{
		if (a == b)
			return 0;
		var al = a.toLowerCase();
		var bl = b.toLowerCase();
		for (index in 0...Std.int(Math.min(a.length, b.length)))
		{
			var av = al.charCodeAt(index);
			var bv = bl.charCodeAt(index);
			if (av < bv)
				return -1;
			else if (bv < av)
				return 1;
		}
		return a.length > b.length ? 1 : -1;
	}
}
