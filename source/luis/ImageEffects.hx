package luis;

import openfl.geom.Matrix;
import openfl.display.BitmapData;

using StringTools;

typedef ImageData =
{
	a:Int,
	r:Int,
	g:Int,
	b:Int
}

class ImageEffects
{
	public static function applyTurnBrightnessToAlpha(bitmapData:BitmapData):BitmapData
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
	}

	public static function applyOversampleSprite(bitmapData:BitmapData):BitmapData
	{
		var oversampledBitmapData:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0x00000000);
		oversampledBitmapData.draw(bitmapData);
		oversampledBitmapData.draw(bitmapData);

		return oversampledBitmapData;
	}

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

	public static function extractARGB(bitmapData:BitmapData, x:Int, y:Int):ImageData
	{
		var argb:UInt = bitmapData.getPixel32(x, y);
		return {
			a: (argb >> 24) & 0xff,
			r: (argb >> 16) & 0xff,
			g: (argb >> 8) & 0xff,
			b: (argb) & 0xff
		};
	}
}
