package zero.flixel.states;

import flixel.FlxG;
import flixel.FlxState;

using zero.utilities.EventBus;

/**
 *  An extended FlxState
 */
class State extends FlxState
{

	/**
	 *  Creates a new State with some options
	 *  @param mouse_visible	whether or not the mouse is visible
	 *  @param esc_exits		whether or not pressing ESC on cpp targets will exit the game
	 */
	public function new(mouse_visible:Bool = false, esc_exits:Bool = false)
	{
		#if !mobile 
			FlxG.mouse.visible = mouse_visible;			
			#if cpp if (esc_exits) ((?_) -> if (FlxG.keys.justPressed.ESCAPE) lime.system.System.exit(0)).listen('update'); #end
			#if debug ((?_) -> if (FlxG.keys.justPressed.R && FlxG.keys.pressed.ALT) FlxG.resetState()).listen('update'); #end
		#end
		super();
	}

	@:dox(hide)
	override public function update(dt:Float)
	{
		'preupdate'.dispatch(dt);
		'update'.dispatch(dt);
		super.update(dt);
		'postupdate'.dispatch(dt);
	}

}