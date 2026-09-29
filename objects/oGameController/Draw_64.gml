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

var shopOpen = instance_exists(oShop) && oShop.open
var deckOpen = instance_exists(oDeckBuilder) && oDeckBuilder.open
if (!shopOpen && !deckOpen && !global.cutsceneActive) {
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

// Катсцена появления босса
if (global.cutsceneActive && sprite_exists(cutsceneSprite)) {
    var guiWidth = display_get_gui_width()
    var guiHeight = display_get_gui_height()

    drawScreenDim(0.5)

    var frame = min(floor(cutsceneFrame), sprite_get_number(cutsceneSprite) - 1)
    draw_sprite_stretched(cutsceneSprite, frame, 0, 0, guiWidth, guiHeight)
}

autosaveDrawIcon()
