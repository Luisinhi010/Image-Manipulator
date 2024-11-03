import lime.graphics.Image;
import openfl.utils.ByteArray;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import sys.FileSystem;
import sys.io.File;
import cpp.vm.Gc;
import sys.thread.Thread;

using StringTools;

typedef ImageData = {a:Int, r:Int, g:Int, b:Int}

class ImageBatchProcessor
{
	public static var threads:Array<Thread> = [];
	private static var __threadCycle:Int = 0;

	public static function initThreads():Void
		for (i in 0...4)
			threads.push(Thread.createWithEventLoop(function() Thread.current().events.promise()));

	public static function execAsync(func:Void->Void):Void
	{
		if (!ImageBatchProcessorUI.async)
		{
			func();
			return;
		}
		var threadIndex:Int = (__threadCycle++) % threads.length;
		var currentThread:Thread = threads[threadIndex];

		try
		{
			currentThread.events.run(func);
		}
		catch (error:Dynamic)
		{
			trace(ImageBatchProcessorUI.updateConsoleText("An error occurred in async execution on thread " + threadIndex + ": " + error, true));
		}
	}

	public static var onImageProcessedCallback:BitmapData->Void;

	public static function processImages(inputPath:String, outputPath:String, processImageFunc:BitmapData->BitmapData):Void
	{
		if (!FileSystem.exists(inputPath))
		{
			trace(ImageBatchProcessorUI.updateConsoleText('Folder does not exist: ' + inputPath, true));
			return;
		}

		if (!FileSystem.exists(outputPath))
		{
			trace(ImageBatchProcessorUI.updateConsoleText('Output folder does not exist, creating: ' + outputPath, true));
			FileSystem.createDirectory(outputPath);
		}

		var files:Array<String> = FileSystem.readDirectory(inputPath);
		var numImages:Int = 0;
		var processedImages:Int = 0;

		for (file in files)
		{
			if (file.endsWith(".png"))
			{
				numImages++;
				try
				{
					execAsync(() ->
					{
						var filePath:String = inputPath + "/" + file;
						var bitmapData:BitmapData = BitmapData.fromFile(filePath);
						var processedBitmapData:BitmapData = processImageFunc(bitmapData);

						var outputFile:String = outputPath + "/" + file;
						var encodedBytes:ByteArray = processedBitmapData.encode(processedBitmapData.rect, new PNGEncoderOptions());
						File.saveBytes(outputFile, encodedBytes);

						onImageProcessedCallback(processedBitmapData);
						processedImages++;
						ImageBatchProcessorUI.imagename.text = "Images: " + numImages + " Processed: " + processedImages + ' MB: '
							+ Std.int(Gc.memInfo64(Gc.MEM_INFO_USAGE) / 1024 / 1024) + ' File: ' + file;
					});
				}
				catch (e:Dynamic)
				{
					trace(ImageBatchProcessorUI.updateConsoleText('Failed to process image: ' + file + ' Error: ' + e), true);
				}
			}
		}
	}

	public static function turnBrightnessToAlpha(inputPath:String, outputPath:String):Void
	{
		processImages(inputPath, outputPath, function(bitmapData:BitmapData):BitmapData
		{
			for (x in 0...bitmapData.width)
				for (y in 0...bitmapData.height)
				{
					var d:ImageData = extractARGB(bitmapData, x, y);

					var brightness:Float = (d.r + d.g + d.b) / (3 * 255.0);
					var newAlpha:Int = Std.int(brightness * d.a);
					var newArgb:UInt = (newAlpha << 24) | (d.r << 16) | (d.g << 8) | d.b;

					bitmapData.setPixel32(x, y, newArgb);
				}

			return bitmapData;
		});
	}

	public static function oversampleSprite(inputPath:String, outputPath:String):Void
	{
		processImages(inputPath, outputPath, function(bitmapData:BitmapData):BitmapData
		{
			var oversampledBitmapData:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0x00000000);
			oversampledBitmapData.draw(bitmapData);
			oversampledBitmapData.draw(bitmapData);
			return oversampledBitmapData;
		});
	}

	public static function grayscaleEffect(inputPath:String, outputPath:String):Void
	{
		processImages(inputPath, outputPath, function(bitmapData:BitmapData):BitmapData
		{
			for (x in 0...bitmapData.width)
				for (y in 0...bitmapData.height)
				{
					var d:ImageData = extractARGB(bitmapData, x, y);

					var averageColor:Int = Std.int((d.r + d.g + d.b) / 3);
					var newArgb:UInt = (d.a << 24) | (averageColor << 16) | (averageColor << 8) | averageColor;
					bitmapData.setPixel32(x, y, newArgb);
				}

			return bitmapData;
		});
	}

	public static function chromaticAberrationEffect(inputPath:String, outputPath:String):Void
	{
		processImages(inputPath, outputPath, function(bitmapData:BitmapData):BitmapData
		{
			var redOffset:Int = 5;
			var blueOffset:Int = -5;
			var xOffset:Int = Std.int(redOffset);
			var yOffset:Int = Std.int(blueOffset);

			var result:BitmapData = new BitmapData(bitmapData.width + xOffset, bitmapData.height + yOffset, true, 0x00000000);

			for (x in 0...bitmapData.width)
				for (y in 0...bitmapData.height)
				{
					var d:ImageData = extractARGB(bitmapData, x, y);

					var redX:Int = x + redOffset;
					var redArgb:UInt = (d.a << 24) | (d.r << 16);
					result.setPixel32(redX, y, result.getPixel32(redX, y) | redArgb);

					var greenArgb:UInt = (d.a << 24) | (d.g << 8);
					result.setPixel32(x, y, result.getPixel32(x, y) | greenArgb);

					var blueY:Int = y + blueOffset;
					var blueArgb:UInt = (d.a << 24) | d.b;
					result.setPixel32(x, blueY, result.getPixel32(x, blueY) | blueArgb);
				}

			return result;
		});
	}

	public static function applyPixelation(inputPath:String, outputPath:String, pixelSize:Int, resize:Bool):Void
	{
		processImages(inputPath, outputPath, function(bitmapData:BitmapData):BitmapData
		{
			var pixelated:BitmapData = new BitmapData(Math.ceil(bitmapData.width / pixelSize), Math.ceil(bitmapData.height / pixelSize),
				bitmapData.transparent, 0);

			pixelated.draw(bitmapData, new Matrix(1.0 / pixelSize, 0, 0, 1.0 / pixelSize));

			if (resize)
				return pixelated;

			var result:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, bitmapData.transparent, 0);
			result.draw(pixelated, new Matrix(pixelSize, 0, 0, pixelSize));

			return result;
		});
	}

	public static function applyDithering(inputPath:String, outputPath:String):Void
	{
		processImages(inputPath, outputPath, function(bitmapData:BitmapData):BitmapData
		{
			for (x in 0...bitmapData.width)
				for (y in 0...bitmapData.height)
				{
					var d:ImageData = extractARGB(bitmapData, x, y);
					var gray:Int = Std.int(0.299 * d.r + 0.587 * d.g + 0.114 * d.b);

					gray = gray > 128 ? 255 : 0;

					var newArgb:UInt = (d.a << 24) | (gray << 16) | (gray << 8) | gray;
					bitmapData.setPixel32(x, y, newArgb);
				}

			return bitmapData;
		});
	}

	public static function extractARGB(bitmapData:BitmapData, x:Int, y:Int):ImageData
	{
		var argb:UInt = bitmapData.getPixel32(x, y);
		return {
			a: (argb >> 24) & 0xff,
			r: (argb >> 16) & 0xff,
			g: (argb >> 8) & 0xff,
			b: argb & 0xff
		};
	}
}
