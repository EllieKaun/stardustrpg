/// oDeckBuilder :: Create

display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));

var _camW = camera_get_view_width(view_camera[0]);
var _camH = camera_get_view_height(view_camera[0]);

var _margin   = 8;
var _tabH     = 18;
var _panelW   = (_camW - _margin * 2) / 2;   // two adjacent halves, no gap
var _panelTop = _margin + _tabH;             // room ABOVE for the tab row
var _panelH   = _camH - _panelTop - _margin;

activePanel = 0; // 0 = choose, 1 = place (independent of screen side)

var _tabFonts = [fnM3x6_22, fnM3x6_14, fnM3x6_13, fnM3x6_12,
                 fnM3x6_11, fnM3x6_10, fnM3x6_9,  fnM3x6_8, fnM3x6_7];

// Focus handoff: enter the target from the edge facing the source panel.
switchFocusTo = function(_target, _row) {
    with (oDeckBuilder) {
        var _src = (_target.tag == "choose") ? placePanel : choosePanel;
        choosePanel.focused = (_target.tag == "choose");
        placePanel.focused  = (_target.tag == "place");
        activePanel = (_target.tag == "choose") ? 0 : 1;
        if (_target.x < _src.x) _target.enterFromRight(_row);
        else                    _target.enterFromLeft(_row);
    }
};

// Edge-of-grid switch (left/right past the border).
panelSwitchCallback = function(_panel, _dir) {
    with (oDeckBuilder) {
        var _other = (_panel.tag == "choose") ? placePanel : choosePanel;
        if ((_dir > 0 && _panel.x < _other.x) || (_dir < 0 && _panel.x > _other.x)) {
            switchFocusTo(_other, _panel.cursorRow);
        }
    }
};

editingCharacter = Characters.Lana;   // which deck the place panel edits

var _categoryForTab = function(_t) {
    switch (_t) {
        case 0: return sprCardSelected.Magic;
        case 1: return CardCategory.Buff;
        case 2: return CardCategory.Heal;
        case 3: return CardCategory.Attack;
        default: return undefined;
    }
};

// ---- choosePanel (LEFT): the collection ----
choosePanel = new Panel({
    x: _margin, y: _panelTop, w: _panelW, h: _panelH,
    bgSprite: sprCardDeskFull,
    slotSpriteEmpty: EmptyCardPlace,
    slotSpriteLocked: LockedCardPlace,
    selectSprite: sprCardSelected,
    pointerSprite: sPointer,
    tabFonts: _tabFonts,
    tabs: [
        { name: "MAGIC",  color: #9944CC },
        { name: "BUFF",   color: #CC44CC },
        { name: "HEAL",   color: #44CC44 },
        { name: "ATTACK", color: #CC4444 }
    ],
    visibleRows: 3, tabH: _tabH, padding: 8,
    slots: buildCollectionSlots(CardCategory.Magic),   // start on first tab
    onTabClick: function(_panel, _tabIndex) {
        with (oDeckBuilder) {
            var _cat = _categoryForTab(_tabIndex);
            _panel.slots    = buildCollectionSlots(_cat);
            _panel.scrollRow = 0;
            _panel.refreshScroll();
        }
    },
    onSlotClick: function(_panel, _index) {
        // Picked a card -> keep it highlighted, jump to the deck panel.
        with (oDeckBuilder) switchFocusTo(placePanel, choosePanel.cursorRow);
    },
    onPanelSwitch: panelSwitchCallback
});
choosePanel.tag = "choose";

// ---- placePanel (RIGHT): the character's deck ----
placePanel = new Panel({
    x: _margin + _panelW, y: _panelTop, w: _panelW, h: _panelH,
    bgSprite: sprCardDeskFull,
    slotSpriteEmpty: EmptyCardPlace,
    slotSpriteLocked: LockedCardPlace,
    selectSprite: sprCardSelected,
    pointerSprite: sPointer,
    tabFonts: _tabFonts,
    tabs: [
        { name: "LANA", color: #4488CC },
        { name: "VIV",  color: #44CC88 }
    ],
    visibleRows: 3, tabH: _tabH, padding: 8,
    slots: buildDeckSlots(Characters.Lana),
    onTabClick: function(_panel, _tabIndex) {
        with (oDeckBuilder) {
            editingCharacter = (_tabIndex == 0) ? Characters.Lana : Characters.Viv;
            _panel.slots     = buildDeckSlots(editingCharacter);
            _panel.scrollRow = 0;
            _panel.refreshScroll();
        }
    },
    onSlotClick: function(_panel, _index) {
        with (oDeckBuilder) {
            if (choosePanel.selectedSlot < 0) return;
            var _src = choosePanel.slots[choosePanel.selectedSlot];
            if (_src.state == "filled") {
                // setDeckSlot rejects locked/out-of-range slots itself.
                if (setDeckSlot(editingCharacter, _index, cardToRef(_src.card))) {
                    _panel.slots = buildDeckSlots(editingCharacter);
                    playerDataSave();
                }
            }
        }
    },
    onPanelSwitch: panelSwitchCallback
});
placePanel.tag = "place";

// Start focused on the collection.
choosePanel.focused = true;
placePanel.focused  = false;
choosePanel.enterFromLeft(0);
activePanel = 0;