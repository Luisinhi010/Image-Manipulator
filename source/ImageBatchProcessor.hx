import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class ImageBatchProcessor
{
	public static var onImageProcessedCallback: BitmapData -> Void;

    public static function processImages(folderPath:String, outputPath:String, processImageFunc:BitmapData->BitmapData):Void
    {
        if (!FileSystem.exists(folderPath))
        {
            trace('Folder does not exist: ' + folderPath);
            return;
        }

        if (!FileSystem.exists(outputPath))
        {
            trace('Output folder does not exist, creating: ' + outputPath);
            FileSystem.createDirectory(outputPath);
        }

        var files:Array<String> = FileSystem.readDirectory(folderPath);

        for (file in files)
        {
            if (file.endsWith(".png"))
            {
                try
                {
                    var filePath = folderPath + "/" + file;
                    var bitmapData:BitmapData = BitmapData.fromFile(filePath);
                    var processedBitmapData:BitmapData = processImageFunc(bitmapData);

                    var outputFile = outputPath + "/" + file;
                    var encodedBytes = processedBitmapData.encode(processedBitmapData.rect, new PNGEncoderOptions());
                    File.saveBytes(outputFile, encodedBytes);

                    // Call the callback function to display the processed image
                    onImageProcessedCallback(processedBitmapData);
                }
                catch (e:Dynamic)
                {
                    trace('Failed to process image: ' + file + ' Error: ' + e);
                }
            }
        }
    }


	public static function turnBrightnessToAlpha(folderPath:String, outputPath:String):Void
	{
		processImages(folderPath, outputPath, function(bitmapData:BitmapData):BitmapData {
			for (x in 0...bitmapData.width)
			{
				for (y in 0...bitmapData.height)
				{
					var argb:UInt = bitmapData.getPixel32(x, y);
					var a:Int = (argb >> 24) & 0xff;
					var r:Int = (argb >> 16) & 0xff;
					var g:Int = (argb >> 8) & 0xff;
					var b:Int = argb & 0xff;

					var brightness:Float = (r + g + b) / (3 * 255.0);
					var newAlpha:Int = Std.int(brightness * a);
					var newArgb:UInt = (newAlpha << 24) | (r << 16) | (g << 8) | b;

					bitmapData.setPixel32(x, y, newArgb);
				}
			}
			return bitmapData;
		});
	}

	public static function oversampleSprite(folderPath:String, outputPath:String):Void
	{
		processImages(folderPath, outputPath, function(bitmapData:BitmapData):BitmapData {
			var oversampledBitmapData:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0x00000000);
			oversampledBitmapData.draw(bitmapData);
			oversampledBitmapData.draw(bitmapData);
			return oversampledBitmapData;
		});
	}
}