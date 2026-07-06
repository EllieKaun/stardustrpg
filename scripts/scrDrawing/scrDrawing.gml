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

function drawHealthBarMana(xx, yy, width, height, hp, maxHp, mana, maxMana) {
    var percentHp = clamp(hp / maxHp, 0, 1)
    var percentMana = clamp(mana / maxMana, 0, 1)
    var borderThickness = 1
    
    draw_sprite_stretched(healthmanabar, 0, xx, yy, width, height)
    
    var col;
    if (percentHp >= 0.5) {
        var t = (percentHp - 0.5) / 0.5
        col = merge_colour(c_yellow, c_lime, t)
    } else {
        var t = percentHp / 0.5
        col = merge_colour(c_red, c_yellow, t)
    }
    draw_set_color(col)
    
    var innerX1 = xx + borderThickness
    var innerY1 = yy + borderThickness
    var innerWidth = width - borderThickness * 2
    var healthHeight = height - 2 - borderThickness * 2 
    
    var innerX2 = innerX1 + innerWidth * percentHp - 1
    var innerY2 = innerY1 + healthHeight - 1
    
    draw_rectangle(innerX1, innerY1, innerX2, innerY2, false)
    
    draw_set_color(c_blue) 
    
    var manaY = innerY2 + 2  
    var manaX2 = innerX1 + innerWidth * percentMana - 1
    
    draw_rectangle(innerX1, manaY, manaX2, manaY, false) 
}


function drawDamageNumber(xx, yy, value, color) {
    var instance = instance_create_depth(xx, yy, depth - 1, oDamageNumber)
    instance.value = value
    instance.color = color
}

// Иконка статуса теперь берётся из реестра эффектов (scrEffectSystem).
function statusIconFor(effect) {
    return effectIcon(effect)
}

/////////////////////////////////////////
// returns {x, y, angle, scale} for card i of n, centered under the screen
function handCardTransform(i, n, hoveredIndex) {
    // tunables
    var spread  = 40;   // px between card centers
    var arcLift = 3;    // px each card dips toward the ends
    var arcTilt = 4;    // degrees rotation per step from center

    var mid = (n - 1) / 2;
    var off = i - mid;              // signed distance from the middle card

    var baseX = display_get_gui_width() / 2;
    var baseY = display_get_gui_height() - 70;

    var t = {
        x:     baseX + off * spread,
        y:     baseY + abs(off) * arcLift,   // ends dip down → arc
        angle: -off * arcTilt,               // fan rotation
        scale: 1
    };

    // hovered/selected card overrides: lift, straighten, enlarge
    if (i == hoveredIndex) {
        t.y     -= 20;
        t.angle  = 0;
        t.scale  = 1.25;
    }

    return t;
}

function drawCardTransformed(card, cx, cy, w, h, angle, scale, alpha = 1) {
    // sprite scale factors: sprite native size → target w/h, then * scale
    var sx = (w / sprite_get_width(card.cardBaseSpr))  * scale;
    var sy = (h / sprite_get_height(card.cardBaseSpr)) * scale;
    draw_sprite_ext(card.cardBaseSpr,         0, cx, cy, sx, sy, angle, c_white, alpha);
    draw_sprite_ext(card.cardIllustrationSpr, 0, cx, cy, sx, sy, angle, c_white, alpha);
    draw_sprite_ext(card.cardBorderSpr,       0, cx, cy, sx, sy, angle, c_white, alpha);
    draw_sprite_ext(card.cardTokenSpr,        0, cx, cy, sx, sy, angle, c_white, alpha);
}



