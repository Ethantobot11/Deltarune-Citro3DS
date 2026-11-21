package deltarune.game.states;

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.object.CitroGroup;
import citro.CitroG;
import deltarune.assets.GameAssets;
import deltarune.data.Chapter.ChapterFile;
import deltarune.Controls;
import deltarune.assets.JsonUtil;
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
	static function sanitizeJson(raw:String):String
	{
	    if (raw == null) return "";
	    if (raw.length > 0 && raw.charCodeAt(0) == 0xFEFF) return raw.substr(1);
	    return raw;
	}

	override public function create()
	{
		super.create();
		instance = this;
		CitroG.sound.stopMusic();
		CitroG.sound.play('romfs:/assets/music/DRONE.cwav', 0.8, true);

		var chapterFiles = GameAssets.list("data/chapters/");
		chapterFiles = chapterFiles.filter(function(s:String) return s.endsWith(".json"));

		for (chapterFile in chapterFiles) {
			var raw = GameAssets.text('data/chapters/$chapterFile');
			if (raw == null) continue;
			raw = sanitizeJson(raw);
			var chapter:Dynamic;
			try {
			    chapter = JsonUtil.trimKeys(Json.parse(raw));
			} catch (e:Dynamic) { trace('Error parsing Chapter JSON for $chapterFile: $e'); continue; }

			if (chapter.previousChapter != null && chapter.previousChapter != "") {
				var inserted = false;
				for (i in 0...chapterData.length) {
					if (chapterData[i].id == chapter.previousChapter) {
						chapterData.insert(i + 1, chapter);
						inserted = true;
						break;
					}
				}
				if (!inserted) chapterData.push(chapter);
			} else {
				chapterData.push(chapter);
			}
		}

		for (i in 0...chapterData.length) {
			var chapterContainer = new CitroGroup();

			var numText = new CitroText(24, 5 + (30 * i), chapterData[i].chapterSelect.label);
			numText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
			numText.color = 0xFFFFFFFF;
			chapterContainer.add(numText);

			var titleText = new CitroText(84, 5 + (30 * i), chapterData[i].chapterSelect.title);
			titleText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
			titleText.alignment = CENTER;
			titleText.color = 0xFFFFFFFF;
			chapterContainer.add(titleText);

			var chIcon = new CitroSprite(276, 5 + (30 * i));
			chIcon.loadGraphic('romfs:/assets/images/ui/chapter_select/ch_icon_${chapterData[i].chapterSelect.iconSuffix}.t3x');
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
		add(selectorSprite);

		var infoText = new CitroText(6, 210, "(C) Toby Fox 2018-2025\nDELTARUNE v1.0");
		infoText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		infoText.color = 0xFF808080;
		add(infoText);

		quitText = new CitroText(280, 210, "Quit");
		quitText.loadFont("romfs:/assets/fonts/8bitoperator_jve.bcfnt");
		quitText.alignment = CENTER;
		quitText.color = 0xFFFFFFFF;
		add(quitText);

		setSelection(currentSelection);
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
				var t:CitroText = null;
				if ((t = Type.getClass(m) == CitroText ? cast m : null) != null) {
					t.color = 0xFFFFFFFF;
				} else {
					m.color = 0xFFFFFFFF;
				}
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
