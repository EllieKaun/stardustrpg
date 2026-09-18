menuEnsureCrispGui()

var gw = display_get_gui_width()
var gh = display_get_gui_height()

menuDrawScene(backLayers, foreLayers, menu, itemsAboveForeground, gw, gh)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
drawUiText(gw * 0.75, gh * 0.22, "MAIN MENU", gh * 0.09)

if (confirmPrompt != "") {
    draw_set_color(merge_color(c_white, c_yellow, 0.35))
    drawUiText(gw * 0.75, gh * 0.36, confirmPrompt, gh * 0.05)
    draw_set_color(c_white)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
