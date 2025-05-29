package luis.utils;

import luis.types.ImageTypes;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

/**
 * Utilities for pixel manipulation and image components.
 * Provides helper functions to simplify common pixel operations.
 */
class PixelUtils
{
	/**
	 * Extracts ARGB components from a pixel at a specific position in the image.
	 * 
	 * @param bitmapData The source image
	 * @param x X coordinate of the pixel
	 * @param y Y coordinate of the pixel
	 * @return ImageData structure containing separated ARGB values
	 */
	public static inline function extractARGB(bitmapData:BitmapData, x:Int, y:Int):ImageData
	{
		var argb:UInt = bitmapData.getPixel32(x, y);
		return {
			a: (argb >> 24) & 0xff,
			r: (argb >> 16) & 0xff,
			g: (argb >> 8) & 0xff,
			b: (argb) & 0xff
		};
	}

	/**
	 * Creates an ARGB pixel value from individual components.
	 * 
	 * @param a Alpha channel (0-255)
	 * @param r Red channel (0-255)
	 * @param g Green channel (0-255)
	 * @param b Blue channel (0-255)
	 * @return 32-bit value representing the ARGB pixel
	 */
	public static inline function makeARGB(a:Int, r:Int, g:Int, b:Int):UInt
	{
		return ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
	}

	/**
	 * Checks if a value is within the valid range for a color channel (0-255).
	 * If the value is outside the range, it will be adjusted.
	 * 
	 * @param value The value to check
	 * @return The adjusted value, between 0 and 255
	 */
	public static inline function clamp(value:Int):Int
	{
		return value < 0 ? 0 : (value > 255 ? 255 : value);
	}

	/**
	 * Calculates the brightness of a pixel based on its RGB components.
	 * Uses standard luminance formula.
	 * 
	 * @param r Red channel (0-255)
	 * @param g Green channel (0-255)
	 * @param b Blue channel (0-255)
	 * @return Brightness value between 0.0 and 1.0
	 */
	public static inline function calculateBrightness(r:Int, g:Int, b:Int):Float
	{
		return (0.299 * r + 0.587 * g + 0.114 * b) / 255;
	}
}
