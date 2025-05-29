package luis;

import luis.types.ImageTypes;
import luis.utils.PixelUtils;
import openfl.geom.Matrix;
import openfl.display.BitmapData;

using StringTools;

/**
 * Provides image effects for various visual transformations.
 * Contains methods for manipulating image appearance.
 */
class ImageEffects
{
	/**
	 * Converts pixel brightness to alpha transparency.
	 * Brighter pixels become more opaque, darker pixels become more transparent.
	 * 
	 * @param bitmapData The source image to process
	 * @return A new BitmapData with brightness-based alpha channel
	 */
	public static function applyTurnBrightnessToAlpha(bitmapData:BitmapData):BitmapData
	{
		for (x in 0...bitmapData.width)
			for (y in 0...bitmapData.height)
			{
				var d:ImageData = PixelUtils.extractARGB(bitmapData, x, y);

				var brightness:Float = PixelUtils.calculateBrightness(d.r, d.g, d.b);
				var newAlpha:Int = Std.int(brightness * d.a);
				var newArgb:UInt = PixelUtils.makeARGB(newAlpha, d.r, d.g, d.b);

				bitmapData.setPixel32(x, y, newArgb);
			}

		return bitmapData;
	}

	/**
	 * Oversamples a sprite by drawing it over itself.
	 * Creates a double-exposure effect to enhance appearance.
	 * 
	 * @param bitmapData The source image to oversample
	 * @return A new BitmapData with oversample effect
	 */
	public static function applyOversampleSprite(bitmapData:BitmapData):BitmapData
	{
		var oversampledBitmapData:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0x00000000);
		oversampledBitmapData.draw(bitmapData);
		oversampledBitmapData.draw(bitmapData);

		return oversampledBitmapData;
	}

	/**
	 * Converts a color image to grayscale.
	 * Uses average method to calculate grayscale values.
	 * 
	 * @param bitmapData The source image to convert
	 * @return The grayscale version of the image
	 */
	public static function grayscaleEffect(bitmapData:BitmapData):BitmapData
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
	}

	/**
	 * Applies chromatic aberration effect by separating color channels.
	 * Creates a glitch/distortion effect common in photography or digital art.
	 * 
	 * @param bitmapData The source image to process
	 * @return A new BitmapData with chromatic aberration effect
	 */
	public static function applyChromaticAberration(bitmapData:BitmapData):BitmapData
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
	}

	/**
	 * Pixelates the image by reducing resolution and then upscaling.
	 * Creates a blocky, retro appearance.
	 * 
	 * @param bitmapData The source image to pixelate
	 * @param pixelSize Size of each "pixel" block (default 4)
	 * @param resize If true, returns the reduced size image without upscaling
	 * @return A new BitmapData with pixelate effect
	 */
	public static function applyPixelation(bitmapData:BitmapData, ?pixelSize:Int = 4, ?resize:Bool = false):BitmapData
	{
		var pixelated:BitmapData = new BitmapData(Math.ceil(bitmapData.width / pixelSize), Math.ceil(bitmapData.height / pixelSize), bitmapData.transparent, 0);
		pixelated.draw(bitmapData, new Matrix(1.0 / pixelSize, 0, 0, 1.0 / pixelSize));

		if (resize)
			return pixelated;

		var result:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, bitmapData.transparent, 0);
		result.draw(pixelated, new Matrix(pixelSize, 0, 0, pixelSize));

		return result;
	}

	/**
	 * Applies a black and white dithering effect.
	 * Creates a high-contrast image with only black and white pixels.
	 * 
	 * @param bitmapData The source image to process
	 * @return A new BitmapData with dithering effect
	 */
	public static function applyDithering(bitmapData:BitmapData):BitmapData
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
	}

	/**
	 * Extracts ARGB components from a pixel.
	 * This is a wrapper for compatibility with older code.
	 * 
	 * @param bitmapData The source image
	 * @param x X coordinate of the pixel
	 * @param y Y coordinate of the pixel
	 * @return ImageData structure containing separated ARGB values
	 */
	public static function extractARGB(bitmapData:BitmapData, x:Int, y:Int):ImageData
	{
		// This method is now just a wrapper to maintain compatibility
		return PixelUtils.extractARGB(bitmapData, x, y);
	}
}
