// Чёткий GUI (на случай ресайза окна)
menuEnsureCrispGui()

var gw = display_get_gui_width()
var gh = display_get_gui_height()

// фон → (пункты, если ниже) → передний план → (пункты, если выше)
menuDrawScene(backLayers, foreLayers, menu, itemsAboveForeground, gw, gh)

// Заголовок (плейсхолдер)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
drawUiText(gw * 0.5, gh * 0.22, "MAIN MENU", gh * 0.09)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
