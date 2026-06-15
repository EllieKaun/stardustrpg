// a controller's Draw GUI Begin (so your HUD in Draw GUI draws on top and stays bright)
var a = 0.45;   // 0 = day, ~0.45 = night
if (a > 0) {
    draw_set_alpha(a);
    draw_set_color(make_color_rgb(10, 20, 60));
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (!open) exit

collectionPanel.draw()
deckPanel.draw()
