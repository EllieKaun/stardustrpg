menuEnsureCrispGui()

var gw = display_get_gui_width()
var gh = display_get_gui_height()

menuDrawScene(backLayers, foreLayers, menu, itemsAboveForeground, gw, gh)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
drawUiText(gw * 0.6, gh * 0.36, "PAUSED", gh * 0.08)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
