package source.citro.object;

import citro.object.CitroText;
import citro.backend.CitroColor;
import citro.CitroG;

class CitroTypeText extends CitroText
{
	public var delay:Float = 0.05;
	public var autoErase:Bool = false;
	public var completeCallback:Void->Void;

	private var _finalText:String = "";
	private var _length:Int = 0;
	private var _typing:Bool = false;
	private var _timer:Float = 0;

	public function new(x:Float, y:Float, width:Float, text:String)
	{
		super(x, y, text);
		_finalText = text;
	}

	public function start(delay:Float, forceRestart:Bool = false, autoErase:Bool = false, ?callback:Void->Void)
	{
		this.delay = delay;
		this.autoErase = autoErase;
		this.completeCallback = callback;
		if (forceRestart)
		{
			_length = 0;
			text = "";
		}
		_typing = true;
	}

	public function resetText(newText:String)
	{
		_finalText = newText;
		_length = 0;
		text = "";
		_typing = true;
	}

	public function skip()
	{
		_length = _finalText.length;
	}

	override public function update():Bool
	{
		if (_typing && _length < _finalText.length)
		{
			_timer += CitroG.deltaTime / 1000.0;
			if (_timer >= delay)
			{
				_length++;
				_timer = 0;
				text = _finalText.substr(0, _length);

				// Play sound here if needed: CitroG.sound.play("romfs:/assets/sounds/type.cwav");
			}
		}

		if (_typing && _length >= _finalText.length)
		{
			_typing = false;
			if (completeCallback != null)
				completeCallback();
		}

		return super.update();
	}
}