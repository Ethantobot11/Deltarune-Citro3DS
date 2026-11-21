package deltarune.game.states;

import citro.CitroG;
import citro.state.CitroState;
import citro.object.CitroButton;
import deltarune.assets.Paths;
import deltarune.game.MenuBackground;
import deltarune.Controls;
import deltarune.Game;
import deltarune.game.states.substates.Credits;
import deltarune.game.states.substates.Options;

class MenuState extends CitroState
{
    public static var instance:MenuState;
    public var playButton:CitroButton;
    public var credsButton:CitroButton;
    public var optButton:CitroButton;
    private var coolBG:MenuBackground;
    private var leaving:Bool = false;

    override public function create()
    {
        super.create();
        instance = this;
        CitroG.sound.playMusic(Paths.getMusic('Before the Story'), 0.8, true);

        coolBG = new MenuBackground();
        add(coolBG);

        playButton = new CitroButton(80, 40, 160, 40, "Play", clickPlay);
        playButton.bottom = true; add(playButton);

        credsButton = new CitroButton(80, 100, 160, 40, "Credits", function() { if (!leaving) openSubstate(new Credits()); });
        credsButton.bottom = true; add(credsButton);

        optButton = new CitroButton(80, 160, 160, 40, "Options", function() { if (!leaving) openSubstate(new Options()); });
        optButton.bottom = true; add(optButton);
    }

    function clickPlay() {
        if (!leaving) { leaving = true; CitroG.switchState(new PlayState()); }//CitroG.switchState(new ChapterSelectState()); }
    }

    public function exitCredits() {
        CitroG.substate = null;
        playButton.alpha = 1; credsButton.alpha = 1; optButton.alpha = 1;
    }
}
