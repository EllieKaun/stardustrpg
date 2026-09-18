draw_sprite_stretched(
    shadow,
    0,
    bbox_left - 1,
    bbox_bottom - 1, 
    bbox_right - bbox_left + 2,
    3
)

draw_self()

if (carriesSpear) {
    var spr = spearSprite()
    if (spr != noone) {
        draw_sprite_ext(spr, 0, (bbox_left + bbox_right) * 0.5, bbox_top - 2, 1, 1, 90, c_white, 1)
    }
}