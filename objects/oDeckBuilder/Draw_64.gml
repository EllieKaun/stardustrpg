var a = 0 // Ночь 0.45, 0 для дня
if (a > 0) {
    draw_set_alpha(a)
    draw_set_color(make_color_rgb(10, 20, 60))
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
    draw_set_alpha(1)
    draw_set_color(c_white)
}

if (!open) exit

layoutPanels()
collectionPanel.draw()
deckPanel.draw()
