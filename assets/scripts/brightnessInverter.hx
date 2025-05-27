// Invert the brightness of the image

// Creates an output image
//self note, dont need to create a new var with the output name, this makes the ScriptManager.hx return nothing.
output = new BitmapData(input.width, input.height, true, 0x00000000);

// Processes each pixel
for (x in 0...input.width) {
    for (y in 0...input.height) {
        var pixel = extractARGB(input, x, y);
        
        // Inverts each channel brigthness, exept alpha
        pixel.r = 255 - pixel.r;
        pixel.g = 255 - pixel.g;
        pixel.b = 255 - pixel.b;
        
        // recompiles the new image
        var newArgb = (pixel.a << 24) | (pixel.r << 16) | (pixel.g << 8) | pixel.b;
        
        // defines the output image
        output.setPixel32(x, y, newArgb);
    }
}

// the output will be returned by the ScriptManager.hx