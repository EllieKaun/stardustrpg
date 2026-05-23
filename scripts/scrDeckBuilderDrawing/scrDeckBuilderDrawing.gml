/// @function Slot(state, card)
/// @param {string} _state   "empty" | "locked" | "filled"
/// @param {struct} _card    Card struct or undefined
function Slot(_state, _card = undefined) constructor {
    state    = _state;       // "empty", "locked", "filled"
    card     = _card;        // Card struct or undefined
    selected = false;
}

/// @function Panel(config)
/// Config keys (camelCase):
///   x, y, w, h            — background panel rect (base coords)
///   bgSprite              — stretched background sprite
///   slotSpriteEmpty       — empty slot sprite
///   slotSpriteLocked      — locked slot sprite (padlock)
///   selectSprite          — highlight sprite for the selected slot
///   pointerSprite         — sPointer sprite drawn at the selected slot
///   tabs                  — array of { name, color, sprite (optional) }
///   visibleRows           — how many rows are shown (rest scroll)
///   slots                 — array of Slot structs
///   padding               — inner padding (panel edge -> grid)
///   tabH                  — height of the tab row (drawn ABOVE the bg)
///   tabGap, tabPadding, tabMinW — tab layout tuning
///   onSlotClick(panel, i) / onTabClick(panel, i) / onPanelSwitch(panel, dir)
function Panel(_config) constructor {
    x = _config[$ "x"] ?? 0;
    y = _config[$ "y"] ?? 0;
    w = _config[$ "w"] ?? 200;
    h = _config[$ "h"] ?? 200;

    bgSprite = _config[$ "bgSprite"];
    slotSpriteEmpty = _config[$ "slotSpriteEmpty"];
    slotSpriteLocked = _config[$ "slotSpriteLocked"];
    selectSprite = _config[$ "selectSprite"];
    pointerSprite = _config[$ "pointerSprite"];

    tabs = _config[$ "tabs"] ?? [];
    activeTab = 0;

    // Columns are ALWAYS 4 — only the spacing adapts.
    cols = 4;
    cardRatio = 2 / 3;                              // width / height (portrait)
    slots = _config[$ "slots"] ?? [];
    padding = _config[$ "padding"] ?? 8;
    tabH = _config[$ "tabH"] ?? 18;
    tabGap = _config[$ "tabGap"] ?? 2;
    tabPadding = _config[$ "tabPadding"] ?? 6;
    tabMinW = _config[$ "tabMinW"] ?? 0;

    onSlotClick = _config[$ "onSlotClick"] ?? undefined;
    onTabClick = _config[$ "onTabClick"] ?? undefined;
    onPanelSwitch = _config[$ "onPanelSwitch"] ?? undefined;

    visibleRows = _config[$ "visibleRows"] ?? ceil(array_length(slots) / cols);
    visibleRows = max(1, visibleRows);
    scrollRow = 0;
    totalRows = ceil(array_length(slots) / cols);

    cursorCol = 0;
    cursorRow = 0;
    selectedSlot = -1;
    focused = false;

    static refreshScroll = function() {
        totalRows = ceil(array_length(slots) / cols);
        scrollRow = clamp(scrollRow, 0, max(0, totalRows - visibleRows));
    };

    /// @function computeLayout()
    /// Solves for a uniform gap so 2:3 cards fill the grid across 4 columns.
   static computeLayout = function() {

    var _gridX = x + padding;
    var _gridY = y + padding;

    var _gridW = w - padding * 2;
    var _gridH = h - padding * 2;

    var _rows = max(1, visibleRows);

    var _ratio = 2 / 3;

    var _minGap = 4;

    // Сколько места минимум займут gap
    var _reservedW = _minGap * (cols + 1);
    var _reservedH = _minGap * (_rows + 1);

    // Размер карты по ширине
    var _cw = (_gridW - _reservedW) / cols;
    var _ch = _cw / _ratio;

    // Если по высоте не влезает —
    // пересчитываем от высоты
    if (_ch * _rows > (_gridH - _reservedH)) {

        _ch = (_gridH - _reservedH) / _rows;
        _cw = _ch * _ratio;
    }

    // Остаток пространства
    var _freeW = _gridW - (_cw * cols);
    var _freeH = _gridH - (_ch * _rows);

    // Реальные gap
    var _gapX = max(_minGap, _freeW / (cols + 1));
    var _gapY = max(_minGap, _freeH / (_rows + 1));

    return {
        gridX : _gridX,
        gridY : _gridY,

        cw : _cw,
        ch : _ch,

        gapX : _gapX,
        gapY : _gapY
    };
};

    /// @function getSlotRect(index)
    static getSlotRect = function(_index) {
        var _lay    = computeLayout();
        var _col    = _index mod cols;
        var _row    = _index div cols;
        var _visRow = _row - scrollRow;

        var _sx = _lay.gridX + _lay.gapX + _col    * (_lay.cw + _lay.gapX);
        var _sy = _lay.gridY + _lay.gapY + _visRow * (_lay.ch + _lay.gapY);

        return { sx: _sx, sy: _sy, sw: _lay.cw, sh: _lay.ch };
    };

    /// @function tabWidth(index) — content sized
    static tabWidth = function(_index) {
        var _name = tabs[_index].name;
        return max(tabMinW, string_width(_name) + tabPadding * 2);
    };

    /// @function getTabRect(index) — tabs sit ABOVE the background panel
    static getTabRect = function(_index) {
        var _tx = x;
        for (var _i = 0; _i < _index; _i++) {
            _tx += tabWidth(_i) + tabGap;
        }
        return { tx: _tx, ty: y - tabH, tw: tabWidth(_index), th: tabH };
    };

    // ----- Focus entry helpers (fixes panel-switch cursor bugs) -----
    static selectAtCursor = function() {
        var _slotsInRow = array_length(slots) - cursorRow * cols;
        if (_slotsInRow <= 0) {
            cursorRow   = max(0, totalRows - 1);
            _slotsInRow = array_length(slots) - cursorRow * cols;
        }
        cursorCol    = clamp(cursorCol, 0, max(0, _slotsInRow - 1));
        selectedSlot = cursorRow * cols + cursorCol;

        if (cursorRow < scrollRow) scrollRow = cursorRow;
        else if (cursorRow >= scrollRow + visibleRows) scrollRow = cursorRow - visibleRows + 1;
        refreshScroll();
    };

    static enterFromLeft = function(_row) {
        cursorCol = 0;
        cursorRow = clamp(_row, 0, max(0, totalRows - 1));
        selectAtCursor();
    };

    static enterFromRight = function(_row) {
        cursorCol = cols - 1;
        cursorRow = clamp(_row, 0, max(0, totalRows - 1));
        selectAtCursor();
    };

    // ----- Update -----
    static step = function() {
        if (!focused) return;
        stepKeyboard();
    };

    static stepKeyboard = function() {
        var _dx = 0, _dy = 0, _moved = false;

        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) { _dy = -1; _moved = true; }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) { _dy =  1; _moved = true; }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) { _dx = -1; _moved = true; }
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) { _dx =  1; _moved = true; }

        if (_moved) {
            // Make sure there is a valid cursor before moving.
            if (selectedSlot < 0) { cursorCol = 0; cursorRow = 0; selectAtCursor(); }

            var _newCol = cursorCol + _dx;
            var _newRow = cursorRow + _dy;

            // Horizontal edges -> ask parent to switch panels.
            if (_newCol < 0) {
                if (onPanelSwitch != undefined) onPanelSwitch(self, -1);
                return;
            }
            if (_newCol >= cols) {
                if (onPanelSwitch != undefined) onPanelSwitch(self, 1);
                return;
            }

            // Clamp to existing rows.
            _newRow = clamp(_newRow, 0, max(0, totalRows - 1));

            // Clamp column into the slots that actually exist on this row
            // (fixes selecting empty cells on a partial last row).
            var _slotsInRow = array_length(slots) - _newRow * cols;
            if (_slotsInRow <= 0) return;
            _newCol = clamp(_newCol, 0, _slotsInRow - 1);

            cursorCol    = _newCol;
            cursorRow    = _newRow;
            selectedSlot = cursorRow * cols + cursorCol;

            // Keep selection on screen.
            if (cursorRow < scrollRow) scrollRow = cursorRow;
            else if (cursorRow >= scrollRow + visibleRows) scrollRow = cursorRow - visibleRows + 1;
            refreshScroll();
        }

        // Confirm
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            if (selectedSlot >= 0 && selectedSlot < array_length(slots)) {
                var _slot = slots[selectedSlot];
                if (_slot.state != "locked" && onSlotClick != undefined) {
                    onSlotClick(self, selectedSlot);
                }
            }
        }

        // Tab switching with Q / E
        if (array_length(tabs) > 0) {
            if (keyboard_check_pressed(ord("Q"))) {
                activeTab = max(0, activeTab - 1);
                if (onTabClick != undefined) onTabClick(self, activeTab);
            }
            if (keyboard_check_pressed(ord("E"))) {
                activeTab = min(array_length(tabs) - 1, activeTab + 1);
                if (onTabClick != undefined) onTabClick(self, activeTab);
            }
        }
    };

    // ----- Draw (call in Draw GUI) -----
    static draw = function() {
        // --- Background panel ---
        if (bgSprite != undefined) {
            draw_sprite_stretched(bgSprite, 0, x, y, w, h);
        }

        // --- Slots (only visible rows) ---
        var _first = scrollRow * cols;
        var _last  = min(_first + visibleRows * cols, array_length(slots));

        for (var _i = _first; _i < _last; _i++) {
            var _slot = slots[_i];
            var _r    = getSlotRect(_i);

            switch (_slot.state) {
                case "locked":
                    if (slotSpriteLocked != undefined)
                        draw_sprite_stretched(slotSpriteLocked, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                    break;
                case "empty":
                    if (slotSpriteEmpty != undefined)
                        draw_sprite_stretched(slotSpriteEmpty, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                    break;
                case "filled":
                    if (slotSpriteEmpty != undefined)
                        draw_sprite_stretched(slotSpriteEmpty, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                    if (_slot.card != undefined)
                        drawCard(_slot.card, _r.sx, _r.sy, _r.sw, _r.sh);
                    break;
            }
        }

        // --- Selection highlight + pointer (no glow, static) ---
        if (selectedSlot >= _first && selectedSlot < _last) {
            var _sr = getSlotRect(selectedSlot);

            if (selectSprite != undefined) {
                draw_sprite_stretched(selectSprite, 0,
                    _sr.sx - 2, _sr.sy - 2, _sr.sw + 4, _sr.sh + 4);
            }

            if (pointerSprite != undefined) {
                var _ph    = _sr.sh * 0.45;
                var _scale = _ph / sprite_get_height(pointerSprite);
                var _px    = _sr.sx + _sr.sw * 0.10;
                var _py    = _sr.sy + (_sr.sh - _ph) / 2;
                draw_sprite_ext(pointerSprite, 0, _px, _py, _scale, _scale, 0, c_white, 1);
            }
        }

        // --- Tabs (drawn ABOVE the background panel) ---
        for (var _t = 0; _t < array_length(tabs); _t++) {
            var _tab      = tabs[_t];
            var _tr       = getTabRect(_t);
            var _isActive = (_t == activeTab);

            if (_tab[$ "sprite"] != undefined) {
                draw_sprite_stretched(_tab.sprite, _isActive ? 1 : 0,
                    _tr.tx, _tr.ty, _tr.tw, _tr.th);
            } else {
                draw_set_color(_tab[$ "color"] ?? c_gray);
                draw_set_alpha(_isActive ? 1.0 : 0.6);
                draw_rectangle(_tr.tx, _tr.ty, _tr.tx + _tr.tw - 1, _tr.ty + _tr.th - 1, false);
                draw_set_alpha(1.0);
            }

            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(_tr.tx + _tr.tw / 2, _tr.ty + _tr.th / 2, _tab.name);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        // --- Scroll indicator (along right inner edge) ---
        if (totalRows > visibleRows) {
            var _barX   = x + w - padding;
            var _barY   = y + padding;
            var _barH   = h - padding * 2;
            var _thumbH = _barH * (visibleRows / totalRows);
            var _thumbY = _barY + (_barH - _thumbH) * (scrollRow / max(1, totalRows - visibleRows));

            draw_set_color(c_dkgray);
            draw_set_alpha(0.4);
            draw_rectangle(_barX, _barY, _barX + 4, _barY + _barH, false);
            draw_set_color(c_white);
            draw_set_alpha(0.8);
            draw_rectangle(_barX, _thumbY, _barX + 4, _thumbY + _thumbH, false);
            draw_set_alpha(1.0);
        }
    };
}

/// @function drawCard(card, x, y, w, h)
function drawCard(_card, _x, _y, _w, _h) {
    if (_card.cardBaseSpr != undefined) {
        draw_sprite_stretched(_card.cardBaseSpr, 0, _x, _y, _w, _h);
    }

    if (_card.cardIllustrationSpr != undefined) {
        var _inset = _w * 0.1;
        draw_sprite_stretched(_card.cardIllustrationSpr, 0,
            _x + _inset, _y + _inset,
            _w - _inset * 2, _h * 0.5);
    }

    if (_card.cardBorderSpr != undefined) {
        draw_sprite_stretched(_card.cardBorderSpr, 0, _x, _y, _w, _h);
    }

    if (_card.cardTokenSpr != undefined) {
        var _tokenSize = _w * 0.25;
        draw_sprite_stretched(_card.cardTokenSpr, 0,
            _x + _w - _tokenSize - 2, _y + 2,
            _tokenSize, _tokenSize);
    }

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    //draw_text(_x + 3, _y + 3, string(_card.energy));

    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    //draw_text(_x + _w / 2, _y + _h - 3, _card.name);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
