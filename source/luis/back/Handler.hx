package luis.back;

import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import sys.FileSystem;
import sys.io.File;
import cpp.vm.Gc;
import sys.thread.Thread;

using StringTools;

class Handler
{
	public static var threads:Array<Thread> = [];
	private static var __threadCycle:Int = 0;

	public static function initThreads():Void
		for (i in 0...4)
			threads.push(Thread.createWithEventLoop(function() Thread.current().events.promise()));

	public static function execAsync(func:Void->Void, async:Bool = false):Void
	{
		if (!async)
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
				}
				catch (e:Dynamic)
				{
					trace(ImageBatchProcessorUI.updateConsoleText('Failed to process image: ' + file + ' Error: ' + e), true);
				}
			}
		}
	}

	public static function applyEffect(inputPath:String, outputPath:String, selectedEffect:String):Void {
		var effectFunction = null;
		switch (selectedEffect)
		{
			case "Brightness to Alpha":
				effectFunction = ImageEffects.applyTurnBrightnessToAlpha;
			case "Oversample":
				effectFunction = ImageEffects.applyOversampleSprite;
			case "Grayscale":
				effectFunction = ImageEffects.grayscaleEffect;
			case "Chromatic":
				effectFunction = ImageEffects.applyChromaticAberration;
			case "Pixelation":
				effectFunction = ImageEffects.applyPixelation.bind();
			case "Dithering":
				effectFunction = ImageEffects.applyDithering;
		}
		processImages(inputPath, outputPath, effectFunction);
	}
}
