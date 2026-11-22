package deltarune.game;

typedef DialogueStructure =
{
	var style:String;
	var dialogue:Array<DialogueLine>;
}

typedef DialogueLine =
{
	var portrait:String;
	var text:String;
	@:optional var speed:Float;
	@:optional var pausespeed:Float;
	@:optional var autocontinue:Bool;
	@:optional var skippable:Bool;
}