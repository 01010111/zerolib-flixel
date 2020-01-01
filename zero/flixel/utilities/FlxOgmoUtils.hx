package zero.flixel.utilities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

using openfl.Assets;
using zero.utilities.OgmoUtils;
using zero.flixel.utilities.FlxOgmoUtils;

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
			case 'tile': if (options.tileset_path != null) FlxG.state.add(new FlxTilemap().load_tilemap(data, options.tileset_path, layer.name));
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
	public static function load_tilemap(tilemap:FlxTilemap, data:OgmoPackage, tileset_path:String, tile_layer:String = 'tiles')
	{
		if (tileset_path.charAt(tileset_path.length - 1) != '/') tileset_path += '/';
		var layer = data.level.get_tile_layer(tile_layer);
		var tileset = data.project.get_tileset_data(layer.tileset);
		switch layer.get_export_mode() {
			case CSV: tilemap.loadMapFromCSV(layer.dataCSV, tileset.get_tileset_path(tileset_path), tileset.tileWidth, tileset.tileHeight);
			case ARRAY: tilemap.loadMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, tileset.get_tileset_path(tileset_path), tileset.tileWidth, tileset.tileHeight);
			case ARRAY2D: tilemap.loadMapFrom2DArray(layer.data2D, tileset.get_tileset_path(tileset_path), tileset.tileWidth, tileset.tileHeight);
		}
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