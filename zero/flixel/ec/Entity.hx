package zero.flixel.ec;

import flixel.FlxSprite;
import zero.flixel.utilities.GameLog.*;

/**
 *  An Entity class for some light-weight ECS behavior in Flixel
 */
class Entity extends FlxSprite
{

	var components:Map<String, Component> = new Map();
	var name:String = 'Unknown';

	/**
	 *  Creates a new Entity with given options
	 *  @param options	EntityOptions - {
	 *  	?x:Float						x position,
	 *  	?y:Float						y position,
	 *  	?name:String					Entity name,
	 *  	?components:Array<Component>	an array of components to be added to this Entity
	 *  }
	 */
	public function new(?options:EntityOptions)
	{
		if (options == null) options = {};
		if (options.x == null) options.x = 0;
		if (options.y == null) options.y = 0;
		if (options.name != null) name = options.name;
		super(options.x, options.y);
		if (options.components == null) return;
		for (c in options.components) add_component(c);
	}

	/**
	 *  Add a component to this Entity
	 *  @param component	Component to be added to this entity
	 */
	public function add_component(component:Component)
	{
		if (components.exists(component.get_name())) LOG('Component with name: ${component.get_name()} already exists!', WARNING);
		else components.set(component.get_name(), component);
		component.add_to(this);
	}

	/**
	 *  Remove a component from this Entity
	 *  @param name	the component's name
	 */
	public function remove_component(name:String)
	{
		if (!components.exists(name))
		{
			LOG('No components with name: $name exist!', WARNING);
			return;
		}
		components[name].on_remove();
		components.remove(name);
	}

	/**
	 *  Get component with name
	 *  @param name	component name
	 *  @return Null<Component>
	 */
	public function get_component(name:String):Null<Component>
	{
		if (!components.exists(name)) LOG('No components with name: $name exist!', ERROR);
		return components[name];
	}
	
	/**
	 *  returns the name of this Entity
	 *  @return	String
	 */
	public inline function get_name():String return name;

	@:dox(hide)
	override public function update(dt:Float)
	{
		update_components(dt);
		super.update(dt);
	}

	function update_components(dt:Float)
	{
		for (c in components) if (c.active) c.update(dt);
	}

	function update_components_by_priority(dt:Float)
	{
		var comps = Lambda.array(components);
		comps.sort(function(c1:Component, c2:Component){
			if (c1.get_priority() < c2.get_priority()) return -1;
			if (c1.get_priority() > c2.get_priority()) return 1;
			return 0;
		});
		for (c in comps) if (c.active) c.update(dt);
	}

}

typedef EntityOptions =
{
	?x:Float,
	?y:Float,
	?name:String,
	?components:Array<Component>,
}