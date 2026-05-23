display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));

var _camW = camera_get_view_width(view_camera[0]);
var _camH = camera_get_view_height(view_camera[0]);

// Layout: two panels side by side with NO gap between their backgrounds.
var _margin    = 8;
var _tabH      = 18;
var _panelW    = (_camW - _margin * 2) / 2;   // each half of the inner area
var _panelTop  = _margin + _tabH;             // leave room ABOVE for the tab row
var _panelH    = _camH - _panelTop - _margin;

// Track which panel has focus: 0 = choose, 1 = place
activePanel = 0;

// --- Panel switch callback ---
panelSwitchCallback = function(_panel, _dir) {
    with (oDeckBuilder) {
        if (_dir > 0 && activePanel == 0) {
            choosePanel.focused = false;
            placePanel.focused  = true;
            activePanel = 1;
            placePanel.enterFromLeft(choosePanel.cursorRow);
        } else if (_dir < 0 && activePanel == 1) {
            placePanel.focused  = false;
            choosePanel.focused = true;
            activePanel = 0;
            choosePanel.enterFromRight(placePanel.cursorRow);
        }
    }
};

// --- chooseCardPanel (left) ---
var _chooseSlots = [];
for (var _i = 0; _i < 12; _i++) {
    if (_i < 3) {
        array_push(_chooseSlots, new Slot("filled", new Card(
            "Potion", "common", "self", "magic", 2, [],
            atcCard, bleedGroup, epicBorder, hpCostToken
        )));
    } else {
        array_push(_chooseSlots, new Slot("locked"));
    }
}

choosePanel = new Panel({
    x: _margin,
    y: _panelTop,
    w: _panelW,
    h: _panelH,
    bgSprite:         sprCardDeskFull,
    slotSpriteEmpty:  EmptyCardPlace,
    slotSpriteLocked: LockedCardPlace,
    selectSprite:     sprCardSelected,
    pointerSprite:    sPointer,
    tabs: [
        { name: "LANA", color: #4488CC },
        { name: "VIV",  color: #44CC88 }
    ],
    visibleRows: 3,
    tabH:    _tabH,
    padding: 8,
    slots:   _chooseSlots,
    onSlotClick: function(_panel, _index) {
        show_debug_message("Choose panel slot clicked: " + string(_index));
    },
    onTabClick: function(_panel, _tabIndex) {
        show_debug_message("Tab switched: " + string(_tabIndex));
    },
    onPanelSwitch: panelSwitchCallback
});

// --- placePanel (right) — adjacent, no gap ---
var _placeSlots = [];
for (var _i = 0; _i < 16; _i++) {
    if (_i < 8) {
        array_push(_placeSlots, new Slot("empty"));
    } else {
        array_push(_placeSlots, new Slot("locked"));
    }
}

placePanel = new Panel({
    x: _margin + _panelW,   // starts exactly where choosePanel ends
    y: _panelTop,
    w: _panelW,
    h: _panelH,
    bgSprite:         sprCardDeskFull,
    slotSpriteEmpty:  EmptyCardPlace,
    slotSpriteLocked: LockedCardPlace,
    selectSprite:     sprCardSelected,
    pointerSprite:    sPointer,
    tabs: [
        { name: "MAGIC",  color: #9944CC },
        { name: "BUFF",   color: #CC44CC },
        { name: "HEAL",   color: #44CC44 },
        { name: "ATTACK", color: #CC4444 }
    ],
    visibleRows: 3,
    tabH:    _tabH,
    padding: 8,
    slots:   _placeSlots,
    onSlotClick: function(_panel, _index) {
        show_debug_message("Place panel slot clicked: " + string(_index));
    },
    onTabClick: function(_panel, _tabIndex) {
        show_debug_message("Category tab: " + string(_tabIndex));
    },
    onPanelSwitch: panelSwitchCallback
});

// Start with choosePanel focused and a slot already selected.
choosePanel.focused = true;
placePanel.focused  = false;
choosePanel.enterFromLeft(0);
