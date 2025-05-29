package luis.utils;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.system.System;
import flixel.FlxG;

/**
 * Advanced memory management utilities based on CodenameEngine's MemoryUtil.
 * Provides garbage collection control and memory monitoring.
 */
class MemoryUtils
{
    public static var disableCount:Int = 0;
    
    /**
     * Requests to disable automatic garbage collection
     */
    public static function requestDisable():Void
    {
        disableCount++;
        if (disableCount > 0) disable();
    }
    
    /**
     * Requests to enable automatic garbage collection
     */
    public static function requestEnable():Void
    {
        disableCount--;
        if (disableCount <= 0) enable();
    }
    
    /**
     * Forces a complete garbage collection cycle
     */
    public static function forceGC():Void
    {
        #if cpp
        Gc.run(true);
        Gc.compact();
        #elseif hl
        Gc.major();
        #elseif (java || neko)
        Gc.run(true);
        #end
    }
    
    /**
     * Runs a minor garbage collection
     */
    public static function clearMinor():Void
    {
        #if (cpp || java || neko)
        Gc.run(false);
        #end
    }
    
    /**
     * Enables automatic garbage collection
     */
    public static function enable():Void
    {
        #if (cpp || hl)
        Gc.enable(true);
        #end
    }
    
    /**
     * Disables automatic garbage collection
     */
    public static function disable():Void
    {
        #if (cpp || hl)
        Gc.enable(false);
        #end
    }
    
    /**
     * Gets current memory usage in bytes
     */
    public static function getCurrentMemoryUsage():Float
    {
        #if cpp
        return Gc.memInfo64(Gc.MEM_INFO_USAGE);
        #elseif sys
        return cast(cast(System.totalMemory, UInt), Float);
        #else
        return 0;
        #end
    }
    
    /**
     * Formats memory value for display
     */
    public static function formatMemory(bytes:Float):String
    {
        var units = ["B", "KB", "MB", "GB"];
        var unitIndex = 0;
        
        while (bytes >= 1024 && unitIndex < units.length - 1)
        {
            bytes /= 1024;
            unitIndex++;
        }
        
        return Math.round(bytes * 100) / 100 + " " + units[unitIndex];
    }
    
    /**
     * Clears unused FlixelG bitmap cache and forces garbage collection
     */
    public static function clearUnusedBitmapCache():Void
    {
        FlxG.bitmap.dumpCache();
        forceGC();
    }
    
    /**
     * Destroys Flixel zombie objects - based on CodenameEngine implementation
     */
    public static function destroyFlixelZombies():Void
    {
        #if cpp
        var zombieCount = 0;
        var destroyableCount = 0;
        var zombie:Dynamic;
        
        while ((zombie = Gc.getNextZombie()) != null)
        {
            zombieCount++;
            if (zombie is flixel.util.FlxDestroyUtil.IFlxDestroyable)
            {
                flixel.util.FlxDestroyUtil.destroy(cast(zombie, flixel.util.FlxDestroyUtil.IFlxDestroyable));
                destroyableCount++;
            }
        }
        
        trace('Cleaned ${zombieCount} zombies; ${destroyableCount} were IFlxDestroyable');
        #end
    }
}