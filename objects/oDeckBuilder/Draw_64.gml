/// obj_card_menu — Draw GUI Event

// Apply scaling transform so everything draws at base resolution
// then gets scaled+offset to the window with letterboxing
var _sx = global.UI_SCALE;
var _ox = global.UI_OFFSET_X;
var _oy = global.UI_OFFSET_Y;

// Letterbox bars (black)
draw_set_color(c_black);
if (_ox > 0) {
    draw_rectangle(0, 0, _ox - 1, display_get_gui_height(), false);
    draw_rectangle(display_get_gui_width() - _ox, 0, display_get_gui_width(), display_get_gui_height(), false);
}
if (_oy > 0) {
    draw_rectangle(0, 0, display_get_gui_width(), _oy - 1, false);
    draw_rectangle(0, display_get_gui_height() - _oy, display_get_gui_width(), display_get_gui_height(), false);
}

// Transform: scale and offset
var _prev_matrix = matrix_get(matrix_world);
var _mat = matrix_build(_ox, _oy, 0, 0, 0, 0, _sx, _sx, 1);
matrix_set(matrix_world, _mat);

// Draw panels at base resolution — scaling is handled by the matrix
choose_panel.draw();
place_panel.draw();

// Restore
matrix_set(matrix_world, _prev_matrix);