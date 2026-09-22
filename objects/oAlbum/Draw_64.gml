menuEnsureCrispGui()
albumLayout(panel)

var gw = display_get_gui_width()
var gh = display_get_gui_height()

// Затемнение
drawScreenDim(0.85)
panel.draw()

// Заголовок
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
drawUiText(gw * 0.5, gh * 0.07, "ALBUM", gh * 0.06)

// Пустой альбом
if (array_length(panel.slots) == 0) {
    drawUiText(gw * 0.5, gh * 0.5, "No cards yet", gh * 0.05)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
