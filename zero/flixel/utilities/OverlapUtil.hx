package zero.flixel.utilities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
using zero.flixel.utilities.FlxTags;

/**
	A Utility used in conjunction with `FlxTags` to reduce the amount of times you build a Quadtree to check for overlaps/collisions.
	Usage (in a `FlxState`):
	```
	// create Overlap Util and your objects
	var overlap = new OverlapUtil();
	var sprite1 = new FlxSprite();
	var sprite2 = new FlxSprite();

	// add tags to sprites using FlxTags
	sprite1.add_tag('my_tag1');
	sprite2.add_tag('my_tag2');

	// add Overlap Util and your objects to state
	add(overlap);
	add(sprite1);
	add(sprite2);

	// add overlap listeners
	overlap.listen({
		tag1: 'my_tag1',
		tag2: 'my_tag2',
		separate: true,
		callback: (o1, o2) -> o2.kill()
	})
	```
**/
class OverlapUtil extends FlxObject {

	var objects:FlxGroup = new FlxGroup();
	var pairs:Array<ObjectPair> = [];
	var listeners:Array<Listener> = [];

	public function add(object:FlxObject) objects.add(object);
	public function remove(object:FlxObject) objects.remove(object);
	public function listen(listener:Listener) listeners.push(listener);

	override function update(elapsed:Float) {
		FlxG.overlap(objects, objects, (o1, o2) -> pairs.push(ObjectPair.get(o1, o2)));
		process_pairs();
	}
	
	function process_pairs() {
		var process = (o1, o2, listener) -> {
			if (listener.separate) FlxObject.separate(o1, o2);
			if (listener.callback != null) listener.callback(o1, o2);
		}
		for (listener in listeners) for (pair in pairs) {
			if (pair.o1.has_tag(listener.tag1) && pair.o2.has_tag(listener.tag2)) process(pair.o1, pair.o2, listener);
			else if (pair.o1.has_tag(listener.tag2) && pair.o2.has_tag(listener.tag1)) process(pair.o2, pair.o1, listener);
		}
		while (pairs.length > 0) pairs.shift().put();
	}

}

private class ObjectPair {

	public static var pool:Array<ObjectPair> = [];
	public static function get(o1:FlxObject, o2:FlxObject):ObjectPair {
		return pool.length > 0 ? pool.shift().set(o1, o2) : new ObjectPair().set(o1, o2);
	}

	public var o1:FlxObject;
	public var o2:FlxObject;

	function new() {}
	public function put() pool.push(this);

	function set(o1:FlxObject, o2:FlxObject) {
		this.o1 = o1;
		this.o2 = o2;
		return this;
	}

}

typedef Listener = {
	tag1:String,
	tag2:String,
	separate:Bool,
	?callback:FlxObject -> FlxObject -> Void
}