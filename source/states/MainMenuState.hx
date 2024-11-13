package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
    public static final psychEngineVersion:String = '0.7.3';
    public static var curSelected:Int = 0;

    private var menuItems:FlxTypedGroup<FlxSprite>;
    private var camFollow:FlxObject;
    private var selectedSomethin:Bool = false;

    inline static final MENU_ITEM_VERTICAL_SPACING:Float = 140;
    inline static final MENU_ITEM_INITIAL_OFFSET:Float = 108;

    final MENU_ITEMS:Array<String> = [
        'story_mode',
        'freeplay',
        #if ACHIEVEMENTS_ALLOWED 'awards', #end
        'credits',
        #if !switch 'donate', #end
        'options'
    ];

    override function create()
    {
        super.create();
        
        setupDiscord();
        setupTransitions();
        setupBackground();
        setupMenuItems();
        setupVersionText();
        setupAchievements();

        FlxG.camera.follow(camFollow, null, 9);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        updateMusicVolume(elapsed);

        if (!selectedSomethin)
        {
            handleMenuNavigation();
        }
    }

    private function setupDiscord():Void
    {
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("In the Menus", null);
        #end
    }

    private function setupTransitions():Void
    {
        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;
        persistentUpdate = persistentDraw = true;
    }

    private function setupBackground():Void
    {
        var yScroll:Float = Math.max(0.25 - (0.05 * (MENU_ITEMS.length - 4)), 0.1);
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.scrollFactor.set(0, yScroll);
        bg.setGraphicSize(Std.int(bg.width * 1.175));
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);
    }

    private function setupMenuItems():Void
    {
        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        var offset:Float = MENU_ITEM_INITIAL_OFFSET - (Math.max(MENU_ITEMS.length, 4) - 4) * 80;
        
        for (i in 0...MENU_ITEMS.length)
        {
            var menuItem:FlxSprite = new FlxSprite(0, (i * MENU_ITEM_VERTICAL_SPACING) + offset);
            menuItem.antialiasing = ClientPrefs.data.antialiasing;
            menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + MENU_ITEMS[i]);
            menuItem.animation.addByPrefix('idle', MENU_ITEMS[i] + " basic", 24);
            menuItem.animation.addByPrefix('selected', MENU_ITEMS[i] + " white", 24);
            menuItem.animation.play('idle');
            menuItems.add(menuItem);

            var scr:Float = (MENU_ITEMS.length > 4) ? (MENU_ITEMS.length - 4) * 0.135 : 0;
            if (MENU_ITEMS.length < 6) scr = 0;
            menuItem.scrollFactor.set(0, scr);
            menuItem.updateHitbox();
            menuItem.screenCenter(X);
        }

        changeItem();
    }

    private function setupVersionText():Void
    {
        var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
        psychVer.scrollFactor.set();
        psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(psychVer);

        var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
        fnfVer.scrollFactor.set();
        fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(fnfVer);
    }

    private function setupAchievements():Void
    {
        #if ACHIEVEMENTS_ALLOWED
        var leDate = Date.now();
        if (leDate.getDay() == 5 && leDate.getHours() >= 18)
            Achievements.unlock('friday_night_play');
        #end
    }

    private function updateMusicVolume(elapsed:Float):Void
    {
        if (FlxG.sound.music.volume < 0.8)
        {
            FlxG.sound.music.volume += 0.5 * elapsed;
            if (FreeplayState.vocals != null)
                FreeplayState.vocals.volume += 0.5 * elapsed;
        }
    }

    private function handleMenuNavigation():Void
    {
        if (controls.UI_UP_P)
            changeItem(-1);

        if (controls.UI_DOWN_P)
            changeItem(1);

        if (controls.BACK)
        {
            selectedSomethin = true;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new TitleState());
        }

        if (controls.ACCEPT)
        {
            selectMenuItem();
        }

        #if desktop
        if (controls.justPressed('debug_1'))
        {
            selectedSomethin = true;
            MusicBeatState.switchState(new MasterEditorMenu());
        }
        #end
    }

    private function selectMenuItem():Void
    {
        if (MENU_ITEMS[curSelected] == 'donate')
        {
            CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
        }
        else
        {
            selectedSomethin = true;
            FlxG.sound.play(Paths.sound('confirmMenu'));

            FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
            {
                switch (MENU_ITEMS[curSelected])
                {
                    case 'story_mode':
                        MusicBeatState.switchState(new StoryMenuState());
                    case 'freeplay':
                        MusicBeatState.switchState(new FreeplayState());
                    #if ACHIEVEMENTS_ALLOWED
                    case 'awards':
                        MusicBeatState.switchState(new AchievementsMenuState());
                    #end
                    case 'credits':
                        MusicBeatState.switchState(new CreditsState());
                    case 'options':
                        loadOptionsState();
                }
            });

            for (i in 0...menuItems.members.length)
            {
                if (i == curSelected) continue;
                FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
                    ease: FlxEase.quadOut,
                    onComplete: function(twn:FlxTween)
                    {
                        menuItems.members[i].kill();
                    }
                });
            }
        }
    }

    private function loadOptionsState():Void
    {
        MusicBeatState.switchState(new OptionsState());
        OptionsState.onPlayState = false;
        if (PlayState.SONG != null)
        {
            PlayState.SONG.arrowSkin = null;
            PlayState.SONG.splashSkin = null;
            PlayState.stageUI = 'normal';
        }
    }

    function changeItem(huh:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        
        curSelected = FlxMath.wrap(curSelected + huh, 0, menuItems.length - 1);

        menuItems.forEach(function(spr:FlxSprite)
        {
            spr.animation.play('idle');
            spr.updateHitbox();
            spr.screenCenter(X);
        });

        menuItems.members[curSelected].animation.play('selected');
        menuItems.members[curSelected].centerOffsets();
        menuItems.members[curSelected].screenCenter(X);

        var newY = menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0);
        camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x, newY);
    }
}
