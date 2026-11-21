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
	var speed:Float;
	var pausespeed:Float;
	var autocontinue:Bool;
	var skippable:Bool;
}