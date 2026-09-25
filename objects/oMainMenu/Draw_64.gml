menuEnsureCrispGui()

var guiWidth = display_get_gui_width()
var guiHeight = display_get_gui_height()

menuDrawScene(backLayers, foreLayers, menu, itemsAboveForeground, guiWidth, guiHeight)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
drawUiText(guiWidth * 0.75, guiHeight * 0.22, loc("screen.mainMenu"), guiHeight * 0.09)

if (confirmPrompt != "") {
    draw_set_color(merge_color(c_white, c_yellow, 0.35))
    drawUiText(guiWidth * 0.75, guiHeight * 0.36, confirmPrompt, guiHeight * 0.05)
    draw_set_color(c_white)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
