package modding;

import objects.MusicBeatState;
import backend.Paths;
import states.MainMenuState;
import openfl.utils.Assets;

class HscriptState extends MusicBeatState
{
	public var script:PsychHscript;
	static  public var state:String = "";

	override function create()
	{
		var path:String = Paths.getSharedPath('states/$state.hx');
		if (!FileSystem.exists(path)) {
			trace('[HscriptState] No State Found! ($path)');
			return;
		}
		script = new PsychHscript(Assets.getText(path));
		trace('[HscriptState] Loaded State! ($path)');
		script.callFunc('create');

		super.create();
	}

	override function update(elapsed:Float)
	{
		script.callFunc('update');
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	override function stepHit()
	{
		script.callFunc('stepHit');
		super.stepHit();
	}

	override function beatHit()
	{
		script.callFunc('beatHit');
		super.beatHit();
	}

	override function sectionHit()
	{
		script.callFunc('sectionHit');
		super.sectionHit();
	}
}