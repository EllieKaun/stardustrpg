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

// --- Battle high-res GUI helpers ---------------------------------------------
// The battle draws its UI in the "logical" base resolution (global.guiBaseW/H)
// and scales it up into a higher-resolution GUI buffer with a world matrix.
// These return that base size, falling back to the raw GUI size outside battle.
function guiBaseWidth()  { return variable_global_exists("guiBaseW") ? global.guiBaseW : display_get_gui_width()  }
function guiBaseHeight() { return variable_global_exists("guiBaseH") ? global.guiBaseH : display_get_gui_height() }

/// @desc Попадание точки в повёрнутый прямоугольник (центр cx,cy; размер w,h;
///       угол angle — та же конвенция, что у draw_sprite_ext). Для хит-теста карт.
function pointInRotatedRect(px, py, cx, cy, w, h, angle) {
    var c = dcos(angle), s = dsin(angle)
    var dx = px - cx, dy = py - cy
    var lx = c * dx - s * dy    // точка в локальных координатах карты
    var ly = s * dx + c * dy
    return (abs(lx) <= w * 0.5 && abs(ly) <= h * 0.5)
}

/// @desc Turn an internal card id ("PhysicalDamageSingleTargetCard") into a
///       human label ("Physical Damage Single Target"). Display-only.
function prettifyCardName(nm) {
    nm = string(nm)
    var len = string_length(nm)
    if (len > 4 && string_copy(nm, len - 3, 4) == "Card") {
        nm = string_copy(nm, 1, len - 4)
        len -= 4
    }
    var out = ""
    for (var i = 1; i <= len; i++) {
        var ch = string_char_at(nm, i)
        if (i > 1) {
            var prev     = string_char_at(nm, i - 1)
            var chUpper  = (ch != string_lower(ch))      // uppercase letter
            var prevLow  = (prev != string_upper(prev))  // lowercase letter
            if (chUpper && prevLow) out += " "
        }
        out += ch
    }
    return out
}

/// @desc Card's headline numbers for the compact on-card display.
///       { kind:"dmg"|"heal"|"none", minNum, maxNum, effectName, costType, costValue }
function cardDisplayStats(card) {
    var st = {
        kind: "none", minNum: 1, maxNum: 0, effectName: "",
        costType: card.costType(), costValue: card.costValue()
    }
    var isAll = (card.target == TargetTypes.AllEnemies || card.target == TargetTypes.AllAllies)

    for (var i = 0; i < array_length(card.effects); i++) {
        var e = card.effects[i]
        if (e.type == EffectTypes.Damage || e.type == EffectTypes.Heal) {
            st.kind = (e.type == EffectTypes.Damage) ? "dmg" : "heal"
            switch (card.rarity) {
                case CardsRarity.Default: st.maxNum = isAll ? 2 : 4;  break
                case CardsRarity.Unusual: st.maxNum = isAll ? 4 : 6;  break
                case CardsRarity.Rare:    st.maxNum = isAll ? 6 : 8;  break
                case CardsRarity.Epic:    st.maxNum = isAll ? 8 : 12; break
            }
            return st
        }
    }
    // no damage/heal — surface the first other effect's short name instead
    for (var i = 0; i < array_length(card.effects); i++) {
        var e = card.effects[i]
        if (e.type != EffectTypes.Damage && e.type != EffectTypes.Heal) {
            st.effectName = effectTypeToString(e.type)
            break
        }
    }
    return st
}

/// @desc Map a card-local point (lx right, ly down; origin = card centre) to
///       screen space for a card drawn with draw_sprite_ext(angle).
function cardLocalToScreen(cx, cy, lx, ly, angle) {
    return {
        x: cx + lx * dcos(angle) + ly * dsin(angle),
        y: cy - lx * dsin(angle) + ly * dcos(angle)
    }
}

function uiFontInit() {
    var f = asset_get_index("fnUI") // -1 если ассет ещё не создан
    global.uiFontIsTTF = (f >= 0 && font_exists(f))
    global.uiFontIndex = global.uiFontIsTTF ? f : fnM3x6_22
    var prev = draw_get_font()
    draw_set_font(global.uiFontIndex)
    global.uiFontLineHeight = max(1, string_height("0"))
    if (prev >= 0) draw_set_font(prev)
}

// Единый шрифт UI
function uiFont() {
    if (!variable_global_exists("uiFontIndex")) uiFontInit()
    return global.uiFontIndex
}

// Масштаб текущего шрифта, чтобы строка была ~targetH пикселей в высоту,
// но не шире maxW. Для TTF — дробный (плавно). Для пиксельного отката —
// округляем до целого, чтобы шрифт не рвался.
function uiTextScale(txt, targetH, maxW) {
    if (!variable_global_exists("uiFontIndex")) uiFontInit()
    var sc = targetH / global.uiFontLineHeight
    var tw = string_width(txt) * sc
    if (tw > maxW) sc *= maxW / max(1, tw)
    if (!global.uiFontIsTTF) sc = max(1, floor(sc))  // пиксельный откат — целый масштаб
    return sc
}

/// @desc Рисует строку шрифтом uiFont() высотой ~pxH пикселей, сохраняя текущие
///       halign/valign/color. Возвращает применённый масштаб (нужен для ширины).
function drawUiText(xx, yy, str, pxH) {
    draw_set_font(uiFont())
    var sc = uiTextScale(str, pxH, 1000000)
    draw_text_transformed(xx, yy, str, sc, sc, 0)
    return sc
}

/// @desc Draw short text at a card-local point with a clean one-pixel drop
///       shadow, rotated to the card angle. Uses the current font & given scale.
function drawCardStatText(cx, cy, lx, ly, angle, txt, col, scale) {
    if (txt == "") return
    var p  = cardLocalToScreen(cx, cy, lx, ly, angle)
    var sh = max(1, scale)   // shadow offset
    draw_text_transformed_colour(p.x + sh, p.y + sh, txt, scale, scale, angle, c_black, c_black, c_black, c_black, 0.6)
    draw_text_transformed_colour(p.x,      p.y,      txt, scale, scale, angle, col, col, col, col, 1)
}

/// @desc Compact stats drawn over the card at full GUI resolution:
///       a big value in the name box + the cost number on the cost token.
///       x,y = card centre; w,h = drawn card size (screen px).
function drawCardStats(x, y, w, h, angle, card) {
    var st = cardDisplayStats(card)

    var colDmg  = make_color_rgb(222, 64,  52)
    var colHeal = make_color_rgb(74,  194, 96)
    var colEff  = make_color_rgb(240, 214, 120)

    // ---- main value (or effect name), big & centred in the name box ----
    var mainTxt = "", mainCol = c_white
    switch (st.kind) {
        case "dmg":  mainTxt = string(st.minNum) + "-" + string(st.maxNum); mainCol = colDmg;  break
        case "heal": mainTxt = string(st.minNum) + "-" + string(st.maxNum); mainCol = colHeal; break
        default:     mainTxt = st.effectName;                                mainCol = colEff;  break
    }

    // Смещения в долях размера карты (лёгкая подстройка центровки — крути тут):
    var valueLx =  0.00   // значение: гориз. (0 = центр карты)
    var valueLy =  0.31   // значение: вертик. (центр белого поля имени)
    var costLx  =  0.32   // стоимость: гориз. (центр сердечка-токена)
    var costLy  = -0.40   // стоимость: вертик. (центр сердечка-токена)

    draw_set_font(uiFont())
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)

    // значение (урон/лечение) — по центру поля имени
    drawCardStatText(x, y, valueLx * w, valueLy * h, angle, mainTxt, mainCol,
        uiTextScale(mainTxt, h * 0.22, w * 0.80))

    // стоимость — цифрой на сердечке-токене (верх-право)
    drawCardStatText(x, y, costLx * w, costLy * h, angle, string(st.costValue), c_white,
        uiTextScale(string(st.costValue), h * 0.16, w * 0.24))

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
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



