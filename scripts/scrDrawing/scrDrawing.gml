function drawBorderAroundCard(
    cardCurrentX,
    drawY,
    selectedBorderWidth, 
    cardWidth, 
    cardHeight
){
    draw_line_width_colour(
        cardCurrentX - 1, 
        drawY - selectedBorderWidth, 
        cardCurrentX - 1 + cardWidth, 
        drawY - selectedBorderWidth, 
        selectedBorderWidth, 
        c_yellow, 
        c_yellow
    )
     draw_line_width_colour(
        cardCurrentX - selectedBorderWidth, 
        drawY - 1, 
        cardCurrentX - selectedBorderWidth , 
        drawY + cardHeight - 1, 
        selectedBorderWidth, 
        c_yellow, 
        c_yellow
    )
     draw_line_width_colour(
        cardCurrentX + cardWidth - 1, 
        drawY - 1, 
        cardCurrentX + cardWidth - 1, 
        drawY + cardHeight - 1, 
        selectedBorderWidth , 
        c_yellow, 
        c_yellow
    )
    draw_line_width_colour(
        cardCurrentX - 1, 
        drawY + cardHeight - 1, 
        cardCurrentX + cardWidth - 1, 
        drawY + cardHeight -1  , 
        selectedBorderWidth, 
        c_yellow, 
        c_yellow
    )
}

function drawFitTextInArea(
    text,
    areaX,
    areaY,
    areaWidth,
    areaHeight
) {
    var fonts = [fnM3x6_22,
        fnM3x6_14, 
        fnM3x6_13, 
        fnM3x6_12, 
        fnM3x6_11, 
        fnM3x6_10, 
        fnM3x6_9,
        fnM3x6_8,
        fnM3x6_7]

    for (var i = 0; i < array_length(fonts); i++) {
        draw_set_font(fonts[i])

        if (string_width_ext(text, -1, areaWidth) <= areaWidth &&
            string_height_ext(text, -1, areaHeight) <= areaHeight) {
            draw_text(areaX, areaY, text)
            break
        }
    }
}

function drawHealthBar(xx, yy, width, height, hp, maxHp) {
    var percent = clamp(hp / maxHp, 0, 1)
    var borderThickness = 1
    draw_sprite_stretched(healthbar, 0, xx, yy, width, height)

    var col;

    if (percent >= 0.5) {
        var total = (percent - 0.5) / 0.5
        col = merge_colour(c_yellow, c_lime, total)
    } else {
        var t = percent / 0.5
        col = merge_colour(c_red, c_yellow, t)
    }
    draw_set_color(col)
    
    var inner_x1 = xx + borderThickness
    var inner_y1 = yy + borderThickness
    
    var inner_x2 = inner_x1 + (width - borderThickness * 2 - 1 ) * percent
    var inner_y2 = yy + height - borderThickness * 2
    
    draw_rectangle(inner_x1, inner_y1, inner_x2, inner_y2, false)
}
