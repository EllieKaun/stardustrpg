draw_self()
if isActive {
    draw_sprite(selectionArrow, 
    0,
    bbox_left - sprite_get_width(selectionArrow) / 2, 
    bbox_top - sprite_get_height(selectionArrow) / 2)
}