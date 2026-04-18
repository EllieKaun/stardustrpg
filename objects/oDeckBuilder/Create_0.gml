/// obj_card_menu — Create Event
display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));
ui_scaling_init();

// Track which panel has focus: 0 = choose, 1 = place
active_panel = 0;

// --- Helper: panel switch callback ---
panel_switch_callback = function(_panel, _dir) {
    with (oDeckBuilder) {
        if (_dir > 0 && active_panel == 0) {
            choose_panel.focused = false;
            place_panel.focused = true;
            active_panel = 1;
        } else if (_dir < 0 && active_panel == 1) {
            place_panel.focused = false;
            choose_panel.focused = true;
            active_panel = 0;
        }
    }
};

// --- Build the chooseCardPanel (left side) ---
var _choose_slots = [];
for (var _i = 0; _i < 12; _i++) {
    if (_i < 3) {
        array_push(_choose_slots, new Slot("filled", new Card(
            "Potion", "common", "self", "magic", 2, [],
            atcCard, bleedGroup, epicBorder, hpCostToken
        )));
    } else {
        array_push(_choose_slots, new Slot("locked"));
    }
}

choose_panel = new Panel({
    x: 8,
    y: 8,
    w: camera_get_view_width(view_camera[0]) / 2 - 16,
    h: camera_get_view_height(view_camera[0]) - 16,
    bg_sprite: sprCardDeskFull,
    slot_sprite_empty: EmptyCardPlace,
    slot_sprite_locked: LockedCardPlace,
    select_sprite: sprCardAttaclBase,
    tabs: [
        { name: "LANA", color: #4488CC },
        { name: "VIV",  color: #44CC88 }
    ],
    cols: 4,
    rows: 3,
    tab_h: 20,
    padding: 8,
    slot_gap: 2,
    slots: _choose_slots,
    on_slot_click: function(_panel, _index) {
        show_debug_message("Choose panel slot clicked: " + string(_index));
    },
    on_tab_click: function(_panel, _tab_index) {
        show_debug_message("Tab switched: " + string(_tab_index));
    },
    on_panel_switch: panel_switch_callback
});

// --- Build the placePanel (right side) ---
var _place_slots = [];
for (var _i = 0; _i < 16; _i++) {
    if (_i < 8) {
        array_push(_place_slots, new Slot("empty"));
    } else {
        array_push(_place_slots, new Slot("locked"));
    }
}

place_panel = new Panel({
    x: 8 + camera_get_view_width(view_camera[0]) / 2,
    y: 8,
    w: camera_get_view_width(view_camera[0]) / 2 - 16,
    h: camera_get_view_height(view_camera[0]) - 16,
    bg_sprite: sprCardDeskFull,
    slot_sprite_empty: EmptyCardPlace,
    slot_sprite_locked: LockedCardPlace,
    select_sprite: sprCardAttaclBase,
    tabs: [
        { name: "MAGIC",  color: #9944CC },
        { name: "BUFF",   color: #CC44CC },
        { name: "HEAL",   color: #44CC44 },
        { name: "ATTACK", color: #CC4444 }
    ],
    cols: 4,
    rows: 3,
    visible_rows: 3,
    tab_h: 20,
    padding: 8,
    slot_gap: 2,
    slots: _place_slots,
    on_slot_click: function(_panel, _index) {
        show_debug_message("Place panel slot clicked: " + string(_index));
    },
    on_tab_click: function(_panel, _tab_index) {
        show_debug_message("Category tab: " + string(_tab_index));
    },
    on_panel_switch: panel_switch_callback
});

// Start with choose_panel focused
choose_panel.focused = true;
place_panel.focused  = false;