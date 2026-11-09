menuEnsureCrispGui()

var guiWidth = display_get_gui_width()
var guiHeight = display_get_gui_height()

menuDrawScene(backLayers, foreLayers, menu, itemsAboveForeground, guiWidth, guiHeight)

draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_color(c_white)
drawUiTextOutline(guiWidth * 0.24, guiHeight * 0.03, loc("screen.paused"), guiHeight * 0.12, c_black, 2)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
