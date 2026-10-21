draw_sprite_stretched(
    shadow,
    0,
    bbox_left - 1,
    bbox_bottom - 1, 
    bbox_right - bbox_left + 2,
    3
)

draw_self()

if (carriedItem != noone) {
    var carryDef = carryItemDef(carriedItem)
    var carrySpr = carryDef.worldSprite()
    if (carrySpr != noone) {
        draw_sprite_ext(carrySpr, 0, (bbox_left + bbox_right) * 0.5, bbox_top - 2, 1, 1, carryDef.worldAngle, c_white, 1)
    }
}