package zero.flixel.utilities;

import flixel.addons.tile.FlxTileSpecial;
import flixel.system.FlxAssets;

class Tilemap extends flixel.addons.tile.FlxTilemapExt {

	var map:Array<Array<Int>>;

	public function new() {
		super();
	}

	public function load_data(options:TilemapOptions) {
		map = options.data;
		loadMapFrom2DArray(options.data, options.tiles, options.tile_width, options.tile_height);
		if (options.flags != null) set_rotations(options.flags);
	}

	function set_rotations(flags:Array<Array<Int>>) {
		var special = [];
		for (j in 0...flags.length) for (i in 0...flags[j].length) {
			var flag = flags[j][i];
			if (flag == 0) {
				special.push(null);
				continue;
			}
			var flip_x = false;
			var flip_y = false;
			if (flag & 4 > 0) flip_x = !flip_x;
			if (flag & 2 > 0) flip_y = !flip_y;
			if (flag & 1 > 0) flip_x = !flip_x;
			special.push(new FlxTileSpecial(map[j][i], flip_x, flip_y, flag & 1));
		}
		setSpecialTiles(special);
	}

}

typedef TilemapOptions = {
	data:Array<Array<Int>>,
	tiles:FlxTilemapGraphicAsset,
	tile_width:Int,
	tile_height:Int,
	?flags:Array<Array<Int>>,
}