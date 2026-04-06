/// scr_ui_scaling

function ui_scaling_init() {
    // Your design resolution — author everything at this size
    global.BASE_W = 640;
    global.BASE_H = 360;
    global.BASE_ASPECT = global.BASE_W / global.BASE_H;
    
    ui_scaling_refresh();
}

function ui_scaling_refresh() {
    var _ww = window_get_width();
    var _wh = window_get_height();
    var _window_aspect = _ww / _wh;
    
    if (_window_aspect > global.BASE_ASPECT) {
        global.UI_SCALE = _wh / global.BASE_H;
        global.UI_OFFSET_X = floor((_ww - (global.BASE_W * global.UI_SCALE)) / 2);
        global.UI_OFFSET_Y = 0;
    } else {
        global.UI_SCALE = _ww / global.BASE_W;
        global.UI_OFFSET_X = 0;
        global.UI_OFFSET_Y = floor((_wh - (global.BASE_H * global.UI_SCALE)) / 2);
    }
}

/// Convert window mouse to base-resolution coords
function ui_mouse_x() {
    return (device_mouse_x_to_gui(0) - global.UI_OFFSET_X) / global.UI_SCALE;
}

function ui_mouse_y() {
    return (device_mouse_y_to_gui(0) - global.UI_OFFSET_Y) / global.UI_SCALE;
}

/// @function Slot(state, card)
/// @param {string} _state   "empty" | "locked" | "filled"
/// @param {struct} _card    Card struct or undefined
function Slot(_state, _card = undefined) constructor {
    state = _state;       // "empty", "locked", "filled"
    card = _card;         // Card struct or undefined
    selected = false;
}

/// @function Panel(config)
/// @param {struct} config
///   .x, .y              — top-left position (base coords)
///   .w, .h              — panel size (base coords)
///   .bg_sprite          — sprite index for background (will be stretched)
///   .slot_sprite_empty  — sprite for empty slot
///   .slot_sprite_locked — sprite for locked slot (with padlock)
///   .select_sprite      — sprite for yellow selection highlight
///   .tabs               — array of { name, color, sprite (optional) }
///   .cols               — number of columns in grid
///   .rows               — number of rows in grid
///   .slots              — array of Slot structs (length = cols * rows)
///   .padding            — inner padding from panel edge to grid
///   .slot_gap           — gap between slots
///   .tab_h              — height of the tab row
///   .on_slot_click      — function(panel, slot_index) — callback when a slot is clicked
///   .on_tab_click       — function(panel, tab_index) — callback when a tab is clicked

function Panel(_config) constructor {
    x = _config[$ "x"] ?? 0;
    y = _config[$ "y"] ?? 0;
    w = _config[$ "w"] ?? 200;
    h = _config[$ "h"] ?? 200;
    
    bg_sprite          = _config[$ "bg_sprite"];
    slot_sprite_empty  = _config[$ "slot_sprite_empty"];
    slot_sprite_locked = _config[$ "slot_sprite_locked"];
    select_sprite      = _config[$ "select_sprite"];
    
    tabs       = _config[$ "tabs"] ?? [];
    active_tab = 0;
    
    cols     = _config[$ "cols"] ?? 4;
    rows     = _config[$ "rows"] ?? 3;
    slots    = _config[$ "slots"] ?? [];
    padding  = _config[$ "padding"] ?? 8;
    slot_gap = _config[$ "slot_gap"] ?? 2;
    tab_h    = _config[$ "tab_h"] ?? 20;
    
    on_slot_click = _config[$ "on_slot_click"] ?? undefined;
    on_tab_click  = _config[$ "on_tab_click"] ?? undefined;
    
    selected_slot = -1;
    visible_rows = _config[$ "visible_rows"] ?? rows;  // how many rows to SHOW
    scroll_row   = 0;                                    // first visible row (0-based)
    total_rows   = ceil(array_length(slots) / cols);     // 
    
    static refresh_scroll = function() {
        total_rows = ceil(array_length(slots) / cols);
        scroll_row = clamp(scroll_row, 0, max(0, total_rows - visible_rows));
    };
    
    
    
    /// @function get_slot_rect(index)
    /// @description Returns {sx, sy, sw, sh} for a slot by grid index
    static get_slot_rect = function(_index) {
        var _col = _index mod cols;
        var _row = _index div cols;
    
        // Offset by scroll
        var _visible_row = _row - scroll_row;
    
        var _grid_x = x + padding;
        var _grid_y = y + padding + tab_h;
        var _grid_w = w - padding * 2;
        var _grid_h = h - padding * 2 - tab_h;
    
        // Size slots based on visible_rows, not total_rows
        var _sw = (_grid_w - (cols - 1) * slot_gap) / cols;
        var _sh = (_grid_h - (visible_rows - 1) * slot_gap) / visible_rows;
        var _sx = _grid_x + _col * (_sw + slot_gap);
        var _sy = _grid_y + _visible_row * (_sh + slot_gap);
    
        return { sx: _sx, sy: _sy, sw: _sw, sh: _sh };
    };
    
    /// @function get_tab_rect(index)
    static get_tab_rect = function(_index) {
        var _tab_count = array_length(tabs);
        if (_tab_count == 0) return { tx: 0, ty: 0, tw: 0, th: 0 };
        
        var _tw = (w - padding * 2) / _tab_count;
        var _tx = x + padding + _index * _tw;
        var _ty = y + padding;
        
        return { tx: _tx, ty: _ty, tw: _tw, th: tab_h };
    };
    
    /// @function step()
    /// @description Call in Step event — handles click detection
    static step = function() {
        if (!mouse_check_button_pressed(mb_left)) return;
        
        var _mx = ui_mouse_x();
        var _my = ui_mouse_y();
        
        // Check tab clicks
        for (var _t = 0; _t < array_length(tabs); _t++) {
            var _tr = get_tab_rect(_t);
            if (point_in_rectangle(_mx, _my, _tr.tx, _tr.ty, _tr.tx + _tr.tw, _tr.ty + _tr.th)) {
                active_tab = _t;
                if (on_tab_click != undefined) on_tab_click(self, _t);
                return;
            }
        }
        
        // Check slot clicks
        var _count = min(array_length(slots), cols * rows);
        for (var _i = 0; _i < _count; _i++) {
            var _r = get_slot_rect(_i);
            if (point_in_rectangle(_mx, _my, _r.sx, _r.sy, _r.sx + _r.sw, _r.sy + _r.sh)) {
                var _slot = slots[_i];
                if (_slot.state != "locked") {
                    selected_slot = _i;
                    if (on_slot_click != undefined) on_slot_click(self, _i);
                }
                return;
            }
        }
    };
    
    /// @function draw()
    /// @description Call in Draw GUI event
    static draw = function() {
        // --- Background sprite (stretched to panel size) ---
        if (bg_sprite != undefined) {
            var _spr_w = sprite_get_width(bg_sprite);
            var _spr_h = sprite_get_height(bg_sprite);
            draw_sprite_stretched(bg_sprite, 0, x, y, w, h);
        }
        
        // --- Tabs ---
        for (var _t = 0; _t < array_length(tabs); _t++) {
            var _tab = tabs[_t];
            var _tr = get_tab_rect(_t);
            var _is_active = (_t == active_tab);
            
            // Tab background — use tab sprite if available, else colored rect
            if (_tab[$ "sprite"] != undefined) {
                draw_sprite_stretched(_tab.sprite, _is_active ? 1 : 0,
                    _tr.tx, _tr.ty, _tr.tw, _tr.th);
            } else {
                draw_set_color(_tab[$ "color"] ?? c_gray);
                draw_set_alpha(_is_active ? 1.0 : 0.6);
                draw_rectangle(_tr.tx, _tr.ty, _tr.tx + _tr.tw - 1, _tr.ty + _tr.th - 1, false);
                draw_set_alpha(1.0);
            }
            
            // Tab label
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(_tr.tx + _tr.tw / 2, _tr.ty + _tr.th / 2, _tab.name);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        
        // --- Slots ---
       // --- Slots (only visible rows) ---
    var _first = scroll_row * cols;
    var _last  = min(_first + visible_rows * cols, array_length(slots));
    for (var _i = _first; _i < _last; _i++) {
        var _slot = slots[_i];
        var _r = get_slot_rect(_i);
    
        switch (_slot.state) {
            case "locked":
                if (slot_sprite_locked != undefined)
                    draw_sprite_stretched(slot_sprite_locked, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                break;
            case "empty":
                if (slot_sprite_empty != undefined)
                    draw_sprite_stretched(slot_sprite_empty, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                break;
            case "filled":
                if (slot_sprite_empty != undefined)
                    draw_sprite_stretched(slot_sprite_empty, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                if (_slot.card != undefined)
                    draw_card(_slot.card, _r.sx, _r.sy, _r.sw, _r.sh);
                break;
        }
    
        // Selection highlight
        if (_i == selected_slot && select_sprite != undefined) {
            draw_sprite_stretched(select_sprite, 0,
                _r.sx - 1, _r.sy - 1, _r.sw + 2, _r.sh + 2);
        }
    }
    
    // --- Optional: scroll indicator ---
    if (total_rows > visible_rows) {
        var _bar_x = x + w - padding;
        var _bar_y = y + padding + tab_h;
        var _bar_h = h - padding * 2 - tab_h;
        var _thumb_h = _bar_h * (visible_rows / total_rows);
        var _thumb_y = _bar_y + (_bar_h - _thumb_h) * (scroll_row / max(1, total_rows - visible_rows));
    
        draw_set_color(c_dkgray);
        draw_set_alpha(0.4);
        draw_rectangle(_bar_x, _bar_y, _bar_x + 4, _bar_y + _bar_h, false);
        draw_set_color(c_white);
        draw_set_alpha(0.8);
        draw_rectangle(_bar_x, _thumb_y, _bar_x + 4, _thumb_y + _thumb_h, false);
        draw_set_alpha(1.0);
    }
    };
}

/// @function draw_card(card, x, y, w, h)
/// @description Draws a card's layered sprites scaled into the given rect
function draw_card(_card, _x, _y, _w, _h) {
    // Base layer
    if (_card.cardBaseSpr != undefined) {
        draw_sprite_stretched(_card.cardBaseSpr, 0, _x, _y, _w, _h);
    }
    
    // Illustration (inset a bit)
    if (_card.cardIllustrationSpr != undefined) {
        var _inset = _w * 0.1;
        draw_sprite_stretched(_card.cardIllustrationSpr, 0,
            _x + _inset, _y + _inset,
            _w - _inset * 2, _h * 0.5);
    }
    
    // Border overlay
    if (_card.cardBorderSpr != undefined) {
        draw_sprite_stretched(_card.cardBorderSpr, 0, _x, _y, _w, _h);
    }
    
    // Token icon (top-right corner)
    if (_card.cardTokenSpr != undefined) {
        var _token_size = _w * 0.25;
        draw_sprite_stretched(_card.cardTokenSpr, 0,
            _x + _w - _token_size - 2, _y + 2,
            _token_size, _token_size);
    }
    
    // Energy cost (top-left)
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_text(_x + 3, _y + 3, string(_card.energy));
    
    // Name (bottom)
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_text(_x + _w / 2, _y + _h - 3, _card.name);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

