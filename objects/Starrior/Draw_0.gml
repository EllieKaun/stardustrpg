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
if !isKO() {
    if maxMana <= 0 {
        drawHealthBar(bbox_left, bbox_top - 4, bbox_right - bbox_left, 4, hp, maxHp)
    } else {
        drawHealthBarMana(bbox_left, bbox_top - 6, bbox_right - bbox_left, 6, hp, maxHp, mana, maxMana)
    }
}
for(var i = 0; i < array_length(effects); i++) {
    draw_sprite(stunned, 0, bbox_right, bbox_top)
}

for (var i = 0; i < array_length(effectNotifications); i++) {

    var notif = effectNotifications[i];
    var spr = notif.sprite;

    if (sprite_exists(spr)) {
        draw_sprite(
            spr,
            notif.currentFrame,
            x,
            y
        );
    }
}