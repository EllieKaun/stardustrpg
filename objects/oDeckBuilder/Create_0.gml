/// obj_card_menu — Create Event


// --- Build the chooseCardPanel (left side) ---
// Dynamic slot count: 3 cols x 3 rows = 9 slots, some locked
var _choose_slots = [];
for (var _i = 0; _i < 12; _i++) {
    if (_i < 3) {
        // First row: filled with cards
        array_push(_choose_slots, new Slot("filled", new Card(
            "Potion", "common", "self", "magic", 2, [],
            sprCardAttaclBase, sprCardAttaclBase, sprCardAttaclBase, sprCardAttaclBase
        )));
    } else {
        // Remaining: locked
        array_push(_choose_slots, new Slot("locked"));
    }
}

choose_panel = new Panel({
    x: 8,
    y: 8,
    w: 304,
    h: 344,
    bg_sprite: sprCardDeskFull,            // <-- your panel background sprite
    slot_sprite_empty: sprCardAttaclBase,
    slot_sprite_locked: sprCardAttaclBase,
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
        // Your logic: pick this card to place
    },
    on_tab_click: function(_panel, _tab_index) {
        show_debug_message("Tab switched: " + string(_tab_index));
        // Your logic: swap slot contents to show different character's cards
    }
});

// --- Build the placeCardPanel (right side) ---
// Fixed 4x4 = 16 slots, some empty, some locked
var _place_slots = [];
for (var _i = 0; _i < 16; _i++) {
    if (_i < 8) {
        array_push(_place_slots, new Slot("empty"));
    } else {
        array_push(_place_slots, new Slot("locked"));
    }
}

place_panel = new Panel({
    x: 320,
    y: 8,
    w: 312,
    h: 344,
    bg_sprite: sprCardDeskFull,
    slot_sprite_empty: sprCardAttaclBase,
    slot_sprite_locked: sprCardAttaclBase,
    select_sprite: sprCardAttaclBase,
    tabs: [
        { name: "MAGIC",  color: #9944CC },
        { name: "BUFF",   color: #CC44CC },
        { name: "HEAL",   color: #44CC44 },
        { name: "ATTACK", color: #CC4444 }
    ],
    cols: 4,
    rows: 4,
    tab_h: 20,
    padding: 8,
    slot_gap: 2,
    slots: _place_slots,
    on_slot_click: function(_panel, _index) {
        show_debug_message("Place panel slot clicked: " + string(_index));
        // Your logic: place currently selected card here
    },
    on_tab_click: function(_panel, _tab_index) {
        show_debug_message("Category tab: " + string(_tab_index));
        // Your logic: filter cards by type
    }
});