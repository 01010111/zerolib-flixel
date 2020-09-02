package zero.flixel.utilities;

import flixel.tweens.FlxTween;
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
		set_position(m.x, m.y);
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

typedef DollyOptions = 
{
	target:FlxObject,
	?camera:FlxCamera,
	?lerp:{ x:Float, y:Float },
	?max_velocity:{ x:Float, y:Float },
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

typedef WindowConstraintOptions =
{
	width:Float,
	height:Float,
	?axes:EAxes,
}

/**
 * Will move the dolly to meet a target's vertical position when a target is touching the ground
 */
class PlatformSnap extends Component
{

	var dolly:Dolly;
	var offset:Float;
	var max_speed:Float;
	var lerp:Float;

	public function set_offset(value:Float) offset = value;

	public function new(options:PlatformSnapOptions)
	{
		super('${Dolly.c} Platform Snap');
		offset = options.offset == null ? 0 : options.offset;
		max_speed = options.max_speed == null ? 9e9 : options.max_speed;
		lerp = options.lerp == null ? 0.1 : options.lerp;
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
		if (dolly.get_target().wasTouching & FlxObject.FLOOR > 0 && dolly.get_target().velocity.y >= 0) {
			var target = dolly.get_target().y + dolly.get_target().height - offset;
			var current = dolly.get_position().y;
			var next = current + ((target - current) * lerp).min(max_speed * dt).max(-max_speed * dt);
			dolly.set_position_y(next);
		}
	}

}

typedef PlatformSnapOptions = 
{
	?offset:Float,
	?max_speed:Float,
	?lerp:Float,
}

/**
 * When a target overlaps one of the given rectangles, the dolly will center on the overlapped rectangle
 */
class AreaOverride extends Component
{

	var rects:Array<AreaRect>;
	var dolly:Dolly;

	public function add_rect(rect:AreaRect)
	{
		rects.push(rect);
		rects.sort((r1, r2) -> r1.priority > r2.priority ? 1 : -1);
	}

	public function remove_rect(rect:AreaRect) rects.remove(rect);

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
			s.makeGraphic(rect.width.to_int(), rect.height.to_int(), 0x00FFFFFF, true);
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

	function override_target(rect:AreaRect)
	{
		dolly.set_position(rect.x + rect.width/2, rect.y + rect.height/2);
	}

}

class AreaRect extends FlxRect
{
	public var priority:Int = 0;
}

typedef AreaOverrideOptions = 
{
	rects:Array<AreaRect>,
}

class BoundsOverride extends Component {

	var rects:Array<AreaRect>;
	var dolly:Dolly;
	var active_rect:FlxRect;
	var cam_bounds_ref:FlxRect;
	var cam_bounds:FlxRect = FlxRect.get();
	var target_rect:FlxRect;
	var cam:FlxCamera;
	var in_lerp:Float;
	var out_lerp:Float;
	var max_delta:Float;

	public function add_rect(rect:AreaRect)
	{
		rects.push(rect);
		rects.sort((r1, r2) -> r1.priority > r2.priority ? 1 : -1);
	}

	public function remove_rect(rect:AreaRect) {
		if (rect == active_rect) on_exit();
		rects.remove(rect);
	}

	public function new(options:BoundsOverrideOptions)
	{
		super('${Dolly.c} Bounds Override');
		reset(options);
	}
	
	public function reset(options:BoundsOverrideOptions)
	{
		cam_bounds_ref = options.bounds;
		cam = options.camera == null ? FlxG.camera : options.camera;
		cam.setScrollBoundsRect(options.bounds.x, options.bounds.y, options.bounds.width, options.bounds.height);
		rects = options.rects;
		in_lerp = options.in_lerp == null ? 0.05 : options.in_lerp;
		out_lerp = options.out_lerp == null ? 0.02 : options.out_lerp;
		max_delta = options.max_delta == null ? 9e9 : options.max_delta;
		cam_bounds = FlxRect.get();
		cam_bounds_ref.copyTo(cam_bounds);
		set_bounds(cam_bounds_ref);
	}

	override function on_add()
	{
		dolly = cast entity;
		#if CAM_DEBUG
		for (rect in rects)
		{
			var s = new FlxSprite(rect.x, rect.y);
			s.makeGraphic(rect.width.to_int(), rect.height.to_int(), 0x00FFFFFF, true);
			s.draw_dashed_rect(FlxRect.get(0.5, 0.5, rect.width - 1, rect.height - 1), 8, 0xFF00A0FF);
			FlxG.state.add(s);
		}
		#end
	}

	override function update(dt:Float)
	{
		var t = dolly.get_target();
		if (active_rect == null) for (rect in rects) check_rect(t, rect);
		else if (!in_rect(t, active_rect)) on_exit();
		var lerp = active_rect == null ? out_lerp : in_lerp;
		cam_bounds.x += ((target_rect.x - cam_bounds.x) * lerp).max(-max_delta).min(max_delta);
		cam_bounds.y += ((target_rect.y - cam_bounds.y) * lerp).max(-max_delta).min(max_delta);
		cam_bounds.width += ((target_rect.width - cam_bounds.width) * lerp).max(-max_delta).min(max_delta);
		cam_bounds.height += ((target_rect.height - cam_bounds.height) * lerp).max(-max_delta).min(max_delta);
		cam.setScrollBoundsRect(cam_bounds.x, cam_bounds.y, cam_bounds.width, cam_bounds.height);
	}

	function check_rect(t:FlxObject, r:FlxRect) {
		if (in_rect(t, r)) on_enter(r);
	}

	function in_rect(t:FlxObject, r:FlxRect) {
		if (r == null) return false;
		return t.x > r.left && t.x + t.width < r.right && t.y > r.top && t.y + t.height < r.bottom;
	}

	function on_enter(rect:FlxRect)
	{
		active_rect = rect;
		set_bounds(rect);
		var combined_rect = FlxRect.get();
		combined_rect.x = Math.min(cam.scroll.x, rect.x);
		combined_rect.y = Math.min(cam.scroll.y, rect.y);
		combined_rect.right = Math.max(cam.scroll.x + cam.width, rect.right);
		combined_rect.bottom = Math.max(cam.scroll.y + cam.height, rect.bottom);
		cam_bounds.copyFrom(combined_rect);
		combined_rect.put();
	}

	function on_exit() {
		active_rect = null;
		set_bounds(cam_bounds_ref);
	}
	
	function set_bounds(rect:FlxRect) {
		target_rect = rect;
	}

}

typedef BoundsOverrideOptions = {
	> AreaOverrideOptions,
	bounds:FlxRect,
	?in_lerp:Float,
	?out_lerp:Float,
	?max_delta:Float,
	?camera:FlxCamera,
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

typedef ForwardFocusOptions = {
	offset:Float,
	?threshold:Float,
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