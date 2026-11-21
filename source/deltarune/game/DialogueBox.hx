package deltarune.game;

import citro.object.CitroGroup;
import deltarune.data.BasicJSONTypes;

class DialogueBox extends CitroGroup
{
	var writer:Dynamic;
	var currentStyle:DialogueStyle;

	public function new()
	{
		super();
	}

	override public function update():Bool
	{
		return super.update();
	}

	public function setStyle(style:DialogueStyle) {}
}

class Portrait extends CitroGroup {}

typedef DialogueStyle =
{
	spriteOrder:Array<String>,
	basicSprites:Array<DialogueStyleSpriteData>,
	portraits:Array<DialogueStylePortraitData>,
	text:DialogueStyleTextData
}

typedef DialogueStyleMember =
{
	label:String,
	position:JSON2DPoint,
	?scale:JSON2DPoint
}

typedef DialogueStyleSpriteData =
{
	> DialogueStyleMember,
	image:String,
	?animation:Array<DSSAnimationData>
}

typedef DSSAnimationData =
{
	name:String
}

typedef DialogueStylePortraitData =
{
	> DialogueStyleMember,
	positionAlignment:String,
	?isDefault:Bool,
	?textPositionOffset:JSON2DPoint,
	?textWidthOffset:Float
}

typedef DialogueStyleTextData =
{
	> DialogueStyleMember,
	defaultFont:String,
	?monoSpacing:Float,
	lineSpacing:Float,
	tabSpacing:Float
}