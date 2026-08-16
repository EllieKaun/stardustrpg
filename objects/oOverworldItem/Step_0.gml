if (global.gamePaused) exit 

depth = -bbox_bottom 

var p = instance_nearest(x, y, oHero)

if (p != noone) {
    var trunk_top = bbox_bottom - trunk_height

    // Игрок позади
    var player_behind = point_in_rectangle(p.x, p.bbox_bottom, bbox_left, bbox_top, bbox_right, trunk_top)

    image_alpha = lerp(image_alpha, player_behind ? fade_alpha : 1, fade_speed)
} else {
    image_alpha = lerp(image_alpha, 1, fade_speed)
}
