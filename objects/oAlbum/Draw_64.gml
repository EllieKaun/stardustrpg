menuEnsureCrispGui()
albumLayout(panel)

var guiWidth = display_get_gui_width()
var guiHeight = display_get_gui_height()

panel.draw()

// Заголовок
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
drawUiText(guiWidth * 0.5, guiHeight * 0.07, loc("screen.album"), guiHeight * 0.06)

// Пустой альбом
if (array_length(panel.slots) == 0) {
    drawUiText(guiWidth * 0.5, guiHeight * 0.5, loc("ui.noCardsYet"), guiHeight * 0.05)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
