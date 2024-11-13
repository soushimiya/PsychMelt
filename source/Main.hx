package;

#if android
import android.content.Context;
#end

import debug.FPSCounter;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import states.TitleState;
import modding.PsychMod;

#if linux
import lime.graphics.Image;
#end

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#end

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
    #define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
    public static var fpsVar:FPSCounter;

	//Coolest FNF Game Config Ever
    private var gameConfig:GameConfig = {
        width: 1280,
        height: 720,
        initialState: TitleState,
        zoom: -1.0,
        framerate: 60,
        skipSplash: true,
        startFullscreen: false
    };

    public static function main():Void
    {
        Lib.current.addChild(new Main());
    }

    public function new()
    {
        super();

        #if android
        setupAndroidWorkingDirectory();
        #elseif ios
        setupIOSWorkingDirectory();
        #end

        if (stage != null)
            init();
        else
            addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(?E:Event):Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        setupGame();
    }

    private function setupGame():Void
    {
        var stageWidth:Int = Lib.current.stage.stageWidth;
        var stageHeight:Int = Lib.current.stage.stageHeight;

        gameConfig.zoom = (gameConfig.zoom == -1.0) ? Math.min(stageWidth / gameConfig.width, stageHeight / gameConfig.height) : gameConfig.zoom;
    
        initializeGameSystems();
        createAndAddGame();
        setupFPSCounter();
        setupPlatformSpecifics();

        #if CRASH_HANDLER
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
        #end

        #if DISCORD_ALLOWED
        DiscordClient.prepare();
        #end

        setupShaderCoordsFix();

        #if MODDING_ALLOWED
        PsychMod.initialize();
        #end
    }

    private function initializeGameSystems():Void
    {
        Controls.instance = new Controls();
        ClientPrefs.loadDefaultKeys();
        #if ACHIEVEMENTS_ALLOWED 
        Achievements.load(); 
        #end
    }

    private function createAndAddGame():Void
    {
        addChild(new FlxGame(
            gameConfig.width, 
            gameConfig.height, 
            gameConfig.initialState, 
            #if (flixel < "5.0.0") gameConfig.zoom, #end
            gameConfig.framerate, 
            gameConfig.framerate, 
            gameConfig.skipSplash, 
            gameConfig.startFullscreen
        ));
    }

    private function setupFPSCounter():Void
    {
        #if !mobile
        fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
        addChild(fpsVar);
        Lib.current.stage.align = "tl";
        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
        if(fpsVar != null) {
            fpsVar.visible = ClientPrefs.data.showFPS;
        }
        #end
    }

    private function setupPlatformSpecifics():Void
    {
        #if linux
        var icon = Image.fromFile("icon.png");
        Lib.current.stage.window.setIcon(icon);
        #end

        #if html5
        FlxG.autoPause = false;
        FlxG.mouse.visible = false;
        #end
    }

    private function setupShaderCoordsFix():Void
    {
        FlxG.signals.gameResized.add(function (w, h) {
            if (FlxG.cameras != null) {
                for (cam in FlxG.cameras.list) {
                    if (cam != null && cam.filters != null)
                        resetSpriteCache(cam.flashSprite);
                }
            }

            if (FlxG.game != null)
                resetSpriteCache(FlxG.game);
        });
    }

    #if android
    private function setupAndroidWorkingDirectory():Void
    {
        Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
    }
    #elseif ios
    private function setupIOSWorkingDirectory():Void
    {
        Sys.setCwd(lime.system.System.applicationStorageDirectory);
    }
    #end

    inline private static function resetSpriteCache(sprite:Sprite):Void
    {
        @:privateAccess {
            sprite.__cacheBitmap = null;
            sprite.__cacheBitmapData = null;
        }
    }
    #if CRASH_HANDLER
    private function onCrash(e:UncaughtErrorEvent):Void
    {
        var errMsg:String = "";
        var path:String;
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
        var dateNow:String = Date.now().toString();

        dateNow = StringTools.replace(dateNow, " ", "_");
        dateNow = StringTools.replace(dateNow, ":", "'");

        path = './crash/PsychEngine_${dateNow}.txt';


        for (stackItem in callStack)
        {
            errMsg += switch (stackItem) {
                case FilePos(s, file, line, column): '$file (line $line)\n';
                default: '$stackItem\n';
            }
        }

        errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";

        if (!FileSystem.exists("./crash/"))
            FileSystem.createDirectory("./crash/");

        File.saveContent(path, errMsg + "\n");

        Sys.println(errMsg);
        Sys.println("Crash dump saved in " + Path.normalize(path));

        Application.current.window.alert(errMsg, "Error!");
        
        #if DISCORD_ALLOWED
        DiscordClient.shutdown();
        #end

        Sys.exit(1);
    }
    #end
}

typedef GameConfig = {
    width:Int,
    height:Int,
    initialState:Class<FlxState>,
    zoom:Float,
    framerate:Int,
    skipSplash:Bool,
    startFullscreen:Bool
}
