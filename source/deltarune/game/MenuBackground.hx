package deltarune.game;

import citro.object.CitroAnimate;
import citro.object.CitroSprite;
import citro.CitroG;

class MenuBackground extends CitroAnimate {
    public static inline var PATH:String = 'romfs:/assets/images/menuBG.t3x';

    public function new() {
        super();
        var probe = new CitroSprite();
        if (!probe.loadGraphic(PATH)) { probe.destroy(); makePlaceholder(); return; }
        var sheetW:Float = probe.sheetWidth;
        var sheetH:Float = probe.sheetHeight;
        probe.destroy();
        var framesPerRow:Int = 5;
        var fw:Float = sheetW / framesPerRow;
        var fh:Float = sheetH;
        loadFromT3XWithAnims(PATH, fw, fh, ["cool" => [0,1,2,3,4]]);
        framerate = 8;
        looped = true;
        play("cool");
        scale.x = CitroG.WIDTH / fw;
        scale.y = CitroG.HEIGHT / fh;
        screenCenter(XY);
    }

    function makePlaceholder() {
        loadFromT3XWithAnims(PATH, 320, 240, ["cool" => [0]]);
        play("cool");
    }
}
