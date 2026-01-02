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
    var fonts = [fnM3x6_14, 
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


