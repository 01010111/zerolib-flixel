package zero.flixel.extensions;

import flixel.math.FlxPoint;
import zero.utilities.IntPoint;
import zero.utilities.Vec2;

using Math;
using zero.extensions.FloatExt;
using zero.flixel.extensions.FlxPointExt;

/**
 *  A collection of extension methods for flixel.math.FlxPoint
 */
class FlxPointExt
{

	/**
	 *  returns the length of the input vector. ex. ship.velocity.vector_length() = speed of ship
	 *  @param p	input vector
	 *  @return		Float
	 */
	public static inline function vector_length(v:FlxPoint):Float return Math.sqrt(Math.pow(v.x, 2) + Math.pow(v.y, 2));

	/**
	 *  returns the distance between two points. ex. ship.getMidpoint().distance(target.getMidpoint()) = distance to target
	 *  @param p0	first point
	 *  @param p1	second point
	 *  @return Float
	 */
	public static inline function distance(p0:FlxPoint, p1:FlxPoint):Float return Math.sqrt(Math.pow(p1.x - p0.x, 2) + Math.pow(p1.y - p0.y, 2));

	/**
	 *  returns the angle of the input vector. ex. ship.velocity.vector_angle() = ship heading in degrees
	 *  @param v	input vector
	 *  @return		Float
	 */
	public static inline function vector_angle(v:FlxPoint):Float return Math.atan2(v.y, v.x).rad_to_deg().get_relative_degree();

	/**
	 *  returns the angle between two points. ex. ship.getMidpoint().get_angle_between(space_station.getMidpoint()) = heading to space_station
	 *  @param p0	first point
	 *  @param p1	second point
	 *  @return		Float
	 */
	public static inline function get_angle_between(p0:FlxPoint, p1:FlxPoint):Float return Math.atan2(p1.y - p0.y, p1.x - p0.x).rad_to_deg();

	/**
	 *  returns a point on the circumference of a circle. ex. planet.position.copyFrom(sun.getMidpoint().place_on_circumference(120, dist_from_sun)) = position of planet
	 *  @param c	center point
	 *  @param a	angle from center
	 *  @param r	radius/distance from center
	 *  @return		FlxPoint
	 */
	public static inline function place_on_circumference(c:FlxPoint, a:Float, r:Float):FlxPoint return FlxPoint.get(c.x + r * Math.cos(a.deg_to_rad()), c.y + r * Math.sin(a.deg_to_rad()));

	/**
	 *  returns a point between two points. ex: point1.get_point_between(point2, 0.75) = a point 75% between point1 and point2
	 *  @param p0	first point
	 *  @param p1	second point
	 *  @param n	the norm between the two points (0.5 = half-way)
	 *  @return		FlxPoint
	 */
	public static inline function get_point_between(p0:FlxPoint, p1:FlxPoint, n:Float = 0.5):FlxPoint return FlxPoint.get(p0.x + (p1.x - p0.x) * n, p0.y + (p1.y - p0.y) * n);

	/**
	 *  returns a point at the bottom-center of a tile of a given width and height. ex. pos.place_on_tile_anchor(16) = a point offset from pos by x: 8, and y: 16
	 *  @param p			input point
	 *  @param tile_width	the width of the tile
	 *  @param tile_height	the height of the tile
	 *  @return				FlxPoint
	 */
	public static inline function place_on_tile_anchor(p:FlxPoint, tile_width:Float, ?tile_height:Float):FlxPoint return FlxPoint.get(p.x + tile_width * 0.5, p.y + (tile_height == null ? tile_width : tile_height));

	/**
	 *  returns a point at the bottom-center of a tile of a given width and height. ex. pos.place_on_tile_anchor(16) = a point offset from pos by x: 8, and y: 8
	 *  @param p			input point
	 *  @param tile_width	the width of the tile
	 *  @param tile_height	the height of the tile
	 *  @return				FlxPoint
	 */
	public static inline function place_on_tile_midpoint(p:FlxPoint, tile_width:Float, ?tile_height:Float):FlxPoint return FlxPoint.get(p.x + tile_width * 0.5, p.y + (tile_height == null ? tile_width : tile_height) * 0.5);

	/**
	 *  Returns a Vector from a FlxPoint
	 *  @param p	input point
	 *  @return		Vector
	 */
	public static inline function to_vector(p:FlxPoint, weak:Bool = false):Vec2 {
		var out = Vec2.get(p.x, p.y);
		if (weak) p.put();
		return out;
	}

	/**
	 *  returns a new IntPoint with the same coordinates, translated to Ints
	 *  @param p	input point
	 *  @return		IntPoint
	 */
	public static inline function to_int_point(p:FlxPoint):IntPoint return IntPoint.get(p.x.to_int(), p.y.to_int());

	/**
	 * Returns a FlxPoint snapped to a grid
	 * @param p			input 
	 * @param grid_size	grid size as FlxPoint
	 * @param offset	grid offpoint
	 * @param floor		whether to floor() or round() to grid
	 * @return FlxPoint
	 */
	public static inline function snap_to_grid(p:FlxPoint, grid_size:FlxPoint, ?offset:FlxPoint, ?floor:Bool = false):FlxPoint return FlxPoint.get(p.x.snap_to_grid(grid_size.x, offset == null ? 0 : offset.x, floor), p.y.snap_to_grid(grid_size.y, offset == null ? 0 : offset.y, floor));

	/**
	 * Returns a FlxPoint within limits set by min and max points
	 * @param p		input
	 * @param min	minimum limit
	 * @param max	maximum limit
	 * @return FlxPoint return FlxPoint.get(p.x.min(max.x).max(min.x), p.y.min(max.y).max(min.y))
	 */
	public static inline function limit(p:FlxPoint, min:FlxPoint, max:FlxPoint):FlxPoint return FlxPoint.get(p.x.min(max.x).max(min.x), p.y.min(max.y).max(min.y));

	/**
	 * Copy a simple object with x and y floats
	 * @param p		input
	 * @param xy	x/y object
	 */
	public static inline function copy_from_simple(p:FlxPoint, xy:{ x:Float, y:Float }) p.set(xy.x, xy.y);

	public static inline function to_flxpoint(v:Vec2, put:Bool = true):FlxPoint
	{
		var out = FlxPoint.get(v.x, v.y);
		if (put) v.put();
		return out;
	}

}