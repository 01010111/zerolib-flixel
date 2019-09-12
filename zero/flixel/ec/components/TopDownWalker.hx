package zero.flixel.ec.components;

import zero.flixel.input.Controller;
import zero.flixel.ec.Component;

using Math;

/**
 * A Component to make an entity in a top down game Walk
 */
class TopDownWalker extends Component
{

	var controller:Controller;
	var walk_speed:Float;
	var accel_amt:Float;
	var drag_amt:Float;

	/**
	 * Create a new Walker component with options
	 * @param options 
	 */
	public function new(options:TopDownWalkerOptions)
	{
		super('top_down_walker');

		controller = options.controller;
		walk_speed = options.walk_speed;
		accel_amt = options.acceleration_force;
		drag_amt = options.drag_force;
	}

	override function on_add()
	{
		entity.maxVelocity.set(walk_speed, walk_speed);
		drag.set(drag_amt, drag_amt);
	}
	
	@:dox(hide)
	override public function update(dt:Float)
	{
		acceleration.set();
		if (controller.pressed(DPAD_UP)) acceleration.y -= accel_amt;
		if (controller.pressed(DPAD_DOWN)) acceleration.y += accel_amt;
		if (controller.pressed(DPAD_LEFT)) acceleration.x -= accel_amt;
		if (controller.pressed(DPAD_RIGHT)) acceleration.x += accel_amt;
	}

	/**
	 * Set controller
	 * @param c	new controller
	 * @return controller = c
	 */
	public function set_controller(c:Controller) controller = c;

}

typedef TopDownWalkerOptions = 
{
	controller:Controller,
	walk_speed:Float,
	acceleration_force:Float,
	drag_force:Float
}