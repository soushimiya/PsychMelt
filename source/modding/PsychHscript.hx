package modding;

import hscriptImproved.Parser;
import hscriptImproved.Interp;

using StringTools;

class PsychHscript extends Interp
{
    public var parent:Dynamic;

    override public function new(scriptToRun:String){
        super();
        setVariables();

        var parser = new Parser();
        parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;

        execute(parser.parseString(scriptToRun));
    }

    //call Function in Interp
    public function callFunc(func:String, ?args:Array<Dynamic>):Dynamic {
		if (variables.exists(func)) {
			if (args == null){ args = []; }

			try {
				return Reflect.callMethod(null, variables.get(func), args);
			}
			catch(e){
				trace(e.message);
            }
		}
		return null;
	}

    //import some default classes
    private function setVariables(){
        variables.set('add', flixel.FlxG.state.add);
		variables.set('insert', flixel.FlxG.state.insert);
		variables.set('remove', flixel.FlxG.state.remove);
    }
}