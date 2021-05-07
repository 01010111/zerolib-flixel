package zero.flixel.utilities;

import flixel.FlxObject;

using zero.extensions.ArrayExt;

/**
	A Utility for adding tags to objects, checking to see if an object has a tag, and getting all objects with a specific tag.
	Usage:
	```
	// in your imports header:
	using zero.flixel.utilities.FlxTags;

	// elsewhere...
	var sprite1 = new FlxObject();
	var sprite2 = new FlxSprite();

	sprite1.add_tag('object');
	sprite2.add_tags(['object', 'pickup']);

	sprite2.has_tag('pickup'); // true
	FlxTags.get_objects('object'); // [sprite1, sprite2]
	```
**/
class FlxTags {
	
	static var map:Map<String, Array<FlxObject>> = [];

    public static function add_tag(object:FlxObject, tag:String) {
		if (!map.exists(tag)) map.set(tag, []);
		map[tag].push(object);
	}

	public static function add_tags(object:FlxObject, tags:Array<String>) {
		for (tag in tags) add_tag(object, tag);
	}

	public static function remove_tag(object:FlxObject, tag:String) {
		return map.exists(tag) && map[tag].remove(object);
	}

	public static function has_tag(object:FlxObject, tag:String):Bool {
		return map.exists(tag) && map[tag].contains(object);
	}	

	public static function remove_all_tags(object:FlxObject) {
		for (array in map) array.remove(object);
	}

	public static function get_objects(tag:String, only_alive:Bool = false):Array<FlxObject> {
		if (!map.exists(tag)) return [];
		for (object in map[tag]) if (object == null) map[tag].remove(object);
		var out = map[tag].copy();
		if (only_alive) return [for (object in out) if (object.alive) object];
		return out;
	}

	public static function clear_tags() map = [];

}