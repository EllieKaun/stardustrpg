// Обработка состояния победы (чтение с клавиатуры)
function stepVictoryScreen() {
    var count = array_length(rewardChoices)

    if (count == 0) { // Если нет наград
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space))
            returnToOverworld()
        return
    }
    if (rewardSelected) return // когда награда уже выбрана энтером - все, блокируем

    if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")))
        rewardCursor = (rewardCursor - 1 + count) mod count 
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")))
        rewardCursor = (rewardCursor + 1) mod count

    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) { // подтверждение награды
        var picked = rewardChoices[rewardCursor].cardRef
        unlockCard(picked.id, picked.rarity, 1)
        playerDataSave()
        rewardSelected = true
        returnToOverworld()
    }
}

// Обработка состояния поражения (чтение с клавиатуры)
function stepGameOverScreen() { 
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) gameOverCursor = 0
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) gameOverCursor = 1

    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        if (gameOverCursor == 0) retryBattle()
        else returnToOverworld()
    }
}

// Отобразить победный скрин
function drawVictoryScreen() {
    // base coords — this draws under the battle UI scale matrix (see Battle Draw GUI)
    var sw = guiBaseWidth()
    var sh = guiBaseHeight()

    // Затемнение
    draw_set_color(c_black); draw_set_alpha(0.5)
    draw_rectangle(0, 0, sw, sh, false)
    draw_set_alpha(1)

    // Надпись победы
    draw_set_font(fnM3x6_22)
    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_text(sw / 2, floor(sh * 0.12), "VICTORY")

    
    var count = array_length(rewardChoices)
    
    // Если нет наград 
    if (count == 0) {
        draw_set_font(fnM3x6_14)
        draw_text(sw / 2, sh / 2, "No rewards — press Enter")
        draw_set_halign(fa_left); draw_set_valign(fa_top)
        return
    }

    var cardH = sh / 3.5
    var cardW = cardH * 2 / 3
    var gap = 8
    var totalW = count * cardW + (count - 1) * gap
    var startX = (sw - totalW) / 2
    var cardY = floor(sh * 0.22)

    // Рисование наград
    for (var i = 0; i < count; i++) {
        var cx = floor(startX + i * (cardW + gap))
        var isSel = (i == rewardCursor)
        var dy = isSel ? cardY - 3 : cardY

        drawCard(rewardChoices[i], cx, dy, cardW, cardH)

        if (isSel) {
            draw_set_color(c_yellow)
            draw_rectangle(cx - 1, dy - 1, cx + cardW + 1, dy + cardH + 1, true)
            draw_sprite(sPointer, 0, floor(cx - 10), floor(dy + cardH / 2))
        }
    }

    // Панель описания
    var panelY = floor(cardY + cardH + 12);
    var panelH = floor(sh - panelY - sh * 0.06);
    drawRewardDescription(rewardChoices[rewardCursor], startX, panelY, totalW, panelH)

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}

// Рисование описания наградной карты
function drawRewardDescription(card, px, py, pw, ph) {
    draw_sprite_stretched(sprCardDesk, 0, px, py, pw, ph) // Бэк
    if (card == undefined) return

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_font(fnM3x6_14)
    draw_set_color(c_white)

    var ix = floor(px + 8)
    var iy = floor(py + 6)
    var lh = 12

    draw_text(ix, iy, string(card.name))
    draw_text(ix, iy + lh, "Type: " + (card.actionType == StarriorStates.Attack ? "Attack" : "Cast"))

    var cy = iy + lh * 2

    for (var i = 0; i < array_length(card.effects); i++) {
        var effect = card.effects[i]
        if (effect.type == EffectTypes.Damage || effect.type == EffectTypes.Heal) {
            var isAll = (card.target == TargetTypes.AllEnemies || card.target == TargetTypes.AllAllies)
            var maxNum = 0;
            switch (card.rarity) {
                case CardsRarity.Default: {
                    maxNum = isAll ? 2 : 4
                    break
                }
                case CardsRarity.Unusual: {
                    maxNum = isAll ? 4 : 6
                    break
                }
                case CardsRarity.Rare: {
                    maxNum = isAll ? 6 : 8
                    break
                }
                case CardsRarity.Epic: {
                    maxNum = isAll ? 8 : 12
                    break
                }
            }
            var label = (effect.type == EffectTypes.Damage) ? "Damage: " : "Heal: "
            draw_text(ix, cy, label + "1-" + string(maxNum))
            cy += lh
            break
        }
    }

    var effectStr = "";
    for (var i = 0; i < array_length(card.effects); i++) {
        var effect = card.effects[i]
        if (effect.type != EffectTypes.Damage && effect.type != EffectTypes.Heal)
            effectStr += effectTypeToString(effect.type) + " "
    }
    if (effectStr != "") { 
        draw_text(ix, cy, "Effects: " + effectStr)
        cy += lh
    }

    var costLabel = (card.costType() == CostType.Mana) ? "MP" : "HP"
    draw_text(ix, cy, "Cost: " + string(card.costValue()) + " " + costLabel)
}

// Рисование экрана поражения
function drawGameOverScreen() {
    // base coords — this draws under the battle UI scale matrix (see Battle Draw GUI)
    var sw = guiBaseWidth()
    var sh = guiBaseHeight()

    draw_set_color(c_black) 
    draw_set_alpha(0.6)
    draw_rectangle(0, 0, sw, sh, false) // Затемнение
    draw_set_alpha(1)

    draw_set_font(fnM3x6_22)
    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_text(sw / 2, floor(sh * 0.30), "GAME OVER") // GameOver надпись

    var labels = ["RETRY", "EXIT"]
    var btnW = 64, btnH = 18, gap = 16
    var totalW = btnW * 2 + gap;
    var startX = (sw - totalW) / 2
    var btnY   = floor(sh * 0.5)

    draw_set_font(fnM3x6_14)
    for (var i = 0; i < 2; i++) { // Рисование кнопок Ретрай и Выход
        var bx = floor(startX + i * (btnW + gap))
        var isSel = (gameOverCursor == i)

        draw_sprite_stretched(sprCardDeskFull, 0, bx, btnY, btnW, btnH)
        draw_set_color(isSel ? c_yellow : c_white)
        draw_text(bx + btnW / 2, btnY + btnH / 2, labels[i])

        if (isSel) {
            draw_set_color(c_yellow)
            draw_rectangle(bx, btnY, bx + btnW, btnY + btnH, true)
            draw_sprite(sPointer, 0, floor(bx - 10), floor(btnY + btnH / 2))
        }
    }

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}