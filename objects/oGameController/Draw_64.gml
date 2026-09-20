guiSyncCrisp()

// Туториал, сообщение о нажатии таба и показе декбилдера
if (global.deckTutorialStage == DeckTutorialStage.AwaitOpen) {
    var hw = display_get_gui_width()
    var hh = display_get_gui_height()
    var msg = "Press TAB to open your deck"
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

// Катсцена появления босса 
if (global.cutsceneActive && sprite_exists(cutsceneSprite)) {
    var sw = display_get_gui_width()
    var sh = display_get_gui_height()

    drawScreenDim(0.5)

    var frame = min(floor(cutsceneFrame), sprite_get_number(cutsceneSprite) - 1)
    draw_sprite_stretched(cutsceneSprite, frame, 0, 0, sw, sh)
}

autosaveDrawIcon()
