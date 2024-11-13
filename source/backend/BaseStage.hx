package backend;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.FlxCamera;
import backend.MusicBeatState;
import objects.Note.EventNote;
import objects.Character;

enum Countdown {
    THREE;
    TWO;
    ONE;
    GO;
    START;
}

class BaseStage extends FlxBasic {
    private var game(default, set):Dynamic = PlayState.instance;
    public var onPlayState(default, null):Bool = false;

    // Convenience properties
    public var paused(get, never):Bool;
    public var songName(get, never):String;
    public var isStoryMode(get, never):Bool;
    public var seenCutscene(get, never):Bool;
    public var inCutscene(get, set):Bool;
    public var canPause(get, set):Bool;
    public var members(get, never):Array<FlxBasic>;

    // Character properties
    public var boyfriend(get, never):Character;
    public var dad(get, never):Character;
    public var gf(get, never):Character;
    public var boyfriendGroup(get, never):FlxSpriteGroup;
    public var dadGroup(get, never):FlxSpriteGroup;
    public var gfGroup(get, never):FlxSpriteGroup;
    
    // Camera properties
    public var camGame(get, never):FlxCamera;
    public var camHUD(get, never):FlxCamera;
    public var camOther(get, never):FlxCamera;
    public var defaultCamZoom(get, set):Float;
    public var camFollow(get, never):FlxObject;

    // Rhythm properties
    public var curBeat:Int = 0;
    public var curDecBeat:Float = 0;
    public var curStep:Int = 0;
    public var curDecStep:Float = 0;
    public var curSection:Int = 0;

    public function new() {
        super();
        this.game = MusicBeatState.getState();
        if (this.game == null) {
            FlxG.log.warn('Invalid state for the stage added!');
            destroy();
        } else {
            this.game.stages.push(this);
            create();
        }
    }

    // Main callbacks
    public function create():Void {}
    public function createPost():Void {}
    public function countdownTick(count:Countdown, num:Int):Void {}

    // Rhythm callbacks
    public function beatHit():Void {}
    public function stepHit():Void {}
    public function sectionHit():Void {}

    // Substate callbacks
    public function closeSubState():Void {}
    public function openSubState(SubState:FlxSubState):Void {}

    // Event callbacks
    public function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float):Void {}
    public function eventPushed(event:EventNote):Void {}
    public function eventPushedUnique(event:EventNote):Void {}

    // Object management methods
    public function add(object:FlxBasic):Void {
        game.add(object);
    }

    public function remove(object:FlxBasic):Void {
        game.remove(object);
    }

    public function insert(position:Int, object:FlxBasic):Void {
        game.insert(position, object);
    }
    
    public function addBehindGF(obj:FlxBasic):Void {
        insert(members.indexOf(game.gfGroup), obj);
    }

    public function addBehindBF(obj:FlxBasic):Void {
        insert(members.indexOf(game.boyfriendGroup), obj);
    }

    public function addBehindDad(obj:FlxBasic):Void {
        insert(members.indexOf(game.dadGroup), obj);
    }

    public function setDefaultGF(name:String):Void {
        var gfVersion:String = PlayState.SONG.gfVersion;
        if (gfVersion == null || gfVersion.length < 1) {
            gfVersion = name;
            PlayState.SONG.gfVersion = gfVersion;
        }
    }

    // Callback setters
    public function setStartCallback(myfn:Void->Void):Void {
        if (!onPlayState) return;
        PlayState.instance.startCallback = myfn;
    }

    public function setEndCallback(myfn:Void->Void):Void {
        if (!onPlayState) return;
        PlayState.instance.endCallback = myfn;
    }

    // PlayState method wrappers
    public function startCountdown():Bool {
        return onPlayState ? PlayState.instance.startCountdown() : false;
    }

    public function endSong():Bool {
        return onPlayState ? PlayState.instance.endSong() : false;
    }

    public function moveCamera(isDad:Bool):Void {
        if (onPlayState) PlayState.instance.moveCamera(isDad);
    }

    // Getters and setters
    private function get_paused():Bool return game.paused;
    private function get_songName():String return game.songName;
    private function get_isStoryMode():Bool return PlayState.isStoryMode;
    private function get_seenCutscene():Bool return PlayState.seenCutscene;
    private function get_inCutscene():Bool return game.inCutscene;
    private function set_inCutscene(value:Bool):Bool {
        game.inCutscene = value;
        return value;
    }
    private function get_canPause():Bool return game.canPause;
    private function set_canPause(value:Bool):Bool {
        game.canPause = value;
        return value;
    }
    private function get_members():Array<FlxBasic> return game.members;
    private function set_game(value:MusicBeatState):MusicBeatState {
        onPlayState = (Std.isOfType(value, states.PlayState));
        game = value;
        return value;
    }

    private function get_boyfriend():Character return game.boyfriend;
    private function get_dad():Character return game.dad;
    private function get_gf():Character return game.gf;

    private function get_boyfriendGroup():FlxSpriteGroup return game.boyfriendGroup;
    private function get_dadGroup():FlxSpriteGroup return game.dadGroup;
    private function get_gfGroup():FlxSpriteGroup return game.gfGroup;
    
    private function get_camGame():FlxCamera return game.camGame;
    private function get_camHUD():FlxCamera return game.camHUD;
    private function get_camOther():FlxCamera return game.camOther;

    private function get_defaultCamZoom():Float return game.defaultCamZoom;
    private function set_defaultCamZoom(value:Float):Float {
        game.defaultCamZoom = value;
        return game.defaultCamZoom;
    }
    private function get_camFollow():FlxObject return game.camFollow;
}