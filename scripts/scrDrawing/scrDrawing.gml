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

//// Battle high-res GUI helpers
// The battle draws its UI in the "logical" base resolution (global.guiBaseW/H)
// and scales it up into a higher-resolution GUI buffer with a world matrix.
// These return that base size, falling back to the raw GUI size outside battle.
function guiBaseWidth()  { return variable_global_exists("guiBaseW") ? global.guiBaseW : display_get_gui_width()  }
function guiBaseHeight() { return variable_global_exists("guiBaseH") ? global.guiBaseH : display_get_gui_height() }

// Ставит GUI-слой в 16:9 аспекте
function setCrispGui(baseW, baseH) {
    var scale = max(1, min(window_get_width() / baseW, window_get_height() / baseH))
    var gw = round(baseW * scale)
    var gh = round(baseH * scale)
    if (display_get_gui_width() != gw || display_get_gui_height() != gh) {
        display_set_gui_size(gw, gh)
    }
}

// Попадание точки в повёрнутый прямоугольник (центр cx,cy; размер w,h;
// угол angle — та же конвенция, что у draw_sprite_ext). Для хит-теста карт
function pointInRotatedRect(px, py, cx, cy, w, h, angle) {
    var c = dcos(angle), s = dsin(angle)
    var dx = px - cx, dy = py - cy
    var lx = c * dx - s * dy    // точка в локальных координатах карты
    var ly = s * dx + c * dy
    return (abs(lx) <= w * 0.5 && abs(ly) <= h * 0.5)
}

// Turn an internal card id ("PhysicalDamageSingleTargetCard") into a
// human label ("Physical Damage Single Target"). Display-only.
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

// Card's headline numbers for the compact on-card display.
// { kind:"dmg"|"heal"|"none", minNum, maxNum, effectName, costType, costValue }
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

//// Детальное описание карты
#macro CARD_DESC_X1 6
#macro CARD_DESC_Y1 35
#macro CARD_DESC_X2 31
#macro CARD_DESC_Y2 50

// Ручной перенос строк под ширину maxW текущим шрифтом
function wrapTextToWidth(text, maxW) {
    var out = ""
    var cur = ""
    var word = ""
    var n = string_length(text)
    for (var i = 1; i <= n + 1; i++) {
        var ch = (i <= n) ? string_char_at(text, i) : "\n" 
        if (ch == " " || ch == "\n") {
            if (word != "") {
                var cand = (cur == "") ? word : cur + " " + word
                if (cur != "" && string_width(cand) > maxW) {
                    out += cur + "\n"
                    cur = word
                } else {
                    cur = cand
                }
                word = ""
            }
            if (ch == "\n") {
                out += cur
                if (i <= n) out += "\n"
                cur = ""
            }
        } else {
            word += ch
        }
    }
    return out
}

// Подбор шрифта под область
function fitWrappedText(text, areaW, areaH) {
    if (!variable_global_exists("uiFontLadder")) uiFontInit()
    var ladder = global.uiFontLadder
    var prevFont = draw_get_font()
    var best = undefined
    var bestSize = -1
    for (var i = 0; i < array_length(ladder); i++) {
        draw_set_font(ladder[i].font)
        var wrapped = wrapTextToWidth(text, areaW)
        var tw = string_width(wrapped)
        var th = string_height(wrapped)
        var sc = min(areaW / max(1, tw), areaH / max(1, th))
        var effective = sc * ladder[i].lineH // итоговая высота строки на экране
       
        if (effective >= bestSize) {
            bestSize = effective
            best = { font: ladder[i].font, scale: sc, text: wrapped }
        }
    }
    draw_set_font(prevFont)
    return best
}

//// Лицо карты с текстом
#macro CARD_FACE_SCALE 8

function cardFaceLayout(card) {
    if (!variable_global_exists("cardFaceLayouts")) global.cardFaceLayouts = {}
    var key = string(card.name) + "|" + string(card.rarity)
    if (variable_struct_exists(global.cardFaceLayouts, key)) return global.cardFaceLayouts[$ key]

    var prevFont = draw_get_font()
    var refW = sprite_get_width(card.cardBaseSpr) * CARD_FACE_SCALE
    var refH = sprite_get_height(card.cardBaseSpr) * CARD_FACE_SCALE
    var areaW = (CARD_DESC_X2 - CARD_DESC_X1) * CARD_FACE_SCALE
    var areaH = (CARD_DESC_Y2 - CARD_DESC_Y1) * CARD_FACE_SCALE
    // ручное описание с карты (card.description); задаётся в фабриках карт
    var descText = variable_struct_exists(card, "description") ? card.description : ""
    var fit = fitWrappedText(descText, areaW, areaH)

    var costTxt = string(card.costValue())
    var costScale = uiTextScale(costTxt, refH * 0.16, refW * 0.24) // ставит шрифт
    var lay = {
        refW: refW, refH: refH,
        descFont: fit.font, descScale: fit.scale, descText: fit.text,
        costTxt: costTxt, costFont: draw_get_font(), costScale: costScale
    }
    draw_set_font(prevFont)
    global.cardFaceLayouts[$ key] = lay
    return lay
}

// Рисуем полностью карту (спрайты + описание + стоимость)
// центр cx,cy, целевой размер w,h, поворот angle
function drawCardFace(card, cx, cy, w, h, angle, scale = 1, alpha = 1, isSelected = false) {
    var baseW = sprite_get_width(card.cardBaseSpr)
    var baseH = sprite_get_height(card.cardBaseSpr)
    var sx = (w / baseW) * scale
    var sy = (h / baseH) * scale
    draw_sprite_ext(card.cardBaseSpr, 0, cx, cy, sx, sy, angle, c_white, alpha)
    draw_sprite_ext(card.cardIllustrationSpr, 0, cx, cy, sx, sy, angle, c_white, alpha)
    draw_sprite_ext(card.cardBorderSpr, 0, cx, cy, sx, sy, angle, c_white, alpha)
    draw_sprite_ext(card.cardTokenSpr, 0, cx, cy, sx, sy, angle, c_white, alpha)

    var lay = cardFaceLayout(card)
    var k = min(w * scale / lay.refW, h * scale / lay.refH)
    var prevFont = draw_get_font()
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)

    // описание
    if (lay.descText != "") {
        draw_set_font(lay.descFont)
        var descLx = w * scale * ((CARD_DESC_X1 + CARD_DESC_X2) * 0.5 / baseW - 0.5)
        var descLy = h * scale * ((CARD_DESC_Y1 + CARD_DESC_Y2) * 0.5 / baseH - 0.5)
        var descPt = cardLocalToScreen(cx, cy, descLx, descLy, angle)
        var descScale = lay.descScale * k
        draw_text_transformed_colour(descPt.x, descPt.y, lay.descText,
            descScale, descScale, angle, c_black, c_black, c_black, c_black, alpha)
    }

    // стоимость
    draw_set_font(lay.costFont)
    drawCardStatText(cx, cy, w * scale * 0.28, -h * scale * 0.36, angle,
        lay.costTxt, c_white, lay.costScale * k)

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
    draw_set_font(prevFont)
    
    if (isSelected) {
        draw_sprite_ext(sprCardSelected, 0, cx, cy, sx, sy, angle, c_white, 1)
    }
}

// Map a card-local point (lx right, ly down; origin = card centre) to
// screen space for a card drawn with draw_sprite_ext(angle).
function cardLocalToScreen(cx, cy, lx, ly, angle) {
    return {
        x: cx + lx * dcos(angle) + ly * dsin(angle),
        y: cy - lx * dsin(angle) + ly * dcos(angle)
    }
}

function uiFontInit() {
    var candidates = ["fnUI_7","fnUI_8", "fnUI_9", "fnUI_10", "fnUI_12", "fnUI_14", "fnUI_15", "fnUI_16", "fnUI_17", "fnUI_18", "fnUI_20", "fnUI_24", "fnUI_28", "fnUI_32", "fnUI_40", "fnUI_48", "fnUI"]
    var ladder = []
    var prev = draw_get_font()
    for (var i = 0; i < array_length(candidates); i++) {
        var f = asset_get_index(candidates[i])
        if (f >= 0 && font_exists(f)) {
            draw_set_font(f)
            array_push(ladder, { font: f, lineH: max(1, string_height("0")) })
        }
    }
    if (array_length(ladder) == 0) {
        draw_set_font(fnUI_24)
        array_push(ladder, { font: fnUI_24, lineH: max(1, string_height("0")) })
    }
    if (prev >= 0) draw_set_font(prev)
    array_sort(ladder, function(a, b) { return a.lineH - b.lineH })
    global.uiFontLadder = ladder
    global.uiFontCurrent = ladder[array_length(ladder) - 1].font
}

function uiFont() {
    if (!variable_global_exists("uiFontLadder")) uiFontInit()
    return global.uiFontCurrent
}

function uiTextScale(txt, targetH, maxW) {
    if (!variable_global_exists("uiFontLadder")) uiFontInit()
    var ladder = global.uiFontLadder
    var pick = ladder[0]
    for (var i = 0; i < array_length(ladder); i++) {
        if (ladder[i].lineH <= targetH) pick = ladder[i]
    }
    global.uiFontCurrent = pick.font
    draw_set_font(pick.font)
    var sc = targetH / pick.lineH
    var tw = string_width(txt) * sc
    if (tw > maxW) sc *= maxW / max(1, tw)
    return sc
}

function drawUiText(xx, yy, str, pxH) {
    var sc = uiTextScale(str, pxH, 1000000)
    draw_text_transformed(xx, yy, str, sc, sc, 0)
    return sc
}

// Draw short text at a card-local point with a clean one-pixel drop
// shadow, rotated to the card angle. Uses the current font & given scale.
function drawCardStatText(cx, cy, lx, ly, angle, txt, col, scale) {
    if (txt == "") return
    var off = max(1, scale)
    var main = cardLocalToScreen(cx, cy, lx, ly, angle)
    var _shadow = cardLocalToScreen(cx, cy, lx + off, ly + off, angle)
    draw_text_transformed_colour(_shadow.x, _shadow.y, txt, scale, scale, angle, c_black, c_black, c_black, c_black, 0.6)
    draw_text_transformed_colour(main.x, main.y, txt, scale, scale, angle, col, col, col, col, 1)
}

function drawFitTextInArea(
    text,
    areaX,
    areaY,
    areaWidth,
    areaHeight
) {
    var fonts = [fnUI_48, fnUI_32, fnUI_24, fnUI_16,
                 fnUI_14, fnUI_12, fnUI_10, fnUI_9, fnUI_8, fnUI_7]

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
    var spread  = 40 // px between card centers
    var arcLift = 3 // px each card dips toward the ends
    var arcTilt = 4 // degrees rotation per step from center

    var mid = (n - 1) / 2
    var off = i - mid // signed distance from the middle card

    var baseX = display_get_gui_width() / 2
    var baseY = display_get_gui_height() - 70

    var t = {
        x: baseX + off * spread,
        y: baseY + abs(off) * arcLift, // ends dip down → arc
        angle: -off * arcTilt, // fan rotation
        scale: 1
    }

    // hovered/selected card overrides: lift, straighten, enlarge
    if (i == hoveredIndex) {
        t.y -= 20
        t.angle = 0
        t.scale = 1.25
    }

    return t
}

function drawCardTransformed(card, cx, cy, w, h, angle, scale, alpha = 1) {
    drawCardFace(card, cx, cy, w, h, angle, scale, alpha)
}

function drawSpriteOutline(spr, sub, xx, yy, xs, ys, ang, col) {
    gpu_set_fog(true, col, 0, 0)
    draw_sprite_ext(spr, sub, xx - 1, yy, xs, ys, ang, c_white, 1)
    draw_sprite_ext(spr, sub, xx + 1, yy, xs, ys, ang, c_white, 1)
    draw_sprite_ext(spr, sub, xx, yy - 1, xs, ys, ang, c_white, 1)
    draw_sprite_ext(spr, sub, xx, yy + 1, xs, ys, ang, c_white, 1)
    gpu_set_fog(false, col, 0, 0)
}

// Высота бейджа
#macro MENU_BADGE_H 10

function menuBadgeSize(label, badgeScale) {
    var aspect = sprite_get_width(ActionButtnBackground) / sprite_get_height(ActionButtnBackground)
    var base = MENU_BADGE_H * badgeScale
    var bh = base
    var textH = base * 0.9
    var padX = 4 * badgeScale
    var sc = uiTextScale(label, textH, 100000)
    var bw = max(base * aspect, string_width(label) * sc + padX * 2)
    return { w: bw, h: bh, textH: textH, scale: sc }
}

function drawMenuBadge(badgeX, badgeY, badgeScale, label, hotkey, ballOnLeft, colorMain, colorPanel) {
    var size = menuBadgeSize(label, badgeScale)
    var badgeWidth = size.w
    var badgeHeight = size.h
    var scale = size.scale
    var flip = ballOnLeft ? 1 : -1
    var cx = badgeX + badgeWidth * 0.5
    var cy = badgeY + badgeHeight * 0.5
    var bgSx = badgeWidth / sprite_get_width(ActionButtnBackground)
    var bgSy = badgeHeight / sprite_get_height(ActionButtnBackground)
    var fgSx = badgeWidth / sprite_get_width(ActionButtonForeground)
    var fgSy = badgeHeight / sprite_get_height(ActionButtonForeground)
    draw_sprite_ext(ActionButtnBackground, 0, cx, cy, bgSx * flip, bgSy, 0, colorMain, 1)
    draw_sprite_ext(ActionButtonForeground, 0, cx, cy, fgSx * flip, fgSy, 0, colorPanel, 1)

    var textShift = (ballOnLeft ? 1 : -1) * 2 * badgeScale
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_set_color(colorMain)
    draw_text_transformed(badgeX + badgeWidth * 0.5 + textShift, badgeY + badgeHeight * 0.5, label, scale, scale, 0)

    var ballCenterX = ballOnLeft ? badgeX : badgeX + badgeWidth
    var ballCenterY = badgeY + badgeHeight * 0.5
    var ballScale = badgeHeight / sprite_get_height(ActionButtonCircle)
    draw_sprite_ext(ActionButtonCircle, 0, ballCenterX, ballCenterY, ballScale, ballScale, 0, colorMain, 1)

    draw_set_color(colorPanel)
    var ksc = uiTextScale(hotkey, size.textH, badgeHeight * 0.6)
    draw_text_transformed(ballCenterX, ballCenterY, hotkey, ksc, ksc, 0)

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
    return size
}



