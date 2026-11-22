package deltarune.game.states;

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.object.CitroGroup;
import citro.CitroG;
import deltarune.assets.GameAssets;
import deltarune.data.Chapter.ChapterFile;
import deltarune.Controls;
import haxe.Json;

using StringTools;

class ChapterSelectState extends CitroState
{
	public static var instance:ChapterSelectState;

	public var selectorSprite:CitroSprite;
	public var quitText:CitroText;
	public var currentSelection:Int = 0;
	public var chapterLabels:Array<CitroGroup> = [];
	public var chapterData:Array<ChapterFile> = [];
	static function sanitizeJson(raw:String):String {
        if (raw == null || raw.length == 0) return "";
        if (raw.length >= 3 && raw.charCodeAt(0) == 0xEF && raw.charCodeAt(1) == 0xBB && raw.charCodeAt(2) == 0xBF) {
            raw = raw.substr(3);
        } else if (raw.length >= 2 && raw.charCodeAt(0) == 0xFF && raw.charCodeAt(1) == 0xFE) {
            raw = raw.substr(2);
        } else if (raw.length > 0 && (raw.charCodeAt(0) == 0xFEFF || raw.charCodeAt(0) == 0xFFFE)) {
            raw = raw.substr(1);
        }

        var buf = new StringBuf();
        for (i in 0...raw.length) {
            var c = raw.charCodeAt(i);
            if (c == 9 || c == 10 || c == 13) { buf.addChar(c); continue; }
            if (c == 0 || c == 65533 || c == 0xFFFE) continue;
            if (c >= 32) buf.addChar(c);
        }
        raw = buf.toString();
        
        var first = -1, firstChar = 0;
        for (i in 0...raw.length) {
            var c = raw.charCodeAt(i);
            if (c == '{'.code || c == '['.code) { first = i; firstChar = c; break; }
        }
        if (first < 0) return raw;
        
        var last = -1;
        var i = raw.length - 1;
        while (i >= first) {
            var c = raw.charCodeAt(i);
            if ((firstChar == '{'.code && c == '}'.code) || (firstChar == '['.code && c == ']'.code)) { 
                last = i; 
                break; 
            }
            i--;
        }
        if (last < 0) return raw;
        
        return raw.substr(first, last - first + 1);
    }

	override public function create()
	{
		super.create();
		instance = this;
		CitroG.sound.stopMusic();
		CitroG.sound.playMusic('romfs:/assets/music/DRONE.cwav', 0.8, true);

		var chapterFiles = GameAssets.list("data/chapters/");
		chapterFiles = chapterFiles.filter(function(s:String) return s.endsWith(".json"));

		for (chapterFile in chapterFiles) {
			var raw = GameAssets.text('data/chapters/$chapterFile');
			if (raw == null) continue;
			
			var chapter:ChapterFile;
			try {
				var cleanRaw = sanitizeJson(raw);
				chapter = cast Json.parse(cleanRaw);
				chapterData.push(chapter);
			} catch (e:Dynamic) {
				trace('Error parsing Chapter JSON for $chapterFile: $e');
				continue;
			}
		}

		chapterData.sort(function(a, b) {
			return extractChapterNumber(a.id) - extractChapterNumber(b.id);
		});

		for (i in 0...chapterData.length) {
			var chapterContainer = new CitroGroup();
			var data = chapterData[i];

			var numText = new CitroText(24, 5 + (30 * i), data.chapterSelect.label);
			numText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
			numText.color = 0xFFFFFFFF;
			chapterContainer.add(numText);

			var titleText = new CitroText(44, 5 + (30 * i), data.chapterSelect.title);
			titleText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
			titleText.alignment = CENTER;
			titleText.color = 0xFFFFFFFF;
			chapterContainer.add(titleText);

			var chIcon = new CitroSprite(356, 5 + (30 * i));
			chIcon.loadGraphic('romfs:/assets/images/ui/chapter_select/ch_icon_${data.chapterSelect.iconSuffix}.t3x');
			chIcon.color = 0xFFFFFFFF;
			chapterContainer.add(chIcon);

			if (isChapterLocked(i)) {
				numText.color = 0xFF808080;
				titleText.color = 0xFF808080;
				chIcon.color = 0xFF808080;
			}

			add(chapterContainer);
			chapterLabels.push(chapterContainer);
		}

		selectorSprite = new CitroSprite(10, 12);
		selectorSprite.loadGraphic("romfs:/assets/images/ui/chapter_select/selector.t3x");
		selectorSprite.scale.x = 1.5;
		selectorSprite.scale.y = 1.5;
		add(selectorSprite);

		var infoText = new CitroText(6, 210, "(C) Toby Fox 2018-2025\nDELTARUNE v1.0");
		infoText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		infoText.color = 0xFF808080;
		infoText.bottom = true;
		add(infoText);

		quitText = new CitroText(280, 210, "Quit");
		quitText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		quitText.alignment = CENTER;
		quitText.color = 0xFFFFFFFF;
		add(quitText);

		setSelection(currentSelection);
	}

	static function extractChapterNumber(id:String):Int {
		if (id == null) return 9999;
		var nums = "";
		for (i in 0...id.length) {
			var c = id.charCodeAt(i);
			if (c >= '0'.code && c <= '9'.code) {
				nums += String.fromCharCode(c);
			}
		}
		return nums == "" ? 9999 : Std.parseInt(nums);
	}

	override public function update(delta:Int)
	{
		super.update(delta);

		if (Controls.up.justPressed) {
			setSelection(currentSelection == -1 ? chapterLabels.length - 1 : currentSelection - 1);
		}
		if (Controls.down.justPressed) {
			setSelection(currentSelection == chapterLabels.length - 1 ? -1 : currentSelection + 1);
		}

		

		if (Controls.back.justPressed)
		{
			CitroG.sound.stopMusic();
			CitroG.switchState(new TransitionState(() -> new MenuState()));
		}

		if (Controls.primary.justPressed) {
			if (currentSelection == -1) {
				CitroG.exitGame();
			} else if (!isChapterLocked(currentSelection)) {
				CitroG.switchState(new TransitionState(() -> new SaveSelectState()));
			}
		}
	}

	public function isChapterLocked(index:Int):Bool {
		return chapterData[index].type == "dummy"
			|| (chapterData[index].requiredChapters != null && chapterData[index].requiredChapters.length > 0);
	}

	public function setSelection(index:Int)
	{
		if (currentSelection == -1) {
			quitText.color = 0xFFFFFFFF;
		} else if (currentSelection < chapterLabels.length && !isChapterLocked(currentSelection)) {
			for (m in chapterLabels[currentSelection].members) {
				m.color = 0xFFFFFFFF;
			}
		}

		currentSelection = index;

		if (currentSelection == -1) {
			quitText.color = 0xFFFFFF00;
			selectorSprite.x = 280;
			selectorSprite.y = 210;
		} else if (currentSelection < chapterLabels.length) {
			if (!isChapterLocked(currentSelection)) {
				for (m in chapterLabels[currentSelection].members) {
					m.color = 0xFFFFFF00;
				}
			}
			selectorSprite.x = 10;
			selectorSprite.y = 12 + (30 * currentSelection);
		}

		CitroG.sound.play('romfs:/assets/sounds/menumove.cwav');
	}
}
