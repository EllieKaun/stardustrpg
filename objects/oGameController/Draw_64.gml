guiSyncCrisp()

// Туториал, сообщение о нажатии таба и показе декбилдера
if (global.deckTutorialStage == DeckTutorialStage.AwaitOpen) {
    var guiWidth = display_get_gui_width()
    var guiHeight = display_get_gui_height()
    var message = loc("ui.pressTabDeck")
    var boxH = max(guiHeight * 0.12, 84)
    var boxW = guiWidth * 0.6
    var boxX = (guiWidth - boxW) * 0.5
    var boxY = guiHeight * 0.06
    draw_sprite_stretched(box, 0, boxX, boxY, boxW, boxH)

    var pulse = 0.6 + 0.4 * (0.5 + 0.5 * sin(current_time / 300))
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_set_color(c_white)
    draw_set_alpha(pulse)
    drawUiText(boxX + boxW * 0.5, boxY + boxH * 0.5, message, boxH * 0.4)
    draw_set_alpha(1)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}

if (worldHudVisible()) {
    // Рисуем монетки
    var guiWidth = display_get_gui_width()
    var guiHeight = display_get_gui_height()
    var goldMargin = guiHeight * 0.03
    var coinH = guiHeight * 0.06
    var coinScale = coinH / sprite_get_height(CoinIcon)
    var coinW = sprite_get_width(CoinIcon) * coinScale
    var coinCenterX = guiWidth - goldMargin - coinW * 0.5
    var coinCenterY = goldMargin + coinH * 0.5
    draw_sprite_ext(CoinIcon, 0, coinCenterX, coinCenterY, coinScale, coinScale, 0, c_white, 1)

    var goldStr = string(getGold())
    draw_set_halign(fa_right)
    draw_set_valign(fa_middle)
    draw_set_color(c_black)
    var goldScale = uiTextScale(goldStr, coinH * 0.9, guiWidth * 0.15)
    var goldX = coinCenterX - coinW * 0.5 - goldMargin * 0.4
    draw_text_transformed(goldX + goldScale, coinCenterY + goldScale, goldStr, goldScale, goldScale, 0)
    draw_set_color(c_white)
    draw_text_transformed(goldX, coinCenterY, goldStr, goldScale, goldScale, 0)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}

// Предметы для квеста лисички
var foxState = questFoxState()
if (worldHudVisible()
    && (foxState == QuestFoxState.Active || foxState == QuestFoxState.ItemsCollected)) {
    var guiWidth = display_get_gui_width()
    var guiHeight = display_get_gui_height()
    var margin = floor(guiHeight * 0.03)
    var iconH = floor(guiHeight * 0.06)
    var gap = floor(guiHeight * 0.02) // промежуток между предметами
    var slotW = iconH + gap // ширина ячейки одного предмета
    var countH = floor(iconH * 0.42) // высота текста счётчика
    var countY = margin + iconH + floor(gap * 0.25)

    var items = [QuestFoxItem.PineCone, QuestFoxItem.Petunia, QuestFoxItem.Cauldron]
    for (var i = 0; i < array_length(items); i++) {
        var item = items[i]
        var iconCenterX = margin + i * slotW + iconH * 0.5
        var iconCenterY = margin + iconH * 0.5
        var done = questFoxItemDone(item)
        var pop = questFoxItemPickupScale(item) // отклик на подбор 

        var spr = questFoxItemSprite(item)
        if (spr != noone) {
            var sprScale = (iconH / sprite_get_height(spr)) * pop
            draw_sprite_ext(spr, 0, floor(iconCenterX), floor(iconCenterY),
                sprScale, sprScale, 0, c_white, done ? 1 : 0.85)
        } else {
            var half = iconH * 0.5 * pop
            draw_set_color(done ? c_lime : make_color_rgb(92, 82, 70))
            draw_set_alpha(0.85)
            draw_roundrect(floor(iconCenterX - half), floor(iconCenterY - half),
                floor(iconCenterX + half), floor(iconCenterY + half), false)
            draw_set_alpha(1)
            draw_set_color(c_white)
        }

        // Подсветка собранного предмета
        if (done) {
            var doneHalf = iconH * 0.5
            draw_set_color(c_lime)
            draw_set_alpha(0.9)
            draw_rectangle(floor(iconCenterX - doneHalf), floor(iconCenterY - doneHalf),
                floor(iconCenterX + doneHalf), floor(iconCenterY + doneHalf), true)
            draw_set_alpha(1)
            draw_set_color(c_white)
        }

        // Счётчик n/need под иконкой, с тенью, через drawUiText
        var countStr = string(questFoxItemCount(item)) + "/" + string(questFoxItemNeeded(item))
        draw_set_halign(fa_center)
        draw_set_valign(fa_top)
        draw_set_color(c_black)
        drawUiText(iconCenterX + 1, countY + 1, countStr, countH, iconH * 1.4)
        draw_set_color(done ? c_lime : c_white)
        drawUiText(iconCenterX, countY, countStr, countH, iconH * 1.4)
        draw_set_color(c_white)
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
    }

    // Подсказка когда всё собрано
    if (foxState == QuestFoxState.ItemsCollected) {
        var hint = loc("ui.returnToFox")
        var hintH = floor(iconH * 0.5)
        var hintY = countY + countH + gap
        var hintMaxW = 3 * slotW
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(c_black)
        drawUiText(margin + 1, hintY + 1, hint, hintH, hintMaxW)
        draw_set_color(c_yellow)
        drawUiText(margin, hintY, hint, hintH, hintMaxW)
        draw_set_color(c_white)
    }
}

// Катсцена появления босса
if (global.cutsceneActive && sprite_exists(cutsceneSprite)) {
    var guiWidth = display_get_gui_width()
    var guiHeight = display_get_gui_height()

    drawScreenDim(0.5)

    var frame = min(floor(cutsceneFrame), sprite_get_number(cutsceneSprite) - 1)
    draw_sprite_stretched(cutsceneSprite, frame, 0, 0, guiWidth, guiHeight)
}

autosaveDrawIcon()

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_font(fnUI_12)
draw_set_color(c_lime)
draw_text(8, 8, "fps " + string(fps) + "   real " + string(round(fps_real)) + "   fireflies " + string(instance_number(oFirefly)) + "   enemies " + string(instance_number(oEnemy)))
draw_set_color(c_white)
