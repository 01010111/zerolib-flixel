package zero.flixel.ec.components;

import zero.flixel.ec.Component;

class KillAfterAnimation extends Component
{

	/**
	 * Kills an entity after it's animation is finished
	 * @return super('kill_after_animation')
	 */
	public function new() super('kill_after_animation');

	@:dox(hide)
	override public function update(dt:Float) if (entity.animation.finished) entity.kill();

}