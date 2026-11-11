if (shadowVisible) {
    var shadowWidth = (bbox_right - bbox_left + 2) * shadowWidthScale
    var shadowCenterX = (bbox_left + bbox_right) * 0.5 + shadowOffsetX
    draw_sprite_stretched(
        shadow,
        0,
        shadowCenterX - shadowWidth * 0.5,
        bbox_bottom - shadowHeight * 0.5 + shadowOffsetY,
        shadowWidth,
        shadowHeight
    )
}

draw_self()
