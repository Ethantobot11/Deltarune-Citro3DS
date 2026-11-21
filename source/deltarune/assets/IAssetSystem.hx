package deltarune.assets;

import haxe.io.Bytes;

interface IAssetSystem
{
	public var label:String;
	public function list(directory:String, subdirectory:Bool = false):Array<String>;
	public function exists(file:String):Bool;
	public function directoryExists(directory:String):Bool;
	public function text(file:String):String;
	public function bytes(file:String):Bytes;
	public function font(file:String):Dynamic;
	public function bitmap(image:String):Dynamic;
	public function sound(sound:String):Dynamic;
}