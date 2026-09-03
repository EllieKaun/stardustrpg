if (global.gamePaused) exit

var vLeft = x - sprite_get_xoffset(sprite_index)
var vTop = y - sprite_get_yoffset(sprite_index)
var vRight = vLeft + sprite_get_width(sprite_index)
var vBottom = vTop + sprite_get_height(sprite_index)

depth = -vBottom 

var p = instance_nearest(x, y, oHero)

if (p != noone) {
    var trunk_top = vBottom - trunk_height

    var player_behind = point_in_rectangle(p.x, p.bbox_bottom, vLeft, vTop, vRight, trunk_top)

    image_alpha = lerp(image_alpha, player_behind ? fade_alpha : 1, fade_speed)
} else {
    image_alpha = lerp(image_alpha, 1, fade_speed)
}
