package zero.flixel.input;

import zero.utilities.Rect;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID as PadButton;

using zero.utilities.EventBus;

/**
 * A Simple controller using the EventBus to dispatch button presses.
 * Mimics a famicom controller in scope.
 * Has bindings for keyboard, gamepad, touch, and mouse - all of which are easy to edit or add to!
 */
class FamiController {

	/**
	 * Keyboard bindings
	 */
	public static var key_bindings:Map<String, Array<Int>> = [
		'1_UP' => [FlxKey.UP, FlxKey.W],
		'1_DOWN' => [FlxKey.DOWN, FlxKey.S],
		'1_LEFT' => [FlxKey.LEFT, FlxKey.A],
		'1_RIGHT' => [FlxKey.RIGHT, FlxKey.D],
		'1_A' => [FlxKey.X],
		'1_B' => [FlxKey.C, FlxKey.Z],
		'1_START' => [FlxKey.ENTER],
		'1_BACK' => [FlxKey.ESCAPE],
		'2_UP' => [FlxKey.I],
		'2_DOWN' => [FlxKey.K],
		'2_LEFT' => [FlxKey.J],
		'2_RIGHT' => [FlxKey.L],
		'2_A' => [FlxKey.PERIOD],
		'2_B' => [FlxKey.SLASH],
	];

	/**
	 * Gamepad bindings
	 */
	public static var pad_bindings:Map<String, Array<Int>> = [
		'UP' => [PadButton.DPAD_UP, PadButton.LEFT_STICK_DIGITAL_UP],
		'DOWN' => [PadButton.DPAD_DOWN, PadButton.LEFT_STICK_DIGITAL_DOWN],
		'LEFT' => [PadButton.DPAD_LEFT, PadButton.LEFT_STICK_DIGITAL_LEFT],
		'RIGHT' => [PadButton.DPAD_RIGHT, PadButton.LEFT_STICK_DIGITAL_RIGHT],
		'A' => [PadButton.A, PadButton.LEFT_SHOULDER, PadButton.LEFT_TRIGGER_BUTTON],
		'B' => [PadButton.B, PadButton.RIGHT_SHOULDER, PadButton.RIGHT_TRIGGER_BUTTON],
		'START' => [PadButton.START],
		'BACK' => [PadButton.BACK],
	];

	/**
	 * Touch bindings - bound to rectangles representing areas on the screen
	 * For example, a rectangle representing the right side of the screen:
	 * ```haxe
	 * [0.5, 0, 0.5, 1] // x, y, width, height
	 * ```
	 */
	public static var touch_bindings:Map<String, Rect> = [
		'UP' => [0, 0, 0, 0],
		'DOWN' => [0, 0, 0, 0],
		'LEFT' => [0, 0.25, 0.25, 1],
		'RIGHT' => [0.25, 0.25, 0.25, 1],
		'A' => [0.5, 0.25, 0.25, 1],
		'B' => [0.75, 0.25, 0.25, 1],
		'START' => [0, 0, 0.5, 0.25],
		'BACK' => [0.5, 0, 0.5, 0.25],
	];

	// Mouse bindings - defaults to touch_bindings, then falls back on mouse buttons
	public static var mouse_bindings:Map<String, MouseButton> = [
		'A' => LEFT,
		'B' => RIGHT,
		'START' => MIDDLE,
	];

	/**
	 * Type safe helper for returning a button state, ie: `1_LEFT_JUST_PRESSED`
	 * @param button 
	 * @param state 
	 * @param player 
	 */
	public static function button(button:Button, state:ButtonState, player:Int = 1):String {
		return '${player}_${button}_${state}';
	}

	// Run this every frame
	public static function update(?dt:Float) {
		#if !FLX_NO_KEYBOARD keyboard(); #end
		#if !FLX_NO_GAMEPADS gamepads(); #end
		#if !FLX_NO_MOUSE mouse(); #end
		#if !FLX_NO_TOUCH touch(); #end
	}

	#if !FLX_NO_KEYBOARD
	static function keyboard() {
		for (button => keys in key_bindings) {
			if (FlxG.keys.anyJustPressed(keys)) '${button}_JUST_PRESSED'.dispatch();
			if (FlxG.keys.anyPressed(keys)) '${button}_PRESSED'.dispatch();
			if (FlxG.keys.anyJustReleased(keys)) '${button}_JUST_RELEASED'.dispatch();
		}
	}
	#end

	#if !FLX_NO_GAMEPADS
	static function gamepads() {
		for (id in FlxG.gamepads.getActiveGamepadIDs()) {
			var gamepad = FlxG.gamepads.getByID(id);
			for (button => buttons in pad_bindings) if (gamepad.anyJustPressed(buttons)) '${id}_${button}_JUST_PRESSED'.dispatch();
			for (button => buttons in pad_bindings) if (gamepad.anyPressed(buttons)) '${id}_${button}_PRESSED'.dispatch();
			for (button => buttons in pad_bindings) if (gamepad.anyJustReleased(buttons)) '${id}_${button}_JUST_RELEASED'.dispatch();
		}
	}
	#end

	#if !FLX_NO_MOUSE
	static function mouse() {
		for (button => rect in touch_bindings) {
			if (FlxG.mouse.y < rect.top * FlxG.height) continue;
			if (FlxG.mouse.y > rect.bottom * FlxG.height) continue;
			if (FlxG.mouse.x < rect.left * FlxG.width) continue;
			if (FlxG.mouse.x > rect.right * FlxG.width) continue;
			if (FlxG.mouse.justPressed) return '1_${button}_JUST_PRESSED'.dispatch();
			if (FlxG.mouse.pressed) return '1_${button}_PRESSED'.dispatch();
			if (FlxG.mouse.justReleased) return '1_${button}_JUST_RELEASED'.dispatch();
		}
		for (button => mouse_button in mouse_bindings) switch mouse_button {
			case LEFT:
				if (FlxG.mouse.justPressed) '1_${button}_JUST_PRESSED'.dispatch();
				if (FlxG.mouse.pressed) '1_${button}_PRESSED'.dispatch();
				if (FlxG.mouse.justReleased) '1_${button}_JUST_RELEASED'.dispatch();
			case RIGHT:
				#if !FLX_NO_MOUSE_ADVANCED
				if (FlxG.mouse.justPressedRight) '1_${button}_JUST_PRESSED'.dispatch();
				if (FlxG.mouse.pressedRight) '1_${button}_PRESSED'.dispatch();
				if (FlxG.mouse.justReleasedRight) '1_${button}_JUST_RELEASED'.dispatch();
				#end
			case MIDDLE:
				#if !FLX_NO_MOUSE_ADVANCED
				if (FlxG.mouse.justPressedMiddle) '1_${button}_JUST_PRESSED'.dispatch();
				if (FlxG.mouse.pressedMiddle) '1_${button}_PRESSED'.dispatch();
				if (FlxG.mouse.justReleasedMiddle) '1_${button}_JUST_RELEASED'.dispatch();
				#end
		}		
	}
	#end

	#if !FLX_NO_TOUCH
	static function touch() {
		for (touch in FlxG.touches.list) for (button => rect in touch_bindings) {
			if (touch.y < rect.top * FlxG.height) continue;
			if (touch.y > rect.bottom * FlxG.height) continue;
			if (touch.x < rect.left * FlxG.width) continue;
			if (touch.x > rect.right * FlxG.width) continue;
			if (touch.justPressed) '1_${button}_JUST_PRESSED'.dispatch();
			if (touch.pressed) '1_${button}_PRESSED'.dispatch();
			if (touch.justReleased) '1_${button}_JUST_RELEASED'.dispatch();
		}
	}
	#end

}

enum Button {
	UP;
	DOWN;
	LEFT;
	RIGHT;
	A;
	B;
	START;
	BACK;
}

enum ButtonState {
	JUST_PRESSED;
	PRESSED;
	JUST_RELEASED;
}

enum MouseButton {
	LEFT;
	RIGHT;
	MIDDLE;
}