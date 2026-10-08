function prettifyCardName(rawName) {
    rawName = string(rawName)
    var nameLength = string_length(rawName)
    if (nameLength > 4 && string_copy(rawName, nameLength - 3, 4) == "Card") {
        rawName = string_copy(rawName, 1, nameLength - 4)
        nameLength -= 4
    }
    var prettyName = ""
    for (var index = 1; index <= nameLength; index++) {
        var currentChar = string_char_at(rawName, index)
        if (index > 1) {
            var previousChar     = string_char_at(rawName, index - 1)
            var chUpper  = (currentChar != string_lower(currentChar)) // uppercase letter
            var prevLow  = (previousChar != string_upper(previousChar)) // lowercase letter
            if (chUpper && prevLow) { prettyName += " " }
        }
        prettyName += currentChar
    }
    return prettyName
}

// Card's headline numbers for the compact on-card display.
// { kind:"dmg"|"heal"|"none", minNum, maxNum, effectName, costType, costValue }
function cardDisplayStats(card) {
    var stats = {
        kind: "none", minNum: 1, maxNum: 0, effectName: "",
        costType: card.costType(), costValue: card.costValue()
    }
    var isAll = (card.target == TargetTypes.AllEnemies || card.target == TargetTypes.AllAllies)

    for (var index = 0; index < array_length(card.effects); index++) {
        var effect = card.effects[index]
        if (effect.type == EffectTypes.Damage || effect.type == EffectTypes.Heal) {
            stats.kind = (effect.type == EffectTypes.Damage) ? "dmg" : "heal"
            switch (card.rarity) {
                case CardsRarity.Default: stats.maxNum = isAll ? 2 : 4;  break
                case CardsRarity.Unusual: stats.maxNum = isAll ? 4 : 6;  break
                case CardsRarity.Rare: stats.maxNum = isAll ? 6 : 8;  break
                case CardsRarity.Epic: stats.maxNum = isAll ? 8 : 12; break
            }
            return stats
        }
    }
    for (var index = 0; index < array_length(card.effects); index++) {
        var effect = card.effects[index]
        if (effect.type != EffectTypes.Damage && effect.type != EffectTypes.Heal) {
            stats.effectName = effectTypeToString(effect.type)
            break
        }
    }
    return stats
}

//// Детальное описание карты
#macro CARD_DESC_X1 28
#macro CARD_DESC_Y1 138
#macro CARD_DESC_X2 124
#macro CARD_DESC_Y2 193


//// Лицо карты с текстом
#macro CARD_FACE_BUCKET_PX 6
// На сколько пикселей арта приподнять токен стоимости энергии 
#macro CARD_COST_TOKEN_RAISE_PX 0

// faceW,faceH — фактический размер границы карт
function cardFaceLayout(card, faceW, faceH) {
    locEnsure()
    if (!variable_global_exists("cardFaceLayouts")) { global.cardFaceLayouts = {} }

    var bucketH = max(CARD_FACE_BUCKET_PX, round(faceH / CARD_FACE_BUCKET_PX) * CARD_FACE_BUCKET_PX)
    var cacheKey = string(card.name) + "|" + string(card.rarity) + "|" + global.language + "|" + string(bucketH) + "|" + string(cardDurationTurns(card))
    if (variable_struct_exists(global.cardFaceLayouts, cacheKey)) { return global.cardFaceLayouts[$ cacheKey] }

    var baseW = sprite_get_width(card.cardBaseSpr)
    var baseH = sprite_get_height(card.cardBaseSpr)
    var bucketW = (faceH != 0) ? faceW * bucketH / faceH : faceW
    var areaW = (CARD_DESC_X2 - CARD_DESC_X1) / baseW * bucketW
    var areaH = (CARD_DESC_Y2 - CARD_DESC_Y1) / baseH * bucketH

    var prevFont = draw_get_font()
    // описание с карты 
    var descText = cardDisplayDesc(card)
    var fittedText = fitWrappedText(descText, areaW, areaH)

    var costTxt = string(card.costValue())
    var costScale = uiTextScale(costTxt, bucketH * 0.16, bucketW * 0.24)
    var layout = {
        descFont: fittedText.font, descScale: fittedText.scale, descText: fittedText.text,
        costTxt: costTxt, costFont: draw_get_font(), costScale: costScale
    }
    draw_set_font(prevFont)
    global.cardFaceLayouts[$ cacheKey] = layout
    return layout
}

// Рисуем полностью карту (спрайты + описание + стоимость)
// центр centerX,centerY, целевой размер cardWidth,cardHeight, поворот angle
function drawCardFace(card, centerX, centerY, cardWidth, cardHeight, angle, scale = 1, alpha = 1, isSelected = false) {
    var baseW = sprite_get_width(card.cardBaseSpr)
    var baseH = sprite_get_height(card.cardBaseSpr)
    var spriteScaleX = (cardWidth / baseW) * scale
    var spriteScaleY = (cardHeight / baseH) * scale
    draw_sprite_ext(card.cardBaseSpr, 0, centerX, centerY, spriteScaleX, spriteScaleY, angle, c_white, alpha)
    draw_sprite_ext(card.cardIllustrationSpr, 0, centerX, centerY, spriteScaleX, spriteScaleY, angle, c_white, alpha)
    draw_sprite_ext(card.cardBorderSpr, 0, centerX, centerY, spriteScaleX, spriteScaleY, angle, c_white, alpha)
    draw_sprite_ext(card.cardTokenSpr, 0, centerX, centerY, spriteScaleX, spriteScaleY, angle, c_white, alpha)
    // Токен стоимости энергии
    if (card.energy > 0) {
        var costToken = (card.energy >= 2) ? sprCostTwoEnergy : sprCostEnergy
        var tokenRaise = CARD_COST_TOKEN_RAISE_PX * spriteScaleY
        var tokenPoint = cardLocalToScreen(centerX, centerY, 0, -tokenRaise, angle)
        draw_sprite_ext(costToken, 0, tokenPoint.x, tokenPoint.y, spriteScaleX, spriteScaleY, angle, c_white, alpha)
    }
    
    // Настройка текста
    var layout = cardFaceLayout(card, cardWidth, cardHeight)
    var prevFont = draw_get_font()
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)

    // Включение сглаживания при повороте или скейле, чтобы текст не выглядел плохо(
    var textIsTransformed = (angle != 0) || (scale != 1)
        || (layout.descScale != 1) || (layout.costScale != 1)
    var prevTexFilter = gpu_get_texfilter()
    if (textIsTransformed) { gpu_set_texfilter(true) }

    // описание
    if (layout.descText != "") {
        draw_set_font(layout.descFont)
        var descLocalX = cardWidth * scale * ((CARD_DESC_X1 + CARD_DESC_X2) * 0.5 / baseW - 0.5)
        var descLocalY = cardHeight * scale * ((CARD_DESC_Y1 + CARD_DESC_Y2) * 0.5 / baseH - 0.5)
        var descPoint = cardLocalToScreen(centerX, centerY, descLocalX, descLocalY, angle)
        drawTextBold(descPoint.x, descPoint.y, layout.descText, layout.descScale * scale, angle, c_black, alpha)
    }

    // стоимость
    draw_set_font(layout.costFont)
    drawCardStatText(centerX, centerY, cardWidth * scale * 0.28, -cardHeight * scale * 0.36, angle,
        layout.costTxt, c_white, layout.costScale * scale)
    gpu_set_texfilter(prevTexFilter)

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
    draw_set_font(prevFont)
    
    if (isSelected) {
        draw_sprite_ext(sprCardSelected, 0, centerX, centerY, spriteScaleX, spriteScaleY, angle, c_white, 1)
    }
}

// Map a card-local point (localX right, localY down; origin = card centre) to
// screen space for a card drawn with draw_sprite_ext(angle).
function cardLocalToScreen(centerX, centerY, localX, localY, angle) {
    return {
        x: centerX + localX * dcos(angle) + localY * dsin(angle),
        y: centerY - localX * dsin(angle) + localY * dcos(angle)
    }
}


// Draw short text at a card-local point with a clean one-pixel drop
// shadow, rotated to the card angle. Uses the current font & given scale.
function drawCardStatText(centerX, centerY, localX, localY, angle, text, color, scale) {
    if (text == "") { return }
    var shadowOffset = max(1, scale)
    var mainPoint = cardLocalToScreen(centerX, centerY, localX, localY, angle)
    var shadowPoint = cardLocalToScreen(centerX, centerY, localX + shadowOffset, localY + shadowOffset, angle)
    draw_text_transformed_colour(shadowPoint.x, shadowPoint.y, text, scale, scale, angle, c_black, c_black, c_black, c_black, 0.6)
    drawTextBold(mainPoint.x, mainPoint.y, text, scale, angle, color, 1)
}
