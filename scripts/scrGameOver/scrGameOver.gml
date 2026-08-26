// Обработка состояния победы (чтение с клавиатуры)
function stepVictoryScreen() {
    var mx = device_mouse_x_to_gui(0)
    var my = device_mouse_y_to_gui(0)
    var mClick = mouse_check_button_pressed(mb_left)

    var count = array_length(rewardChoices)

    if (count == 0) { // Если нет наград
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mClick)
            returnToOverworld()
        return
    }
    if (rewardSelected) return // когда награда уже выбрана

    var confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)

    for (var i = 0; i < array_length(rewardHitRects); i++) {
        var r = rewardHitRects[i]
        if (pointInRect(mx, my, r.x, r.y, r.w, r.h)) {
            rewardCursor = r.index
            if (mClick) confirm = true
            break
        }
    }

    if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")))
        rewardCursor = (rewardCursor - 1 + count) mod count
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")))
        rewardCursor = (rewardCursor + 1) mod count

    if (confirm) { // подтверждение награды
        var picked = rewardChoices[rewardCursor].cardRef
        unlockCard(picked.id, picked.rarity, 1)
        playerDataSave()
        rewardSelected = true
        returnToOverworld()
    }
}

// Обработка состояния поражения (чтение с клавиатуры)
function stepGameOverScreen() {
    var mx = device_mouse_x_to_gui(0)
    var my = device_mouse_y_to_gui(0)
    var mClick = mouse_check_button_pressed(mb_left)

    var confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)

    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) gameOverCursor = 0
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) gameOverCursor = 1

    // Мышь: наведение выбирает кнопку, клик подтверждает
    for (var i = 0; i < array_length(gameOverHitRects); i++) {
        var r = gameOverHitRects[i]
        if (pointInRect(mx, my, r.x, r.y, r.w, r.h)) {
            gameOverCursor = r.index
            if (mClick) confirm = true
            break
        }
    }

    if (confirm) {
        if (gameOverCursor == 0) retryBattle()
        else returnToOverworld()
    }
}

// Отобразить победный скрин
function drawVictoryScreen() {
    // координаты GUI/окна — бой рисуется без матрицы (см. Battle Draw GUI)
    var sw = display_get_gui_width()
    var sh = display_get_gui_height()
    var s  = sw / guiBaseWidth()

    // Затемнение
    draw_set_color(c_black); draw_set_alpha(0.5)
    draw_rectangle(0, 0, sw, sh, false)
    draw_set_alpha(1)

    // Надпись победы
    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawUiText(sw / 2, floor(sh * 0.08), "VICTORY", sh * 0.07)

    var count = array_length(rewardChoices)
    rewardHitRects = []

    // Если нет наград
    if (count == 0) {
        drawUiText(sw / 2, sh / 2, "No rewards — press Enter", sh * 0.04)
        draw_set_halign(fa_left); draw_set_valign(fa_top)
        return
    }

    var cardH = floor(sh * 0.42)
    var cardW = floor(cardH * 2 / 3)
    var gap = 16 * s
    var totalW = count * cardW + (count - 1) * gap
    var startX = (sw - totalW) / 2
    var cardY = floor(sh * 0.15)

    // Рисование наград
    for (var i = 0; i < count; i++) {
        var cx = floor(startX + i * (cardW + gap))
        var isSel = (i == rewardCursor)
        var dy = isSel ? cardY - 3 * s : cardY

        array_push(rewardHitRects, { x: cx, y: cardY, w: cardW, h: cardH, index: i })

        drawCard(rewardChoices[i], cx, dy, cardW, cardH)

        if (isSel) {
            draw_set_color(c_yellow)
            draw_rectangle(cx - 1, dy - 1, cx + cardW + 1, dy + cardH + 1, true)
            draw_sprite_ext(sPointer, 0, floor(cx - 10 * s), floor(dy + cardH / 2), s, s, 0, c_white, 1)
        }
    }

    // Панель описания
    var panelX = floor(sw * 0.05)
    var panelW = sw - panelX * 2
    var panelY = floor(cardY + cardH + 12 * s)
    var panelH = floor(sh * 0.95 - panelY)
    drawRewardDescription(rewardChoices[rewardCursor], panelX, panelY, panelW, panelH)

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}

// Рисование описания наградной карты
function drawRewardDescription(card, px, py, pw, ph) {
    draw_sprite_stretched(box6, 0, px, py, pw, ph) // Бэк
    if (card == undefined) return

    var s = display_get_gui_width() / guiBaseWidth()
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)

    var ix = floor(px + 12 * s)
    var iy = floor(py + 8 * s)
    // высота строки — от высоты панели, чтобы текст заполнял её, а не терялся
    var lh = min(16 * s, ph / 5.5)
    var textH = lh * 0.85

    drawUiText(ix, iy, string(card.name), textH)
    drawUiText(ix, iy + lh, "Type: " + (card.actionType == StarriorStates.Attack ? "Attack" : "Cast"), textH)

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
            drawUiText(ix, cy, label + "1-" + string(maxNum), textH)
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
        drawUiText(ix, cy, "Effects: " + effectStr, textH)
        cy += lh
    }

    var costLabel = (card.costType() == CostType.Mana) ? "MP" : "HP"
    drawUiText(ix, cy, "Cost: " + string(card.costValue()) + " " + costLabel, textH)
}

// Рисование экрана поражения
function drawGameOverScreen() {
    // координаты GUI/окна — бой рисуется без матрицы (см. Battle Draw GUI)
    var sw = display_get_gui_width()
    var sh = display_get_gui_height()
    var s  = sw / guiBaseWidth()

    draw_set_color(c_black)
    draw_set_alpha(0.6)
    draw_rectangle(0, 0, sw, sh, false) // Затемнение
    draw_set_alpha(1)

    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawUiText(sw / 2, floor(sh * 0.30), "GAME OVER", sh * 0.06) // GameOver надпись

    var labels = ["RETRY", "EXIT"]
    var btnW = 64 * s, btnH = 18 * s, gap = 16 * s
    var totalW = btnW * 2 + gap;
    var startX = (sw - totalW) / 2
    var btnY   = floor(sh * 0.5)
    gameOverHitRects = []

    for (var i = 0; i < 2; i++) { // Рисование кнопок Ретрай и Выход
        var bx = floor(startX + i * (btnW + gap))
        var isSel = (gameOverCursor == i)

        array_push(gameOverHitRects, { x: bx, y: btnY, w: btnW, h: btnH, index: i })

        draw_sprite_stretched(box, 0, bx, btnY, btnW, btnH)
        draw_set_color(isSel ? c_yellow : c_white)
        drawUiText(bx + btnW / 2, btnY + btnH / 2, labels[i], btnH * 0.55)

        if (isSel) {
            draw_set_color(c_yellow)
            draw_rectangle(bx, btnY, bx + btnW, btnY + btnH, true)
            draw_sprite_ext(sPointer, 0, floor(bx - 10 * s), floor(btnY + btnH / 2), s, s, 0, c_white, 1)
        }
    }

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}