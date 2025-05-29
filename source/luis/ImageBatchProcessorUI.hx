package luis;

import luis.back.ScriptManager;
import luis.back.Handler;
import openfl.geom.Point;
import openfl.filters.BlurFilter;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.tweens.FlxTween;
import flixel.FlxState;

class ImageBatchProcessorUI extends FlxState
{
	var inputFolderInput:FlxUIInputText;
	var outputFolderInput:FlxUIInputText;
	var effectsDropdown:FlxUIDropDownMenu;

	public var uiGroup:FlxUIGroup;

	static var tween:FlxTween;
	public static var consoleText:FlxText;
	public static var imagename:FlxText;

	var wallpaper:FlxSprite;
	var havewallpaper:Bool = true;

	override function create()
	{
		super.create();
		FlxG.cameras.list[0].bgColor = 0xFF4E4E4E;

		try
		{
			var bitmapData:BitmapData = BitmapData.fromFile('${Sys.getEnv("AppData")}\\Microsoft\\Windows\\Themes\\TranscodedWallpaper');
			var blurFilter:BlurFilter = new BlurFilter(20, 20, 20);
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), blurFilter);
			wallpaper = new FlxSprite().loadGraphic(bitmapData);
		}
		catch (e:Dynamic)
		{
			havewallpaper = false;
		}
		if (havewallpaper)
		{
			wallpaper.scrollFactor.set(0, 0);
			wallpaper.antialiasing = true;
			wallpaper.visible = false;
			wallpaper.scale.set(FlxG.width / wallpaper.width, FlxG.height / wallpaper.height);
			wallpaper.updateHitbox();
			add(wallpaper);

			var changebgbutton:FlxButton = new FlxButton(10, 690, 'Change Bg', function()
			{
				wallpaper.visible = !wallpaper.visible;
			});
			changebgbutton.alpha = 0.6;
			changebgbutton.label.alpha = 0.6;
			add(changebgbutton);
		}

		uiGroup = new FlxUIGroup();
		add(uiGroup);

		var offsetY:Float = FlxG.height / 3;

		var inputLabel:FlxText = new FlxText(100, offsetY, 0, "Input Folder Path:", 20);
		uiGroup.add(inputLabel);
		inputFolderInput = new FlxUIInputText(inputLabel.x, inputLabel.y + inputLabel.height + 10, 500, "", 50);
		uiGroup.add(inputFolderInput);

		var outputLabel:FlxText = new FlxText(inputFolderInput.x, inputFolderInput.y + inputFolderInput.height + 20, "Output Folder Path:", 20);
		uiGroup.add(outputLabel);
		outputFolderInput = new FlxUIInputText(outputLabel.x, outputLabel.y + outputLabel.height + 10, 500, "", 50);
		uiGroup.add(outputFolderInput);

		var effectsList:Array<String> = [
			"Brightness to Alpha",
			"Oversample",
			"Grayscale",
			"Chromatic",
			"Pixelation",
			"Dithering"
		];

		// Load script effects
		var scriptEffects = ScriptManager.getAvailableEffects();
		for (effect in scriptEffects)
			effectsList.push(effect);

		// Sort effects alphabetically
		effectsList.sort((a, b) -> a.toLowerCase() < b.toLowerCase() ? -1 : 1);

		effectsDropdown = new FlxUIDropDownMenu(outputFolderInput.x, outputFolderInput.y + outputFolderInput.height + 10,
			FlxUIDropDownMenu.makeStrIdLabelArray(effectsList, true));
		uiGroup.add(effectsDropdown);

		var applyEffectButton = new FlxUIButton(effectsDropdown.x + effectsDropdown.width + 10, effectsDropdown.y, "Apply Effect", applyEffect);
		uiGroup.add(applyEffectButton);

		imagename = new FlxText(10, FlxG.height - 20);
		imagename.setFormat(null, 16, 0xffffff, FlxTextAlign.LEFT);
		uiGroup.add(imagename);

		consoleText = new FlxText(10, imagename.y - 10);
		consoleText.setFormat(null, 16, 0xffffff, FlxTextAlign.LEFT);
		uiGroup.add(consoleText);

		Handler.onImageProcessedCallback = function(processedBitmapData:BitmapData)
		{
			var imagesToRemove:Array<FlxSprite> = [];

			for (member in members)
			{
				if (member is FlxSprite && member != wallpaper && !Std.isOfType(member, FlxUIGroup) && !Std.isOfType(member, FlxText)
					&& !Std.isOfType(member, FlxButton))
				{
					imagesToRemove.push(cast(member, FlxSprite));
				}
			}

			for (img in imagesToRemove)
			{
				img.visible = false;
				img.alpha = 0;
				img.kill();
				remove(img, true);
			}

			var processedImage:FlxSprite = new FlxSprite(0, 0, processedBitmapData);
			processedImage.x = FlxG.width - processedImage.width;
			processedImage.screenCenter(Y);
			processedImage.alpha = 0.5;
			processedImage.moves = false;
			insert(members.indexOf(uiGroup) - 1, processedImage);
		};
	}

	function applyEffect()
	{
		var inputFolder:String = inputFolderInput.text;
		var outputFolder:String = outputFolderInput.text;
		var selectedEffect:String = effectsDropdown.selectedLabel;
		Handler.applyEffect(inputFolder, outputFolder, selectedEffect);
	}

	public static function updateConsoleText(message:String, isError:Bool = false):String
	{
		consoleText.color = isError ? 0xff0000 : 0xffffff;
		consoleText.text += message + "\n";
		consoleText.y -= 20;

		consoleText.alpha = 1;
		if (tween != null)
			tween.cancel();

		tween = FlxTween.tween(consoleText, {alpha: 0}, 0.8, {
			startDelay: 5,
			onComplete: function(twn:FlxTween)
			{
				tween = null;
			}
		});

		return message;
	}
}
