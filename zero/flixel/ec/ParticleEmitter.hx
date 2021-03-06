package zero.flixel.ec;

import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import zero.flixel.ec.Entity;

using zero.flixel.utilities.FlxTags;

/**
 * A particle emitter class.
 */
class ParticleEmitter extends FlxTypedGroup<Particle>
{

	var new_particle:Void -> Particle;

	/**
	 * Creates a new particle emitter
	 * @param new_particle	a function that returns the desired Particle
	 */
	public function new(new_particle:Void -> Particle)
	{
		super();
		this.new_particle = new_particle;
	}

	/**
	 * Fires a particle with given options. If none are available, it will create a new particle using the function passed in new()
	 * @param options 
	 */
	public function fire(options:FireOptions)
	{
		while (getFirstAvailable() == null) add(new_particle());
		var particle = getFirstAvailable();
		particle.fire(options);
		return particle;
	}

}

/**
 * A particle class
 */
class Particle extends Entity
{

	/**
	 * Creates a new particle
	 */
	public function new()
	{
		super();
		this.add_tag('particle');
		exists = false;
	}

	/**
	 * Fires this particle with given options
	 * @param options 
	 */
	public function fire(options:FireOptions)
	{
		reset(options.position.x, options.position.y);
		if (options.acceleration != null)	acceleration.copyFrom(options.acceleration);
		if (options.velocity != null)		velocity.copyFrom(options.velocity);
		if (options.animation != null)		animation.play(options.animation, true);
	}

}

typedef FireOptions =
{
	position:FlxPoint,
	?velocity:FlxPoint,
	?acceleration:FlxPoint,
	?animation:String,
	?util_amount:Float,
	?util_color:Int,
	?util_int:Int,
	?util_bool:Bool,
	?data:Dynamic,
}