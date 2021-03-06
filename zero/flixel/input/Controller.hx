package zero.flixel.input;

import flixel.FlxG;
import flixel.FlxBasic;

using Math;

/**
 *  A Controller class using standard controller buttons (XBox360 Controller)
 */
class Controller extends FlxBasic
{

	/**
	 *  The current state of the controller
	 */
	public var state:Map<ControllerButton, Bool> = new Map();
	public var protected:Bool = false;

	var history:Array<Map<ControllerButton, Bool>> = [];
	var max_history:Int = 1;

	/**
	 *  Creates a new Controller instance
	 */
	public function new()
	{
		super();
		for (button in Type.allEnums(ControllerButton)) state.set(button, false);
	}

	@:dox(hide)
	override public function update(dt:Float)
	{
		var last_state = state.copy();
		history.push(last_state);
		while (history.length > max_history) history.shift();
		super.update(dt);
		set(dt);
	}

	@:dox(show)
	/**
	 *  Override this to set controller buttons instead of update()
	 *  @param dt	delta time
	 */
	function set(dt:Float){}

	@:dox(show)
	/**
	 *  Call this to add the controller to the state instead of [FlxState].add(controller)
	 */
	public function add() {
		FlxG.state.add(this);
		return this;
	}

	/**
	 *  Returns a history of states for the controller
	 *  @return	Array<Map<ControllerButton, Bool>>
	 */
	public inline function get_history():Array<Map<ControllerButton, Bool>> return history;

	/**
	 *  Set the maximum number of history states
	 *  @param length	length of max history states
	 */
	public inline function set_max_history(length:Int) max_history = length.max(1).floor();

	/**
	 *  Set button state
	 *  @param button	button to set
	 *  @param pressed	whether it's pressed or not
	 */
	public inline function set_button(button:ControllerButton, pressed:Bool) state.set(button, pressed);

	/**
	 *  Gets the pressed state of a button
	 *  @param button	button query
	 *  @return			Bool
	 */
	public function pressed(button:ControllerButton):Bool return state[button];

	/**
	 *  Gets the just pressed state of a button
	 *  @param button	button query
	 *  @return			Bool
	 */
	public function just_pressed(button:ControllerButton):Bool history.length == 0 ? return false : return state[button] && !history[history.length - 1][button];
	
	/**
	 *  Gets the just released state of a button
	 *  @param button	button query
	 *  @return			Bool
	 */
	public function just_released(button:ControllerButton):Bool history.length == 0 ? return false : return !state[button] && history[history.length - 1][button];

	override public function destroy()
	{
		if (protected) return;
		super.destroy();
	}

}

enum ControllerButton
{
	FACE_A;
	FACE_B;
	FACE_X;
	FACE_Y;
	DPAD_UP;
	DPAD_DOWN;
	DPAD_LEFT;
	DPAD_RIGHT;
	UTIL_START;
	UTIL_SELECT;
	BUMPER_LEFT;
	BUMPER_RIGHT;
	TRIGGER_LEFT;
	TRIGGER_RIGHT;
	LEFT_ANALOG_UP;
	LEFT_ANALOG_DOWN;
	LEFT_ANALOG_LEFT;
	LEFT_ANALOG_RIGHT;
	LEFT_ANALOG_CLICK;
	RIGHT_ANALOG_UP;
	RIGHT_ANALOG_DOWN;
	RIGHT_ANALOG_LEFT;
	RIGHT_ANALOG_RIGHT;
	RIGHT_ANALOG_CLICK;
	GUIDE;
}