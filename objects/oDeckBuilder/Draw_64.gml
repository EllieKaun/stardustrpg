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
var counterBoxH = collectionPanel.tabH * 0.8
var counterScale = uiTextScale(collectionCounterText, counterBoxH * 0.65, collectionPanel.w * 0.35)
var counterBoxW = string_width(collectionCounterText) * counterScale + collectionPanel.tabPadding * 4
var counterBoxX = collectionPanel.x + collectionPanel.w - collectionPanel.padding * 0.5 - counterBoxW
var counterBoxY = collectionPanel.y - collectionPanel.tabH + (collectionPanel.tabH - counterBoxH) * 0.5
draw_sprite_stretched_ext(TabFill, 0, counterBoxX, counterBoxY, counterBoxW, counterBoxH, #8E3B31, 1)
draw_sprite_stretched(TabBorder, 0, counterBoxX, counterBoxY, counterBoxW, counterBoxH)
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text_transformed(counterBoxX + counterBoxW / 2, counterBoxY + counterBoxH / 2,
    collectionCounterText, counterScale, counterScale, 0)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

if (global.deckTutorialStage == DeckTutorialStage.Steps && deckTutorial.isActive()) {
    deckTutorial.draw()
}
