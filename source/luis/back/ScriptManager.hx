package luis.back;

import hscript.Interp;
import hscript.Parser;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class ScriptManager {
    private static var parser:Parser;
    private static var interp:Interp;
    private static var started:Bool;
    private static var effectsMap:Map<String, String> = new Map();
    
    public static function initialize():Void {
        parser = new Parser();
        interp = new Interp();
        
        interp.variables.set("BitmapData", BitmapData);
        interp.variables.set("Math", Math);
        interp.variables.set("Std", Std);
        interp.variables.set("extractARGB", ImageEffects.extractARGB);
        // anyway to add the typedef ImageData to the interpreter?
        
        loadEffectsMapping();
        started = true;
    }
    
    private static function loadEffectsMapping():Void {
        if (FileSystem.exists("assets/scripts/effects.txt")) {
            var content = File.getContent("assets/scripts/effects.txt");
            var lines = content.split("\n");
            
            for (line in lines) {
                line = line.trim();
                if (line == "" || line.startsWith("#")) continue;
                
                var parts = line.split(":");
                if (parts.length == 2) {
                    var effectName = parts[0].trim();
                    var scriptFile = parts[1].trim() + '.hx';
                    effectsMap.set(effectName, scriptFile);
                }
            }
        }
    }
    
    public static function getAvailableEffects():Array<String> {
        return [for (key in effectsMap.keys()) key];
    }
    
    public static function applyScriptEffect(bitmapData:BitmapData, effectName:String):BitmapData {
        if (!effectsMap.exists(effectName)) {
            trace(ImageBatchProcessorUI.updateConsoleText('Script effect not found: $effectName', true));
            return bitmapData;
        }
        
        var scriptFile = "assets/scripts/" + effectsMap.get(effectName);
        if (!FileSystem.exists(scriptFile)) {
            trace(ImageBatchProcessorUI.updateConsoleText('Script file not found: $scriptFile', true));
            return bitmapData;
        }
        
        try {
            //prepares the script
            var scriptContent = File.getContent(scriptFile);
            var program = parser.parseString(scriptContent);
            
            interp.variables.set("input", bitmapData);
            interp.variables.set("output", null);
            
            //executes it
            interp.execute(program);
            
            var result:BitmapData = interp.variables.get("output");
            
            if (result == null) {
                trace(ImageBatchProcessorUI.updateConsoleText('Script has none return value: $effectName', true));
                return bitmapData;
            }
            
            return result;
        } catch (e:Dynamic) {
            trace(ImageBatchProcessorUI.updateConsoleText('Error executing the script $effectName: $e', true));
            return bitmapData;
        }
    }
}