package zero.flixel.ec.components;

import flixel.FlxObject.*;
import zero.flixel.input.Controller;
import zero.flixel.ec.Component;

/**
 * A Component to make an entity in a platformer Walk
 */
class PlatformerWalker extends Component
{

	var controller:Controller;
	var walk_speed:Float;
	var accel_amt:Float;
	var drag_amt:Float;
	var run_button:ControllerButton;
	var run_speed:Float;
	var slip_amt:Float = 0.5;

	/**
	 * Create a new Walker component with options
	 * @param options 
	 */
	public function new(options:WalkerOptions)
	{
		super('platformer_walker');
		controller = options.controller;
		walk_speed = options.walk_speed;
		accel_amt = options.acceleration_force;
		drag_amt = options.drag_force;
		if (options.slip_amt != null) slip_amt = options.slip_amt;
		if (options.run_options != null)
		{
			run_button = options.run_options.run_button;
			run_speed = options.run_options.run_speed;
		}
	}

	override function on_add()
	{
		entity.maxVelocity.x = walk_speed;
		drag.x = drag_amt;
	}
	
	@:dox(hide)
	override public function update(dt:Float)
	{
		acceleration.x = 0;
		if (controller.pressed(DPAD_LEFT)) acceleration.x -= accel_amt;
		if (controller.pressed(DPAD_RIGHT)) acceleration.x += accel_amt;
		if (entity.facing == LEFT && velocity.x > 0 || entity.facing == RIGHT && velocity.x < 0) velocity.x *= slip_amt;
		entity.facing = acceleration.x < 0 ? LEFT : acceleration.x > 0 ? RIGHT : entity.facing;
		if (run_button == null) return;
		entity.maxVelocity.x = controller.pressed(run_button) ? run_speed : walk_speed;
	}

	/**
	 * Set walk speed to given value
	 * @param v walk speed value
	 * @return walk_speed = v
	 */
	public function set_walk_speed(v:Float) walk_speed = v;

	/**
	 * Set controller
	 * @param c	new controller
	 * @return controller = c
	 */
	public function set_controller(c:Controller) controller = c;

}

typedef WalkerOptions =
{
	controller:Controller,
	walk_speed:Float,
	acceleration_force:Float,
	drag_force:Float,
	?slip_amt:Float,
	?run_options:RunOptions,
}

typedef RunOptions =
{
	run_button:ControllerButton,
	run_speed:Float,
}