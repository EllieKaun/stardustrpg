guiSyncCrisp()

// Туториал, сообщение о нажатии таба и показе декбилдера
if (global.deckTutorialStage == DeckTutorialStage.AwaitOpen) {
    var hw = display_get_gui_width()
    var hh = display_get_gui_height()
    var msg = loc("ui.pressTabDeck")
    var boxH = max(hh * 0.12, 84)
    var boxW = hw * 0.6
    var bx = (hw - boxW) * 0.5
    var by = hh * 0.06
    draw_sprite_stretched(box, 0, bx, by, boxW, boxH)

    var pulse = 0.6 + 0.4 * (0.5 + 0.5 * sin(current_time / 300))
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_set_color(c_white)
    draw_set_alpha(pulse)
    drawUiText(bx + boxW * 0.5, by + boxH * 0.5, msg, boxH * 0.4)
    draw_set_alpha(1)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}

var shopOpen = instance_exists(oShop) && oShop.open
var deckOpen = instance_exists(oDeckBuilder) && oDeckBuilder.open
if (!shopOpen && !deckOpen && !global.cutsceneActive) {
    var gw = display_get_gui_width()
    var gh = display_get_gui_height()
    var goldMargin = gh * 0.03
    var coinH = gh * 0.06
    var coinScale = coinH / sprite_get_height(CoinIcon)
    var coinW = sprite_get_width(CoinIcon) * coinScale
    var coinCX = gw - goldMargin - coinW * 0.5
    var coinCY = goldMargin + coinH * 0.5
    draw_sprite_ext(CoinIcon, 0, coinCX, coinCY, coinScale, coinScale, 0, c_white, 1)

    var goldStr = string(getGold())
    draw_set_halign(fa_right)
    draw_set_valign(fa_middle)
    draw_set_color(c_black)
    var goldScale = uiTextScale(goldStr, coinH * 0.9, gw * 0.15)
    var goldX = coinCX - coinW * 0.5 - goldMargin * 0.4
    draw_text_transformed(goldX + goldScale, coinCY + goldScale, goldStr, goldScale, goldScale, 0)
    draw_set_color(c_white)
    draw_text_transformed(goldX, coinCY, goldStr, goldScale, goldScale, 0)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}

// Катсцена появления босса
if (global.cutsceneActive && sprite_exists(cutsceneSprite)) {
    var sw = display_get_gui_width()
    var sh = display_get_gui_height()

    drawScreenDim(0.5)

    var frame = min(floor(cutsceneFrame), sprite_get_number(cutsceneSprite) - 1)
    draw_sprite_stretched(cutsceneSprite, frame, 0, 0, sw, sh)
}

autosaveDrawIcon()
