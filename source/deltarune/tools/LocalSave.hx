package deltarune.tools;

import citro.CitroSave;

class LocalSave
{
	public var data:Dynamic;

	private var save:CitroSave;

	public function new()
	{
		save = new CitroSave();
		data = save.data;
	}

	public function bind(name:String, ?path:String):Bool
	{
		return save.status == SUCCESSFUL;
	}

	public function flush():Bool
	{
		return save.flush();
	}

	public function erase():Void
	{
		save.delete(true);
		data = {};
	}
}