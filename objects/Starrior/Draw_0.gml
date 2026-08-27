if isActive drawSpriteOutline(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_yellow)
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

// Анимация уменьшения хп
if (!hpBarReady) {
    displayHp = hp
    displayMana = mana
    hpBarReady = true
} else {
    displayHp += (hp - displayHp) * 0.2
    if (abs(displayHp - hp) < 0.5) displayHp = hp
    displayMana += (mana - displayMana) * 0.2
    if (abs(displayMana - mana) < 0.5) displayMana = mana
}

if !isKO() {
    if maxMana <= 0 {
        drawHealthBar(bbox_left, bbox_top - 4, bbox_right - bbox_left, 4, displayHp, maxHp)
    } else {
        drawHealthBarMana(bbox_left, bbox_top - 6, bbox_right - bbox_left, 6, displayHp, maxHp, displayMana, maxMana)
    }
}


// Рисование наложенных эффектов/cтатусов 

var statusIcons = []
var seenIcons   = {}
for (var i = 0; i < array_length(effects); i++) { // ищем иконки
    var icon = statusIconFor(effects[i])
    if (icon == noone) continue;

    var key = string(icon)
    if (variable_struct_exists(seenIcons, key)) continue
    seenIcons[$ key] = true

    array_push(statusIcons, icon)
    if (array_length(statusIcons) >= 3) break
}

var n = array_length(statusIcons)
if (n > 0) {
    var iconSize = 12
    var iconGap  = 2

    var barTop = (maxMana <= 0) ? (bbox_top - 4) : (bbox_top - 6)
    var rowY = barTop - iconSize - 2

    var startX = bbox_left

    for (var i = 0; i < n; i++) {
        var ix = startX + i * (iconSize + iconGap)
        draw_sprite_stretched(statusIcons[i], 0, ix, rowY, iconSize, iconSize)
    }
}