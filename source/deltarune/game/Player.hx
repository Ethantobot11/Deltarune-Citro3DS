package deltarune.game;

import citro.object.CitroAnimate;
import citro.object.CitroObject;
import citro.CitroG;
import deltarune.Controls;
import deltarune.assets.GameAssets;
import haxe.Json;

class Player extends CitroAnimate
{
    public var baseSpeed:Float = 240;
    public var speeds:Dynamic = {normal:240, shortrun:360, mediumruntime:0.3, mediumrun:480, longruntime:2.0, longrun:540};
    public var runningTime:Float = 0;
    public var collider:LinkedCollider;
    public var colliderOffset:Array<Int> = [10, 40];
    public var colliderSize:Array<Int> = [16, 36];
    public var interactionCollider:CitroObject;
    public var controlArray:Array<String> = [];
    public var lastAnimation:String = '_';
    public var warped:Bool = false;
    public var running:Bool = false;

    private var animFramerates:Map<String, Float> = new Map();
    public static inline var UP:Int = 0;
    public static inline var DOWN:Int = 1;
    public static inline var LEFT:Int = 2;
    public static inline var RIGHT:Int = 3;
    public var facing:Int = DOWN;

    public function new(x:Float, y:Float, character:String = 'KrisDarkworld')
    {
        super();
        this.x = x;
        this.y = y;
        var cfg = GameAssets.getJSON('config', 'characters/$character', 'json');
        if (cfg != null && cfg.speeds != null) speeds = cfg.speeds;
        var anims = GameAssets.getJSON('animations', 'characters/$character', 'json');
        if (anims == null) {
            trace('Player: missing animations.json for $character');
            makePlaceholder();
        } else {
            var fw:Float = anims.width;
            var fh:Float = anims.height;
            colliderOffset[0] = Std.int(anims.colliderData.x * 2);
            colliderOffset[1] = Std.int(anims.colliderData.y * 2);
            colliderSize[0] = anims.colliderData.even ? 16 : 18;
            colliderSize[1] = Std.int(fh * 1.0);

            var defs:Map<String, Array<Int>> = new Map();
            for (a in anims.animations) {
                defs.set(a.name, a.indicies);
                animFramerates.set(a.name, a.framerate != null ? a.framerate : 8);
            }
            loadFromT3XWithAnims('romfs:/assets/images/characters/$character/spritesheet.t3x', fw, fh, defs);
        }

        collider = new LinkedCollider(x + colliderOffset[0], y + colliderOffset[1], colliderSize[0], colliderSize[1]);
        interactionCollider = new CitroObject();
        interactionCollider.width = 32;
        interactionCollider.height = 52;
        collider.linkedObjects.set(this, {x: colliderOffset[0], y: colliderOffset[1]});
        collider.linkedObjects.set(interactionCollider, {x: 8, y: 16});
        reverseposition();
    }

    function makePlaceholder()
    {
        loadFromT3XWithAnims('romfs:/assets/images/characters/KrisDarkworld/spritesheet.t3x', 18, 38,
            ["down" => [0], "walk-down" => [1,0,2,0], "left" => [3], "walk-left" => [4,3,5,3],
             "up" => [6], "walk-up" => [7,6,8,6], "right" => [9], "walk-right" => [10,9,11,9]]);
    }

    public function playAnimation(?anim:String)
    {
        if (anim == null) anim = lastAnimation;
        if (animFramerates.exists(anim)) framerate = animFramerates[anim];
        if (curAnim != anim || finished) play(anim);
        lastAnimation = anim;
    }

    public function reverseposition()
    {
        collider.x = this.x + colliderOffset[0];
        collider.y = this.y + colliderOffset[1];
        interactionCollider.x = collider.x - 8;
        interactionCollider.y = collider.y - 16;
    }

    override public function update():Bool
    {
        if (controlArray.length <= 0) updateMovement();
        return super.update();
    }

    function updateMovement()
    {
        var up = Controls.up.pressed, down = Controls.down.pressed;
        var left = Controls.left.pressed, right = Controls.right.pressed;
        running = Controls.secondary.pressed;
        if (up && down) { up = false; down = false; }
        if (left && right) { left = false; right = false; }

        if (up || down || left || right) {
            var speed:Float = speeds.normal;
            if (running) {
                runningTime += CitroG.deltaTime / 1000.0;
                speed = runningTime >= speeds.longruntime ? speeds.longrun
                      : runningTime >= speeds.mediumruntime ? speeds.mediumrun
                      : speeds.shortrun;
            } else runningTime = 0;

            var vx:Float = 0, vy:Float = 0;
            if (up) { vy = -speed; facing = UP; }
            if (down) { vy = speed; facing = DOWN; }
            if (left) { vx = -speed; facing = LEFT; }
            if (right) { vx = speed; facing = RIGHT; }
            if (vx != 0 && vy != 0) { vx *= 0.707; vy *= 0.707; }

            collider.x += vx * (CitroG.deltaTime / 1000.0);
            collider.y += vy * (CitroG.deltaTime / 1000.0);

            var d = switch (facing) { case LEFT:"left"; case RIGHT:"right"; case UP:"up"; default:"down"; }
            playAnimation("walk-" + d);
        } else {
            runningTime = 0;
            var d = switch (facing) { case LEFT:"left"; case RIGHT:"right"; case UP:"up"; default:"down"; }
            playAnimation(d);
        }
        this.x = collider.x - colliderOffset[0];
        this.y = collider.y - colliderOffset[1];
        interactionCollider.x = collider.x - 8;
        interactionCollider.y = collider.y - 16;
    }

    override public function destroy()
    {
        if (collider != null) collider.destroy();
        if (interactionCollider != null) interactionCollider.destroy();
        super.destroy();
    }
}

class LinkedCollider extends CitroObject
{
    public var linkedObjects:Map<CitroObject, {x:Float, y:Float}> = new Map();
    public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
    {
        super();
        this.x = x; this.y = y; this.width = width; this.height = height;
    }
}
