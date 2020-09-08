package zero.flixel.extensions;

import flixel.tile.FlxTilemap;
import flixel.math.FlxPoint;

using Math;
using zero.flixel.extensions.FlxTilemapExt;

class FlxTilemapExt
{

	/**
	 * Returns the tile index at a given point
	 */
	public static inline function get_index_from_point(t:FlxTilemap, p:FlxPoint):Int return t.getTile((p.x / t.get_tile_width()).floor(), (p.y / t.get_tile_height()).floor());

	/**
	 * Returns a tile's allowCollisions value at a given point
	 */
	public static inline function get_collisions_from_point(t:FlxTilemap, p:FlxPoint):Int return t.getTileCollisions(t.get_index_from_point(p));

	/**
	 * Returns the tile width of a tilemap
	 */
	public static inline function get_tile_width(t:FlxTilemap):Float return t.width / t.widthInTiles;

	/**
	 * Returns the tile height of a tilemap
	 */
	public static inline function get_tile_height(t:FlxTilemap):Float return t.height / t.heightInTiles;

	/**
	 * Returns a 2D array of tile indexes
	**/
	public static inline function get_2D_array(t:FlxTilemap):Array<Array<Int>> return [for (j in 0...t.heightInTiles) [ for (i in 0...t.widthInTiles) t.getTileByIndex(i + j * t.widthInTiles)]];

}