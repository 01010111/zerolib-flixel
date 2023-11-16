package zero.flixel.utilities;

import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import zero.utilities.GOAP.IAgent;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;

using openfl.Assets;
using zero.utilities.OgmoUtils;
using zero.flixel.utilities.FlxOgmoUtils;
using zero.extensions.Tools;

/**
 * A group of Utility functions for working with OGMO files (level .json and project .ogmo files) in haxeflixel
 */
class FlxOgmoUtils
{

	/**
	 * Returns a handy object containing OgmoProjectData and OgmoLevelData
	 * @param project_path
	 * @param level_path
	 * @return OgmoPackage
	 */
	public static function get_ogmo_package(project_path:String, level_path:String):OgmoPackage
	{
		return {
			project: project_path.getText().parse_project_json(),
			level: level_path.getText().parse_level_json()
		}
	}

	/**
	 * Goes through every layer in an OGMO level and loads everything in order.
	 * @param data
	 * @param options
	 */
	public static function load_level(data:OgmoPackage, options:FlxOgmoLevelOptions)
	{
		var layers = data.project.layers.copy();
		layers.reverse();
		for (layer in layers) switch (layer.definition) {
			case 'entity': if (options.entity_loader != null) data.level.get_entity_layer(layer.name).load_entities(options.entity_loader);
			case 'decal': if (options.decals_path != null) FlxG.state.add(data.level.get_decal_layer(layer.name).get_decal_group(options.decals_path, data.project.anglesRadians));
			case 'tile': if (options.tileset_path != null) FlxG.state.add(new FlxTilemapExt().load_tilemap(data, options.tileset_path, layer.name));
			case 'grid': if (options.grid_loader != null) options.grid_loader(data.level.get_grid_layer(layer.name));
		}
	}

	/**
	 * Loads a tilemap
	 * @param tilemap the tilemap to load into
	 * @param data an OgmoPackage containing the project and level data
	 * @param tileset_path The path to the directory containing your tileset images
	 * @param tile_layer The name of your tile layer
	 */
	public static function load_tilemap(tilemap:FlxTilemapExt, data:OgmoPackage, tileset_path:String, tile_layer:String = 'tiles')
	{
		if (tileset_path.charAt(tileset_path.length - 1) != '/') tileset_path += '/';

		var layer = data.level.get_tile_layer(tile_layer);
		var tileset = data.project.get_tileset_data(layer.tileset);

		var data:Array<Array<Int>> = [];
		switch layer.get_export_mode() {
			case CSV: for (row in layer.dataCSV.split('\n')) data.push(row.split('').strings_to_ints());
			case ARRAY: data = layer.data.expand(layer.gridCellsX);
			case ARRAY2D: data = layer.data2D;
		}

		tilemap.loadMapFrom2DArray(data, tileset.get_tileset_path(tileset_path), tileset.tileWidth, tileset.tileHeight);

		if (layer.tileFlags2D != null) {
			var special = [];
			for (j in 0...layer.tileFlags2D.length) for (i in 0...layer.tileFlags2D[j].length) {
				var flag = layer.tileFlags2D[j][i];
				if (flag == 0) {
					special.push(null);
					continue;
				}
				var flip_x = false;
				var flip_y = false;
				if (flag & 4 > 0) flip_x = !flip_x;
				if (flag & 2 > 0) flip_y = !flip_y;
				if (flag & 1 > 0) flip_x = !flip_x;
				special.push(new FlxTileSpecial(data[j][i], flip_x, flip_y, flag & 1));
			}
			tilemap.setSpecialTiles(special);
		}

		#if (flixel < "5.0.0")
		tilemap.useScaleHack = false;
		#end

		return tilemap;
	}

	/**
	 * Returns a group of decals from a DecalLayer
	 * @param layer The DecalLayer to load decals from
	 * @param path The path to the directory containing your decal images
	 * @param radians Whether or not your project exports angles in radians
	 * @return FlxGroup
	 */
	public static function get_decal_group(layer:DecalLayer, path:String, radians:Bool = true):FlxGroup
	{
		if (path.charAt(path.length - 1) != '/') path += '/';
		var g = new FlxGroup();
		var decal_loader = function(d:DecalData) {
			var s = new FlxSprite(d.x, d.y, d.get_decals_path(path));
			s.offset.set(s.width/2, s.height/2);
			if (d.scaleX != null) s.scale.x = d.scaleX;
			if (d.scaleY != null) s.scale.y = d.scaleY;
			if (d.rotation != null) s.angle = radians ? d.rotation * 180/Math.PI : d.rotation;
			g.add(s);
		}
		layer.load_decals(decal_loader);
		return g;
	}

	public static function grid_to_tilemap(layer:GridLayer, options:TileOptions) {
		var tilemap = new FlxTilemap();
		var data = [];
		if (layer.grid2D != null) for (row in layer.grid2D) data.push(row.strings_to_ints());
		if (layer.grid != null) for (row in layer.grid.expand(layer.gridCellsX)) data.push(row.strings_to_ints());
		tilemap.loadMapFrom2DArray(data, options.graphic, options.tile_width, options.tile_height, options.auto_tile, options.starting_index, options.draw_index, options.collision_index);
		if (options.collision_map != null) for (id => col in options.collision_map) tilemap.setTileProperties(id, col);
		#if (flixel < "5.0.0")
		tilemap.useScaleHack = false;
		#end
		return tilemap;
	}

	static function get_tileset_path(data:ProjectTilesetData, path:String):String
	{
		return path + data.path.split('/').pop();
	}

	static function get_export_mode(layer:TileLayer):ETileExportMode
	{
		if (layer.exportMode == 1) return CSV;
		else if (layer.arrayMode == 0) return ARRAY;
		else return ARRAY2D;
	}

	static function get_decals_path(data:DecalData, path:String):String
	{
		return path + data.texture;
	}

}

typedef OgmoPackage = {
	project:ProjectData,
	level:LevelData
}

typedef TileOptions = {
	graphic:FlxTilemapGraphicAsset,
	?tile_width:Int,
	?tile_height:Int,
	?auto_tile:FlxTilemapAutoTiling,
	?starting_index:Int,
	?draw_index:Int,
	?collision_index:Int,
	?collision_map:Map<Int, Int>,
}

typedef FlxOgmoLevelOptions = {
	?tileset_path:String,
	?decals_path:String,
	?entity_loader:EntityData -> Void,
	?grid_loader:GridLayer -> Void,
}

enum ETileExportMode
{
	CSV;
	ARRAY;
	ARRAY2D;
}