package zero.flixel.utilities;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

using zero.utilities.OgmoUtils;
using openfl.Assets;
using zero.flixel.utilities.FlxOgmoUtils;

class FlxOgmoUtils
{

	public static function get_ogmo_package(project_path:String, level_path:String):OgmoPackage
	{
		return {
			project: project_path.getText().parse_project_json(),
			level: level_path.getText().parse_level_json()
		}
	}

	public static function get_tileset_path(data:ProjectTilesetData, path:String):String
	{
		return path + data.path.split('/').pop();
	}

	public static function load_tilemap(tilemap:FlxTilemap, data:OgmoPackage, path:String)
	{
		if (path.charAt(path.length - 1) != '/') path += '/';
		var layer = data.level.get_tile_layer('tiles');
		var tileset = data.project.get_tileset_data(layer.tileset);
		switch layer.get_export_mode() {
			case CSV: tilemap.loadMapFromCSV(layer.dataCSV, tileset.get_tileset_path(path), tileset.tileWidth, tileset.tileHeight);
			case ARRAY: tilemap.loadMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, tileset.get_tileset_path(path), tileset.tileWidth, tileset.tileHeight);
			case ARRAY2D: tilemap.loadMapFrom2DArray(layer.data2D, tileset.get_tileset_path(path), tileset.tileWidth, tileset.tileHeight);
		}
		return tilemap;
	}

	static function get_export_mode(layer:TileLayer):ETileExportMode
	{
		if (layer.exportMode == 1) return CSV;
		else if (layer.arrayMode == 0) return ARRAY;
		else return ARRAY2D;
	}

	public static function get_decals_path(data:DecalData, path:String):String
	{
		return path + data.texture;
	}

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

}

typedef OgmoPackage = {
	project:ProjectData,
	level:LevelData
}

enum ETileExportMode
{
	CSV;
	ARRAY;
	ARRAY2D;
}