package modding;

import polymod.backends.OpenFLBackend;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules.LinesParseFormat;
import polymod.format.ParseRules.TextFileFormat;
import polymod.format.ParseRules;
import polymod.Polymod;

import sys.FileSystem;
import flixel.FlxG;
import backend.Paths;

class PsychMod
{
	private static final MOD_DIR:String = 'mods';

	public static var loadedMods = ["fuck"]; // enabled mods

	public static function initialize():Void
	{
		if (!FileSystem.exists(MOD_DIR))
		{
			trace('Mods Folder Missing. Creating $MOD_DIR folder...');
			FileSystem.createDirectory(MOD_DIR);
			return;
		}
		trace("Initializing PsychMod...");
		
		Polymod.init({
			// Root directory for all mods.
			modRoot: MOD_DIR,
			// Call this function any time an error occurs.
			errorCallback: onPolymodError,

			frameworkParams: {
				assetLibraryPaths: [
					"default" => "./",
					"songs" => "./songs",
					"shared" => "./shared",
					"videos" => "./videos"
				]
			},
			// List of filenames to ignore in mods. Use the default list to ignore the metadata file, etc.
			ignoredFiles: Polymod.getDefaultIgnoreList()
		});

		trace(curMod);
		Polymod.loadOnlyMods(loadedMods);
	}

	static function onPolymodError(error:PolymodError):Void
	{
		// Perform an action based on the error code.
		switch (error.code)
		{
			case MISSING_ICON:
			default:
				// Log the message based on its severity.
				switch (error.severity)
				{
					case NOTICE:
					case WARNING:
						trace(error.message, null);
					case ERROR:
						trace(error.message, null);
				}
		}
	}
}