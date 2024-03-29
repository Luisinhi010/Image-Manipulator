import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIList;

class ImageBatchProcessorUI extends flixel.addons.ui.FlxUIState
{
    var processedImage:FlxSprite;
    override function create()
    {
        super.create();

        var square = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF4E4E4E);
        add(square);

        var inputFolderInput = new FlxUIInputText(100, square.height / 3, 500, "Input Folder Path", 50);
        add(inputFolderInput);

        var outputFolderInput = new FlxUIInputText(inputFolderInput.x, inputFolderInput.y + inputFolderInput.height + 10, 500, "Output Folder Path", 50);
        add(outputFolderInput);

        // Set the onImageProcessedCallback to update the UI with the processed image
        ImageBatchProcessor.onImageProcessedCallback = function(processedBitmapData:BitmapData)
        {
            // Update the UI to show the processed image
            if (processedImage != null)
            remove(processedImage);
            processedImage = new FlxSprite(0, 0, processedBitmapData);
            processedImage.x = FlxG.width-processedImage.width;
            processedImage.screenCenter(Y);
            add(processedImage);
        };

        var turnBrightnessButton = new FlxUIButton(outputFolderInput.x, outputFolderInput.y + outputFolderInput.height + 10, "Turn Brightness to Alpha",
            function()
            {
                var inputFolder = inputFolderInput.text;
                var outputFolder = outputFolderInput.text;
                ImageBatchProcessor.turnBrightnessToAlpha(inputFolder, outputFolder);
            });
        add(turnBrightnessButton);

        var oversampleButton = new FlxUIButton(turnBrightnessButton.x, turnBrightnessButton.y + turnBrightnessButton.height + 10, "Oversample Sprite",
            function()
            {
                var inputFolder = inputFolderInput.text;
                var outputFolder = outputFolderInput.text;
                ImageBatchProcessor.oversampleSprite(inputFolder, outputFolder);
            });
        add(oversampleButton);
    }
}
