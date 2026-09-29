// Обработка ввода на экране победы
function stepVictoryScreen() {
    var mouseX = device_mouse_x_to_gui(0)
    var mouseY = device_mouse_y_to_gui(0)
    var mouseClicked = mouse_check_button_pressed(mb_left)

    var count = array_length(rewardChoices)

    if (count == 0) { // Если нет наград
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mouseClicked) {
            returnToOverworld()
        }
        return
    }
    if (rewardSelected) { return } // когда награда уже выбрана

    var confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)

    for (var rewardIndex = 0; rewardIndex < array_length(rewardHitRects); rewardIndex++) {
        var hitRect = rewardHitRects[rewardIndex]
        if (pointInRect(mouseX, mouseY, hitRect.x, hitRect.y, hitRect.w, hitRect.h)) {
            rewardCursor = hitRect.index
            if (mouseClicked) { confirm = true }
            break
        }
    }

    if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) {
        rewardCursor = (rewardCursor - 1 + count) mod count
    }
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        rewardCursor = (rewardCursor + 1) mod count
    }

    if (confirm) { // подтверждение награды
        var picked = rewardChoices[rewardCursor].cardRef
        unlockCard(picked.id, picked.rarity, 1)
        analyticsReward(picked.id, picked.rarity, "battle") // аналитика: забрал карту-награду за победу
        playerDataSave()
        rewardSelected = true
        returnToOverworld()
    }
}

// Обработка состояния поражения (чтение с клавиатуры)
function stepGameOverScreen() {
    var mouseX = device_mouse_x_to_gui(0)
    var mouseY = device_mouse_y_to_gui(0)
    var mouseClicked = mouse_check_button_pressed(mb_left)

    var confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)

    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) { gameOverCursor = 0 }
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) { gameOverCursor = 1 }

    // Мышь: наведение выбирает кнопку, клик подтверждает
    for (var buttonIndex = 0; buttonIndex < array_length(gameOverHitRects); buttonIndex++) {
        var hitRect = gameOverHitRects[buttonIndex]
        if (pointInRect(mouseX, mouseY, hitRect.x, hitRect.y, hitRect.w, hitRect.h)) {
            gameOverCursor = hitRect.index
            if (mouseClicked) { confirm = true }
            break
        }
    }

    if (confirm) {
        if (gameOverCursor == 0) { retryBattle() }
        else { returnToOverworld() }
    }
}

// Отобразить победный экран
function drawVictoryScreen() {
    // координаты GUI 
    var screenWidth = display_get_gui_width()
    var screenHeight = display_get_gui_height()
    var guiScaleFactor = guiScale()

    // Затемнение
    drawScreenDim(0.5)

    // Надпись победы
    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawUiText(screenWidth / 2, floor(screenHeight * 0.08), loc("ui.victory"), screenHeight * 0.07)

    var count = array_length(rewardChoices)
    rewardHitRects = []

    // Если нет наград
    if (count == 0) {
        drawUiText(screenWidth / 2, screenHeight / 2, loc("ui.noRewards"), screenHeight * 0.04)
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        return
    }

    var cardH = floor(screenHeight * 0.42)
    var cardW = floor(cardH * 2 / 3)
    var cardGap = 16 * guiScaleFactor
    var totalW = count * cardW + (count - 1) * cardGap
    var startX = (screenWidth - totalW) / 2
    var cardY = floor(screenHeight * 0.15)

    // Рисование наград
    for (var rewardIndex = 0; rewardIndex < count; rewardIndex++) {
        var cardX = floor(startX + rewardIndex * (cardW + cardGap))
        var isSelected = (rewardIndex == rewardCursor)
        var cardDrawY = isSelected ? cardY - 3 * guiScaleFactor : cardY

        array_push(rewardHitRects, { x: cardX, y: cardY, w: cardW, h: cardH, index: rewardIndex })

        drawCard(rewardChoices[rewardIndex], cardX, cardDrawY, cardW, cardH)

        if (isSelected) {
            draw_sprite_ext(sPointer, 0, floor(cardX - 10 * guiScaleFactor), floor(cardDrawY + cardH / 2), guiScaleFactor, guiScaleFactor, 0, c_white, 1)
        }
    }

    // Панель описания
    var panelX = floor(screenWidth * 0.05)
    var panelW = screenWidth - panelX * 2
    var panelY = floor(cardY + cardH + 12 * guiScaleFactor)
    var panelH = floor(screenHeight * 0.95 - panelY)
    drawRewardDescription(rewardChoices[rewardCursor], panelX, panelY, panelW, panelH)

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}

// Рисование описания наградной карты
function drawRewardDescription(card, panelX, panelY, panelW, panelH) {
    draw_sprite_stretched(box, 0, panelX, panelY, panelW, panelH) // Бэк
    if (card == undefined) { return }

    var guiScaleFactor = display_get_gui_width() / guiBaseWidth()
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)

    var textX = floor(panelX + 12 * guiScaleFactor)
    var textTopY = floor(panelY + 8 * guiScaleFactor)
    // высота строки — от высоты панели, чтобы текст заполнял её, а не терялся
    var lineHeight = min(16 * guiScaleFactor, panelH / 5.5)
    var textH = lineHeight * 0.85

    drawUiText(textX, textTopY, cardDisplayName(card), textH)
    drawUiText(textX, textTopY + lineHeight, loc("reward.type") + (card.actionType == StarriorStates.Attack ? loc("reward.attack") : loc("reward.cast")), textH)

    var lineY = textTopY + lineHeight * 2

    for (var effectIndex = 0; effectIndex < array_length(card.effects); effectIndex++) {
        var effect = card.effects[effectIndex]
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
            var label = (effect.type == EffectTypes.Damage) ? loc("reward.damage") : loc("reward.heal")
            drawUiText(textX, lineY, label + "1-" + string(maxNum), textH)
            lineY += lineHeight
            break
        }
    }

    var effectStr = "";
    for (var effectIndex = 0; effectIndex < array_length(card.effects); effectIndex++) {
        var effect = card.effects[effectIndex]
        if (effect.type != EffectTypes.Damage && effect.type != EffectTypes.Heal) {
            effectStr += effectTypeToString(effect.type) + " "
        }
    }
    if (effectStr != "") {
        drawUiText(textX, lineY, loc("reward.effects") + effectStr, textH)
        lineY += lineHeight
    }

    var costLabel = (card.costType() == CostType.Mana) ? loc("reward.mp") : loc("reward.hp")
    drawUiText(textX, lineY, loc("reward.cost") + string(card.costValue()) + " " + costLabel, textH)
}

// Рисование экрана поражения
function drawGameOverScreen() {
    // координаты GUI
    var screenWidth = display_get_gui_width()
    var screenHeight = display_get_gui_height()
    var guiScaleFactor  = guiScale()

    drawScreenDim(0.6) // Затемнение

    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawUiText(screenWidth / 2, floor(screenHeight * 0.30), loc("ui.gameover"), screenHeight * 0.06) // GameOver надпись

    var labels = [loc("ui.retry"), loc("ui.exit")]
    var btnW = 64 * guiScaleFactor, btnH = 18 * guiScaleFactor, buttonGap = 16 * guiScaleFactor
    var totalW = btnW * 2 + buttonGap;
    var startX = (screenWidth - totalW) / 2
    var btnY   = floor(screenHeight * 0.5)
    gameOverHitRects = []

    for (var buttonIndex = 0; buttonIndex < 2; buttonIndex++) { // Рисование кнопок Ретрай и Выход
        var buttonX = floor(startX + buttonIndex * (btnW + buttonGap))
        var isSelected = (gameOverCursor == buttonIndex)

        array_push(gameOverHitRects, { x: buttonX, y: btnY, w: btnW, h: btnH, index: buttonIndex })

        drawButtonFrame(buttonX, btnY, btnW, btnH)
        draw_set_color(isSelected ? c_yellow : c_white)
        drawUiText(buttonX + btnW / 2, btnY + btnH / 2, labels[buttonIndex], btnH * 0.55)

        if (isSelected) {
            draw_sprite_ext(sPointer, 0, floor(buttonX - 10 * guiScaleFactor), floor(btnY + btnH / 2), guiScaleFactor, guiScaleFactor, 0, c_white, 1)
        }
    }

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}