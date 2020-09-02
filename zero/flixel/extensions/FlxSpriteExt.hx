package zero.flixel.extensions;

import flixel.math.FlxRect;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

using openfl.Assets;
using haxe.Json;
using zero.extensions.FloatExt;
using zero.extensions.StringExt;
using flixel.util.FlxSpriteUtil;
using zero.flixel.extensions.FlxPointExt;
using zero.flixel.extensions.FlxSpriteExt;

/**
 *  A collection of extension methods for flixel.FlxSprite
 */
class FlxSpriteExt
{

	/**
	 *  Creates a hitbox and centers it on a FlxSprite's frame
	 */
	public static inline function make_and_center_hitbox(sprite:FlxSprite, width:Float, height:Float):Void
	{
		sprite.offset.set(sprite.width * 0.5 - width * 0.5, sprite.height * 0.5 - height * 0.5);
		sprite.setSize(width, height);
	}

	/**
	 *  Creates a hitbox and aligns it to the bottom center point of a FlxSprite's frame
	 */
	public static inline function make_anchored_hitbox(sprite:FlxSprite, width:Float, height:Float):Void
	{
		sprite.offset.set(sprite.width * 0.5 - width * 0.5, sprite.height - height);
		sprite.setSize(width, height);
	}

	/**
	 * Set a sprite's hitbox from a rectangle relative to the sprite's frame
	 */
	public static inline function make_rect_hitbox(sprite:FlxSprite, x:Float, y:Float, width:Float, height:Float) {
		sprite.offset.set(x, y);
		sprite.setSize(width, height);
	}

	/**
	 *  Sets both right and left facing flip
	 */
	public static inline function set_facing_flip_horizontal(sprite:FlxSprite, graphic_facing_right:Bool = true):Void
	{
		sprite.setFacingFlip(FlxObject.LEFT, graphic_facing_right, false);
		sprite.setFacingFlip(FlxObject.RIGHT, !graphic_facing_right, false);
	}

	/**
	 *  Returns a bottom center point of a FlxSprite
	 */
	public static inline function get_anchor(sprite:FlxSprite):FlxPoint return FlxPoint.get(sprite.x + sprite.width * 0.5, sprite.y + sprite.height);

	/**
	 *  Sets the position of a FlxSprite using a FlxPoint
	 */
	public static inline function set_position(sprite:FlxSprite, point:FlxPoint) sprite.setPosition(point.x, point.y);

	/**
	 *  Sets the anchor (bottom center) position of a FlxSprite using a FlxPoint
	 */
	public static inline function set_anchor_position(sprite:FlxSprite, point:FlxPoint) sprite.setPosition(point.x - sprite.width * 0.5, point.y - sprite.height);

	/**
	 *  Sets the midpoint position of a FlxSprite using a FlxPoint
	 */
	public static inline function set_midpoint_position(sprite:FlxSprite, point:FlxPoint) sprite.setPosition(point.x - sprite.width * 0.5, point.y - sprite.height * 0.5);

	/**
	 *  Add animations from JSON file
	 */
	public static inline function add_animations_from_json(sprite:FlxSprite, json:String)
	{
		var anim_data:Array<SpriteAnimation> = json.getText().parse_json();
		for (animation in anim_data) add_animation(sprite, animation);
	}

	static inline function add_animation(sprite:FlxSprite, animation:SpriteAnimation) sprite.animation.add(animation.name, animation.frames, animation.speed.to_int(), animation.loop == null ? true : animation.loop);

	public static inline function draw_dashed_line(sprite:FlxSprite, p1:FlxPoint, p2:FlxPoint, segments:Int, color:Int = 0xFFFFFFFF, thickness:Int = 1)
	{
		segments = segments * 2 + 1;
		var len = p1.distance(p2);
		for (s in 0...segments)
		{
			if (s % 2 != 0) continue;
			var tp1 = p1.get_point_between(p2, s / segments);
			var tp2 = p1.get_point_between(p2, (s + 1) / segments);
			FlxSpriteUtil.drawLine(sprite, tp1.x, tp1.y, tp2.x, tp2.y, { thickness: thickness, color: color }); 
		}
	}

	public static inline function draw_dashed_rect(sprite:FlxSprite, rect:FlxRect, segment_length:Int, color:Int = 0xFFFFFFFF, thickness:Int = 1)
	{
		sprite.draw_dashed_line(FlxPoint.get(rect.x, rect.y), FlxPoint.get(rect.x + rect.width, rect.y), (rect.width/segment_length).to_int(), color, thickness);
		sprite.draw_dashed_line(FlxPoint.get(rect.x, rect.y + rect.height), FlxPoint.get(rect.x + rect.width, rect.y + rect.height), (rect.width/segment_length).to_int(), color, thickness);
		sprite.draw_dashed_line(FlxPoint.get(rect.x, rect.y), FlxPoint.get(rect.x, rect.y + rect.height), (rect.height/segment_length).to_int(), color, thickness);
		sprite.draw_dashed_line(FlxPoint.get(rect.x + rect.width, rect.y), FlxPoint.get(rect.x + rect.width, rect.y + rect.height), (rect.height/segment_length).to_int(), color, thickness);
	}

	public static inline function facing_to_degrees(object:FlxSprite):Float
	{
		return switch (object.facing)
		{
			case FlxObject.UP: 270;
			case FlxObject.DOWN: 90;
			case FlxObject.LEFT: 180;
			case FlxObject.RIGHT: 0;
			default: 0;
		}
	}

	public static inline function is_facing_object(subject:FlxSprite, object:FlxObject):Bool return subject.getMidpoint().x > object.getMidpoint().x && subject.facing == FlxObject.LEFT || subject.getMidpoint().x < object.getMidpoint().x && subject.facing == FlxObject.RIGHT;

}

typedef SpriteAnimation = {
	name:String,
	frames: Array<Int>,
	speed: Int,
	?loop: Bool
}