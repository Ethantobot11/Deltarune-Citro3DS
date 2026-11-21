package citro.backend;

class CitroSoundSystem {
    public var volume:Float = 1.0;
    public var muted:Bool = false;
    public var activeSounds:Array<CitroSound> = [];
    public var currentMusic:CitroSound = null;

    public function new() {
        #if (!wiiu || !cafe)
        untyped __cpp__("cwavUseEnvironment(0)");
        #end
    }

    public function playMusic(path:String, ?vol:Float = 1.0, ?looped:Bool = true):Void {
        if (currentMusic != null && currentMusic.path == path && currentMusic.isPlaying && currentMusic.looped == looped) {
            return;
        }
        
        stopMusic();
        
        currentMusic = new CitroSound(path);
        currentMusic.volume = muted ? 0.0 : (vol != null ? vol : this.volume);
        currentMusic.looped = looped;
        currentMusic.play();
        activeSounds.push(currentMusic);
    }

    public function stopMusic():Void {
        if (currentMusic != null) {
            currentMusic.stop();
            activeSounds.remove(currentMusic);
            currentMusic = null;
        }
    }

    public function play(path:String, ?vol:Float = 1.0, ?looped:Bool = false):CitroSound {
        var sound = new CitroSound(path);
        sound.volume = muted ? 0.0 : (vol != null ? vol : this.volume);
        sound.looped = looped;
        sound.play();
        activeSounds.push(sound);
        return sound;
    }

    public function load(path:String):CitroSound {
        var sound = new CitroSound(path);
        sound.volume = muted ? 0.0 : this.volume;
        activeSounds.push(sound);
        return sound;
    }

    public function update():Void {
        for (sound in activeSounds) {
            sound.update();
        }
    }
}
