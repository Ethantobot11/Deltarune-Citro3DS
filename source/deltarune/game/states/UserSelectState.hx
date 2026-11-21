package deltarune.game.states;

import citro.state.CitroState;
import deltarune.Game;
#if sys
import sys.FileSystem;
#end

class UserSelectState extends CitroState
{
	override public function create()
	{
		Game.initialize();
		super.create();

		var users:Array<String> = [];

		#if sys
		var saveDataDir = 'sdmc:/Deltarune-Citro3DS/savedata/global/';
		if (FileSystem.exists(saveDataDir))
		{
			for (saveFile in FileSystem.readDirectory(saveDataDir))
			{
				if (FileSystem.isDirectory(saveDataDir + saveFile)
					|| saveFile == "_userlist"
					|| saveFile == "_default"
					|| saveFile == "save.json")
					continue;
				users.push(saveFile);
			}
		}
		#end

		users.sort(sortAlphabetically);
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