menuEnsureCrispGui()

var guiWidth = display_get_gui_width()
var guiHeight = display_get_gui_height()

menuDrawScene(backLayers, foreLayers, menu, itemsAboveForeground, guiWidth, guiHeight)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
drawUiText(guiWidth * 0.6, guiHeight * 0.36, loc("screen.paused"), guiHeight * 0.08)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
