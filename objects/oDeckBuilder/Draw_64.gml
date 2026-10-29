var nightAlpha = 0 // Ночь 0.45, 0 для дня
if (nightAlpha > 0) {
    draw_set_alpha(nightAlpha)
    draw_set_color(make_color_rgb(10, 20, 60))
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
    draw_set_alpha(1)
    draw_set_color(c_white)
}

if (!open) { exit }

guiSyncCrisp()
layoutPanels()
collectionPanel.draw()
deckPanel.draw()

draw_set_font(uiFont())
draw_set_color(c_white)
draw_set_halign(fa_right)
draw_set_valign(fa_middle)
var counterScale = uiTextScale(collectionCounterText, collectionPanel.tabH * 0.6, collectionPanel.w * 0.35)
draw_text_transformed(collectionPanel.x + collectionPanel.w - collectionPanel.padding,
    collectionPanel.y - collectionPanel.tabH / 2,
    collectionCounterText, counterScale, counterScale, 0)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

