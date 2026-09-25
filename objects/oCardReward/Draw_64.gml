if (!active) { exit }

var guiWidth = display_get_gui_width()
var guiHeight = display_get_gui_height()

drawScreenDim(0.6)

var panelW = guiWidth * 0.42
var panelH = guiHeight * 0.7
var panelX = (guiWidth - panelW) * 0.5
var panelY = (guiHeight - panelH) * 0.5

draw_sprite_stretched(box, 0, panelX, panelY, panelW, panelH)

draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_color(merge_color(c_white, c_yellow, 0.4))
drawUiText(panelX + panelW * 0.5, panelY + panelH * 0.06, rewardTitle, panelH * 0.09, panelW * 0.9)
draw_set_color(c_white)

if (card != undefined) {
    var cardH = panelH * 0.58
    var cardW = cardH * 2 / 3
    var cardCenterX = panelX + panelW * 0.5
    var cardCenterY = panelY + panelH * 0.52
    drawCardFace(card, cardCenterX, cardCenterY, cardW, cardH, 0, 1, 1, false)
}

draw_set_valign(fa_bottom)
draw_set_color(merge_color(c_white, c_black, 0.3))
drawUiText(panelX + panelW * 0.5, panelY + panelH - panelH * 0.04, loc("ui.clickContinue"), panelH * 0.05, panelW * 0.8)

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
