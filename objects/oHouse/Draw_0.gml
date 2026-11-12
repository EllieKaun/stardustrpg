var houseShadow = shadowSprite
if (houseShadow == noone) {
    switch (sprite_index) {
        case sprLanaHouse: houseShadow = sprLanaHouseShadow; break
        case sprFiraHouse: houseShadow = sprFiraHouseShadow; break
    }
}
if (shadowVisible && houseShadow != noone && sprite_exists(houseShadow)) {
    var artCenterX = x - sprite_xoffset + sprite_width * 0.5
    var artBottomY = y - sprite_yoffset + sprite_height - 1
    draw_sprite(houseShadow, 0, artCenterX + shadowOffsetX, artBottomY + shadowOffsetY)
}

draw_self()
