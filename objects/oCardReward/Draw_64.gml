if (!active) exit

var sw = display_get_gui_width()
var sh = display_get_gui_height()

drawScreenDim(0.6)

var panelW = sw * 0.42
var panelH = sh * 0.7
var px = (sw - panelW) * 0.5
var py = (sh - panelH) * 0.5

draw_sprite_stretched(box, 0, px, py, panelW, panelH)

draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_color(merge_color(c_white, c_yellow, 0.4))
drawUiText(px + panelW * 0.5, py + panelH * 0.06, rewardTitle, panelH * 0.09)
draw_set_color(c_white)

if (card != undefined) {
    var cardH = panelH * 0.58
    var cardW = cardH * 2 / 3
    var cx = px + panelW * 0.5
    var cy = py + panelH * 0.52
    drawCardFace(card, cx, cy, cardW, cardH, 0, 1, 1, false)
}

draw_set_valign(fa_bottom)
draw_set_color(merge_color(c_white, c_black, 0.3))
drawUiText(px + panelW * 0.5, py + panelH - panelH * 0.04, "Click to continue", panelH * 0.05)

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
