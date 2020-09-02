package zero.flixel.shaders;

import flixel.system.FlxAssets;
import zero.flixel.utilities.GameLog;

using zero.extensions.FloatExt;

class FourColor extends FlxShader
{
    @:glFragmentSource('
        #pragma header

		uniform float uMix;
        uniform vec4 col_0;
        uniform vec4 col_1;
        uniform vec4 col_2;
        uniform vec4 col_3;
		
        void main()
        {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec4 pal = col_0;
			if ((color.r + color.g + color.b) / 3.0 > 0.75) pal = col_3;
			else if ((color.r + color.g + color.b) / 3.0 > 0.5) pal = col_2;
			else if ((color.r + color.g + color.b) / 3.0 > 0.25) pal = col_1;

            gl_FragColor = mix(color, pal, color.a);
        }'
    )

    /**
     * Creates a 4 color palette shader - useful for gameboy-like games!
     * @param palette 
     */
    public function new(palette:Array<Int>)
    {
        super();
        set_palette(palette);
    }

	/**
	 * Sets the palette using an array of four colors (Ints), colors should be ordered from dark to light
	 * @param palette 
	 */
	public function set_palette(palette:Array<Int>)
	{
		trace(palette);
		if (palette.length != 4)
		{
			GameLog.LOG('requires 4 Ints', ERROR);
			return;
		}
		set_color(BLACK, palette[0]);
		set_color(DARK_GREY, palette[1]);
		set_color(LIGHT_GREY, palette[2]);
		set_color(WHITE, palette[3]);
	}

	/**
	 * Set a specific palette index to the given color
	 * @param index 
	 * @param color 
	 */
	public function set_color(index:PaletteIndex, color:Int)
	{
		switch (index) {
			case BLACK:			col_0.value = cast color.to_color();
			case DARK_GREY:		col_1.value = cast color.to_color();
			case LIGHT_GREY:	col_2.value = cast color.to_color();
			case WHITE:			col_3.value = cast color.to_color();
		}
	}

}

enum PaletteIndex
{
	BLACK;
	DARK_GREY;
	LIGHT_GREY;
	WHITE;
}