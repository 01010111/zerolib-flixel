package zero.flixel.states;

import flixel.FlxG;
import flixel.FlxState;

using zero.utilities.EventBus;

/**
 *  An extended FlxState
 */
class State extends FlxState
{
		
	@:dox(hide)
	override public function update(dt:Float) {
		'preupdate'.dispatch(dt);
		'update'.dispatch(dt);
		super.update(dt);
		'postupdate'.dispatch(dt);
		#if debug if (FlxG.keys.justPressed.R && FlxG.keys.pressed.ALT) FlxG.resetState(); #end
	}

}