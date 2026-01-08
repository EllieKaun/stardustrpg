draw_self()
if isActive {
    draw_sprite(selectionArrow, 
    0,
    bbox_left - sprite_get_width(selectionArrow) / 2, 
    bbox_top - sprite_get_height(selectionArrow) / 2)
}
if isTarget {
    draw_sprite(sPointer, 
    0,
    bbox_left, 
    y)
}

drawHealthBar(bbox_left, bbox_top - 4, bbox_right - bbox_left, 4, hp, maxHp)