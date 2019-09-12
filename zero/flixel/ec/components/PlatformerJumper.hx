package zero.flixel.ec.components;

import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxObject.*;
import zero.flixel.input.Controller;
import zero.flixel.ec.Component;

using zero.flixel.extensions.FlxTilemapExt;
using zero.flixel.extensions.FlxSpriteExt;

/**
 * A Component to make an entity in a platformer Jump
 */
class PlatformerJumper extends Component
{

	var jump_power:Float;
	var jump_button:ControllerButton;
	var controller:Controller;
	var coyote_time:Float;
	var gravity:Float;
	var jump_down:Bool;
	var tiles:FlxTilemap;
	var tvel:Float;
	
	var coyote_timer:Float = 0;
	var just_jumped_timer:Float = 0;
	var jump_callback:Void -> Void = function(){};
	var jump_down_callback:Void -> Void = function(){};

	/**
	 * Create a new Jumper component with options
	 * @param options 
	 */
	public function new(options:JumperOptions)
	{
		super('platformer_jumper');
		jump_power = options.jump_power;
		jump_button = options.jump_button;
		controller = options.controller;
		coyote_time = options.coyote_time;
		gravity = options.gravity;
		jump_down = options.jump_down != null;
		tvel = options.terminal_velocity != null ? options.terminal_velocity : Math.POSITIVE_INFINITY;
		if (jump_down) tiles = options.jump_down.tiles;
		if (jump_down && options.jump_down.callback != null) jump_down_callback = options.jump_down.callback;
		if (options.jump_callback != null) jump_callback = options.jump_callback;
	}

	override public function on_add()
	{
		entity.acceleration.y = gravity;
		entity.maxVelocity.y = tvel;
	}

	@:dox(hide)
	override public function update(dt:Float)
	{
		if (coyote_timer > 0) coyote_timer -= dt;
		if (just_jumped_timer > 0) just_jumped_timer -= dt;

		if (jump_down && can_jump_down()) return;

		if (entity.wasTouching & FLOOR > 0) coyote_timer = coyote_time;
		if (controller.just_pressed(jump_button)) just_jumped_timer = coyote_time;
		if (controller.just_released(jump_button) && velocity.y < 0) velocity.y *= 0.5;

		if (just_jumped_timer <= 0 || coyote_timer <= 0) return;
		jump();
	}

	function jump()
	{
		velocity.y = -jump_power;
		just_jumped_timer = 0;
		jump_callback();
	}

	function can_jump_down():Bool
	{
		if (!controller.just_pressed(jump_button) || !controller.pressed(DPAD_DOWN)) return false;
		if (entity.wasTouching & FLOOR > 0 && tiles.get_collisions_from_point(entity.get_anchor().add(0, 1)) & 0x1000 == 0) {
			y += FlxObject.SEPARATE_BIAS + 0.001;
			jump_down_callback();
		}
		return true;
	}

	/**
	 * Set controller
	 * @param c	new controller
	 * @return controller = c
	 */
	public function set_controller(c:Controller) controller = c;

}

typedef JumperOptions = 
{
	controller:Controller,
	jump_power:Float,
	jump_button:ControllerButton,
	coyote_time:Float,
	gravity:Float,
	?terminal_velocity:Float,
	?jump_down:JumpDownOptions,
	?jump_callback:Void -> Void,
}

typedef JumpDownOptions =
{
	tiles:FlxTilemap,
	?callback:Void -> Void,
}