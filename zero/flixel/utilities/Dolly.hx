package zero.flixel.utilities;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import zero.flixel.ec.Component;
import flixel.FlxG;
import zero.flixel.ec.Entity;
import flixel.FlxCamera;

using Math;
using zero.extensions.FloatExt;
using flixel.util.FlxSpriteUtil;
using zero.flixel.extensions.FlxPointExt;
using zero.flixel.extensions.FlxSpriteExt;

/**
 * A handy camera dolly with several advanced features
 * Thanks to Itay Keren and his amazing GDC talk "Scroll Back: The Theory and Practice of Cameras in Side-Scrollers"
 */
class Dolly extends Entity
{

	public static var c:Int = 0;

	var lerp:{ x:Float, y:Float };
	var target_position:{ x:Float, y:Float } = { x: 0, y: 0 };
	var target_object:FlxObject;

	/**
	 * Creates a new Dolly with given options.
	 *	target:FlxObject,
	 *	?camera:FlxCamera,
	 *	?lerp:Float,
	 *	?max_velocity:{ x:Float, y:Float },
	 * @param options 
	 */
	public function new(options:DollyOptions)
	{
		super({ name: 'Camera Dolly' });
		init_graphic(FlxG.width, FlxG.height);
		options.camera == null ? FlxG.camera.follow(this) : options.camera.follow(this);
		lerp = options.lerp == null ? { x: 0.1, y: 0.1 } : options.lerp;
		if (options.max_velocity != null) maxVelocity.copy_from_simple(options.max_velocity);
		set_target(options.target, true);

		FlxG.watch.add(this, 'x');
		FlxG.watch.add(this, 'y');
		FlxG.watch.add(this, 'target_position');
	}

	override function add_component(component:Component)
	{
		component.set_priority(c);
		super.add_component(component);
		c++;
	}

	function init_graphic(width:Int, height:Int)
	{
		#if CAM_DEBUG
		makeGraphic(width, height, 0x00FFFFFF);
		this.drawCircle(width/2, height/2, 2, 0xFFFF004D);
		offset.set(width/2, height/2);
		setSize(0, 0);
		#else 
		makeGraphic(1, 1, 0x00FFFFFF);
		#end
	}

	/**
	 * Sets the target for the dolly
	 * @param target	FlxObject
	 * @param snap		Whether or not to immediately snap dolly to target
	 */
	public function set_target(target:FlxObject, snap:Bool = false)
	{
		target_object = target;
		if (!snap) return;
		var m = target_object.getMidpoint();
		setPosition(m.x, m.y);
	}

	override function update(dt:Float)
	{
		x += ((target_position.x - x) * lerp.x).clamp(-maxVelocity.x * dt, maxVelocity.x * dt);
		y += ((target_position.y - y) * lerp.y).clamp(-maxVelocity.y * dt, maxVelocity.y * dt);
		super.update(dt);
	}

	override function update_components(dt:Float)
	{
		super.update_components_by_priority(dt);
	}

	public function set_position_x(x:Float) target_position.x = x;
	public function set_position_y(y:Float) target_position.y = y;
	public function set_position_x_relative(x:Float) target_position.x = this.x + x;
	public function set_position_y_relative(y:Float) target_position.y = this.y + y;
	public function set_position(x:Float, y:Float) target_position = { x: x, y: y };
	public function set_position_relative(x:Float, y:Float) target_position = { x: this.x + x, y: this.y + y };
	public function set_position_from_flxpoint(p:FlxPoint) target_position = { x: p.x, y: p.y };

	public function get_target():FlxObject return target_object;
	public function get_position():{ x:Float, y:Float } return target_position;

}

/**
 * The equivalent of FlxCameraFollowStyle.LOCKON, might come in handy
 */
class FollowTarget extends Component
{

	var dolly:Dolly;
	public function new() { super('Follow Target'); }
	override function on_add() dolly = cast entity;
	override function update(dt:Float) dolly.set_position_from_flxpoint(dolly.get_target().getMidpoint());

}

/**
 * Creates a window constraint. When target is outside the window, the dolly will move to get it back inside.
 */
class WindowConstraint extends Component
{

	var width:Float;
	var height:Float;
	var dolly:Dolly;
	var axes:EAxes;

	public function new(options:WindowConstraintOptions)
	{
		super('${Dolly.c} Follow Window Rect');
		width = options.width;
		height = options.height;
		axes = options.axes == null ? BOTH : options.axes;
	}

	override function on_add()
	{
		dolly = cast entity;
		#if CAM_DEBUG
		dolly.drawRect(FlxG.width/2 - width/2, FlxG.height/2 - height/2, width, height, 0x00FFFFFF, { thickness: 1, color: 0xFFFF004D });
		#end
	}

	override function update(dt:Float)
	{
		var rect1 = FlxRect.get(x - width/2, y - height/2, width, height);
		var rect2 = get_object_rect(dolly.get_target());
		var diff = get_diff(rect1, rect2);
		rect1.put();
		rect2.put();
		if (diff.x == 0 && diff.y == 0) return;
		dolly.set_position_relative(diff.x, diff.y);
	}

	function get_diff(r1:FlxRect, r2:FlxRect):{ x:Float, y:Float }
	{
		var out = { x: 0.0, y: 0.0 };
		if ((axes == HORIZONTAL || axes == BOTH) && r1.left > r2.left) out.x = r2.left - r1.left;
		else if ((axes == HORIZONTAL || axes == BOTH) && r1.right < r2.right) out.x = r2.right - r1.right;
		if ((axes == VERTICAL || axes == BOTH) && r1.top > r2.top) out.y = r2.top - r1.top;
		else if ((axes == VERTICAL || axes == BOTH) && r1.bottom < r2.bottom) out.y = r2.bottom - r1.bottom;
		return out;
	}

	function get_object_rect(object:FlxObject):FlxRect
	{
		return FlxRect.get(object.x, object.y, object.width, object.height);
	}

}

/**
 * Will move the dolly to meet a target's vertical position when a target is touching the ground
 */
class PlatformSnap extends Component
{

	var dolly:Dolly;
	var offset:Float;

	public function set_offset(value:Float) offset = value;

	public function new(options:PlatformSnapOptions)
	{
		super('${Dolly.c} Platform Snap');
		offset = options.offset == null ? 0 : options.offset;
	}

	override function on_add()
	{
		dolly = cast entity;
		#if CAM_DEBUG
		dolly.drawLine(0, FlxG.height/2 + offset, FlxG.width, FlxG.height/2 + offset, { thickness: 1, color: 0xFFFF004D });
		#end
	}

	override function update(dt:Float)
	{
		if (dolly.get_target().wasTouching & FlxObject.FLOOR > 0 && dolly.get_target().velocity.y >= 0) dolly.set_position_y(dolly.get_target().y + dolly.get_target().height - offset);
	}

}

/**
 * When a target overlaps one of the given rectangles, the dolly will center on the overlapped rectangle
 */
class AreaOverride extends Component
{

	var rects:Array<FlxRect>;
	var dolly:Dolly;

	public function add_rect(rect:FlxRect) rects.push(rect);
	public function remove_rect(rect:FlxRect) rects.remove(rect);

	public function new(options:AreaOverrideOptions)
	{
		super('${Dolly.c} Area Override');
		rects = options.rects;
	}

	override function on_add()
	{
		dolly = cast entity;
		#if CAM_DEBUG
		for (rect in rects)
		{
			var s = new FlxSprite(rect.x, rect.y);
			s.makeGraphic(rect.width.to_int(), rect.height.to_int(), 0x00FFFFFF);
			s.draw_dashed_rect(FlxRect.get(0.5, 0.5, rect.width - 1, rect.height - 1), 8, 0xFF0080FF);
			FlxG.state.add(s);
		}
		#end
	}

	override function update(dt:Float)
	{
		var t = dolly.get_target();
		for (rect in rects)
		{
			if (t.x + t.width > rect.left && t.x < rect.right && t.y + t.height > rect.top && t.y < rect.bottom) override_target(rect);
		}
	}

	function override_target(rect:FlxRect)
	{
		dolly.set_position(rect.x + rect.width/2, rect.y + rect.height/2);
	}

}

/**
 * The dolly will move to look ahead of a target
 */
class ForwardFocus extends Component
{

	var dolly:Dolly;
	var offset:Float;
	var threshold:Float;
	var direction:Int = 1;
	var last_x:Float;

	public function set_offset(value:Float) offset = value;
	public function set_threshold(value:Float) threshold = value;

	public function new(options:ForwardFocusOptions)
	{
		super('${Dolly.c} Forward Facing');
		offset = options.offset;
		threshold = options.threshold == null || options.offset > options.threshold ? offset : options.threshold;
	}

	override function on_add()
	{
		dolly = cast entity;
		last_x = dolly.get_target().x;
		#if CAM_DEBUG
		dolly.drawLine(FlxG.width/2 - offset, 0, FlxG.width/2 - offset, FlxG.height, { thickness: 1, color: 0xFFFF004D });
		dolly.drawLine(FlxG.width/2 + offset, 0, FlxG.width/2 + offset, FlxG.height, { thickness: 1, color: 0xFFFF004D });
		dolly.draw_dashed_line(FlxPoint.get(FlxG.width/2 - threshold, 0), FlxPoint.get(FlxG.width/2 - threshold, FlxG.height), (FlxG.height / 8).to_int(), 0xFFFF004D);
		dolly.draw_dashed_line(FlxPoint.get(FlxG.width/2 + threshold, 0), FlxPoint.get(FlxG.width/2 + threshold, FlxG.height), (FlxG.height / 8).to_int(), 0xFFFF004D);
		#end
	}

	override function update(dt:Float)
	{
		var tx = dolly.get_target().x + dolly.get_target().width/2;
		var heading = (tx - last_x).sign_of();
		if (heading == 0) return;
		if (heading != direction) (x - tx).abs() > threshold ? direction = heading : return;
		dolly.set_position_x(tx + offset * direction);
		last_x = tx;
	}

}

/**
 * The camera won't move beyond the edges of a given tilemap
 */
class FollowTilemap extends Component
{

	public function new(options:FollowTilemapOptions)
	{
		super('${Dolly.c} Follow Tilemap');
		options.camera == null ? options.tilemap.follow(FlxG.camera) : options.tilemap.follow(options.camera);
	}

	public function reset(options:FollowTilemapOptions)
	{
		options.camera == null ? options.tilemap.follow(FlxG.camera) : options.tilemap.follow(options.camera);
	} 

}

typedef DollyOptions = 
{
	target:FlxObject,
	?camera:FlxCamera,
	?lerp:{ x:Float, y:Float },
	?max_velocity:{ x:Float, y:Float },
}

typedef WindowConstraintOptions =
{
	width:Float,
	height:Float,
	?axes:EAxes,
}

typedef PlatformSnapOptions = 
{
	?offset:Float,
}

typedef AreaOverrideOptions = 
{
	rects:Array<FlxRect>,
}

typedef ForwardFocusOptions = {
	offset:Float,
	?threshold:Float,
}

typedef FollowTilemapOptions = 
{
	tilemap:FlxTilemap,
	?camera:FlxCamera,
}

enum EAxes
{
	HORIZONTAL;
	VERTICAL;
	BOTH;
}