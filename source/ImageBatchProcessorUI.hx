import openfl.filters.BitmapFilterQuality;
import flixel.FlxBasic;
import openfl.geom.Point;
import openfl.filters.BlurFilter;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIList;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUIState;

class ImageBatchProcessorUI extends FlxUIState
{
	var inputFolderInput:FlxUIInputText;
	var outputFolderInput:FlxUIInputText;
	var effectsDropdown:FlxUIDropDownMenu;
	var uiGroup:FlxUIGroup;

	static var tween:FlxTween;
	public static var consoleText:FlxText;
	public static var imagename:FlxText;
	public static var async:Bool = true;

	var wallpaper:FlxSprite;
	var havewallpaper:Bool = true;

	override function create()
	{
		super.create();
		ImageBatchProcessor.initThreads();
		FlxG.cameras.list[0].bgColor = 0xFF4E4E4E;

		try {
			var bitmapData:BitmapData = BitmapData.fromFile('${Sys.getEnv("AppData")}\\Microsoft\\Windows\\Themes\\TranscodedWallpaper');
			var blurFilter:BlurFilter = new BlurFilter(20, 20, 20);
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), blurFilter);
			wallpaper = new FlxSprite()
			.loadGraphic(bitmapData);
		} catch (e:Dynamic) {
			havewallpaper = false;
		}
		if (havewallpaper) {
			wallpaper.scrollFactor.set(0, 0);
			wallpaper.antialiasing = true;
			wallpaper.visible = false;
			wallpaper.scale.set(FlxG.width / wallpaper.width, FlxG.height / wallpaper.height);
			wallpaper.updateHitbox();
			add(wallpaper);
		
			var changebgbutton:FlxButton = new FlxButton(10, 690, 'Change Bg', function() {
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
			"Oversample Sprite",
			"Grayscale Effect",
			"Chromatic Effect",
			"Pixelation",
			"Dithering"
		];
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

		ImageBatchProcessor.onImageProcessedCallback = function(processedBitmapData:BitmapData)
		{
			for (member in members)
			{
				if (!(member is FlxSprite))
					return;
				var lastImage:FlxSprite = cast(member, FlxSprite);
				if (lastImage != null)
				{
					lastImage.visible = false;
					lastImage.alpha = 0;
					lastImage.kill();
					remove(lastImage, true);
				}
			}

			var processedImage:FlxSprite = new FlxSprite(0, 0, processedBitmapData);
			processedImage.x = FlxG.width - processedImage.width;
			processedImage.screenCenter(Y);
			processedImage.moves = false;
			add(processedImage);
		};
	}

	function applyEffect()
	{
		var inputFolder:String = inputFolderInput.text;
		var outputFolder:String = outputFolderInput.text;
		var selectedEffect:String = effectsDropdown.selectedLabel;
		switch (selectedEffect)
		{
			case "Brightness to Alpha":
				ImageBatchProcessor.turnBrightnessToAlpha(inputFolder, outputFolder);
			case "Oversample Sprite":
				ImageBatchProcessor.oversampleSprite(inputFolder, outputFolder);
			case "Grayscale Effect":
				ImageBatchProcessor.grayscaleEffect(inputFolder, outputFolder);
			case "Chromatic Effect":
				ImageBatchProcessor.chromaticAberrationEffect(inputFolder, outputFolder);
			case "Pixelation":
				ImageBatchProcessor.applyPixelation(inputFolder, outputFolder, 4, false);
			case "Dithering":
				ImageBatchProcessor.applyDithering(inputFolder, outputFolder);
		}
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
			startDelay: 1,
			onComplete: function(twn:FlxTween)
			{
				tween = null;
			}
		});

		return message;
	}
}
