package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class MenuItem extends FlxSprite
{
    public var targetY:Float = 0;
    
    public var isFlashing:Bool = false;
    private var flashingElapsed:Float = 0;
    private static inline final FLASH_COLOR:FlxColor = 0xFF33FFFF;
    private static inline final FLASHES_PER_SECOND:Int = 6;
    private static inline final LERP_SPEED:Float = 10.2;
    private static inline final BASE_Y:Float = 480;
    
    private var lerpFactor:Float;

    public function new(x:Float, y:Float, weekName:String = '')
    {
        super(x, y);
        loadGraphic(Paths.image('storymenu/' + weekName));
        antialiasing = ClientPrefs.data.antialiasing;
        lerpFactor = Math.exp(-1 / FlxG.updateFramerate * LERP_SPEED);
    }

    public function setFlashing(value:Bool = true):Void
    {
        isFlashing = value;
        flashingElapsed = 0;
        color = isFlashing ? FLASH_COLOR : FlxColor.WHITE;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // Smooth movement towards target Y position
        y = FlxMath.lerp((targetY * 120) + BASE_Y, y, lerpFactor);

        if (isFlashing)
        {
            flashingElapsed += elapsed;
            var flashFrame = Std.int(flashingElapsed * FlxG.updateFramerate * FLASHES_PER_SECOND);
            color = ((flashFrame & 1) == 0) ? FLASH_COLOR : FlxColor.WHITE;
        }
    }
}
