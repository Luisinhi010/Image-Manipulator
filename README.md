A HaxeFlixel-based image processing tool.

## Overview

-----------

This project is a graphical user interface (GUI) application built with HaxeFlixel that allows users to batch process images using various effects.

## Features

------------

*   Batch processing of images in a specified input folder
*   Support for multiple image effects:
  *   Brightness to Alpha
  *   Oversample
  *   Grayscale
  *   Chromatic
  *   Pixelation
  *   Dithering
*   Asynchronous processing using multiple threads
*   Real-time console output for monitoring progress and errors
*   Customizable output folder and file naming

## Code Structure


-----------------

The project consists of three main classes:

*   `ImageBatchProcessorUI`: The main GUI application class, responsible for user input, effect selection, and progress display.
*   `Handler`: The class responsible for executing the selected effect on each image in the input folder.
*   `ImageEffects`: The class containing functions for applying image effects.
*   `ScriptManager`: The class contains functions for scripted effects.

### ImageBatchProcessorUI

This class extends `FlxState` and contains the following key components:

*   `inputFolderInput`: A `FlxUIInputText` field for specifying the input folder path.
*   `outputFolderInput`: A `FlxUIInputText` field for specifying the output folder path.
*   `effectsDropdown`: A `FlxUIDropDownMenu` for selecting the desired image effect.
*   `uiGroup`: A `FlxUIGroup` containing the GUI elements.

### Handler

This class contains the following key components:

*   `threads`: An array of `Thread` objects for asynchronous processing.
*   `execAsync`: A function for executing a given function asynchronously using the thread pool.
*   `processImages`: A function for processing images in the input folder using the selected effect.

### ScriptManager

This class, utilizing Hscripts `Parser`, `Interp` contains the following components:

*   `effectsMap`: A map that saves the names and the script file names for each effect in `assets\scripts\effects.txt`
*   `programCache`: A map which caches the script effects before running them.

### ImageEffects

This class contains functions for applying image effects, such as `applyTurnBrightnessToAlpha`, which takes a `BitmapData` object as input and returns the modified `BitmapData` object.

## Usage

-----

1.   Clone the repository and navigate to the project directory.
2.   Open the project in your preferred Haxe development environment.
3.   Build and run the project using the `lime build` and `lime run` commands.
4.   In the GUI application, select the input folder, output folder, and desired image effect.
5.   Click the "Apply Effect" button to start the batch processing.

## Notes

-----

*   This project uses the HaxeFlixel framework and OpenFL library for GUI and graphics processing.
*   The image processing effects are implemented using OpenFL's `BitmapData` class.
*   Asynchronous processing is achieved using Haxe's `Thread` class and a thread pool.

## Contributing

------------

Contributions are welcome! Please submit pull requests or issues on the GitHub repository.

## License

-------

This project is licensed under the MIT License. See the LICENSE file for details.
