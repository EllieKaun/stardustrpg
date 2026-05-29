enum Panels { Collection, Deck }

// Конструктор слотаб, который используется для отрисовки в дек билдере
function Slot(_state, _card = undefined) constructor {
    state = _state;       // "empty" | "locked" | "filled"
    card = _card;
    selected = false;
}

// Подобрать шрифт и отрисовать текст центрировано
function drawFitTextCentered(text, areaX, areaY, areaW, areaH, fonts = undefined) {
    if (fonts != undefined && array_length(fonts) > 0) {
        for (var i = 0; i < array_length(fonts); i++) {
            draw_set_font(fonts[i]);
            if (string_width(text) <= areaW && string_height(text) <= areaH) break;
        }
    }
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(areaX + areaW / 2, areaY + areaH / 2, text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Конфигурация панели, которая отвечает за отрисовку в дек билдере
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
    tabFonts = _config[$ "tabFonts"] ?? undefined;
    activeTab = 0;

    cols = 4;           
    cardRatio = 2 / 3;     
    slots = _config[$ "slots"] ?? [];
    padding = _config[$ "padding"] ?? 8;
    tabH = _config[$ "tabH"] ?? 18;
    tabGap = _config[$ "tabGap"] ?? 2;
    tabPadding = _config[$ "tabPadding"] ?? 4;

    onSlotClick = _config[$ "onSlotClick"] ?? undefined;
    onTabClick = _config[$ "onTabClick"] ?? undefined;
    onPanelSwitch = _config[$ "onPanelSwitch"] ?? undefined;

    visibleRows = max(1, _config[$ "visibleRows"] ?? ceil(array_length(slots) / cols));
    scrollRow = 0;
    totalRows = ceil(array_length(slots) / cols);

    cursorCol = 0;
    cursorRow = 0;
    selectedSlot = -1;
    focused = false;
    onTabRow = false;
    justGainedFocus = false;   
    tag = "";

    // Обновление слотов при скроле
    static refreshScroll = function() {
        totalRows = ceil(array_length(slots) / cols);
        scrollRow = clamp(scrollRow, 0, max(0, totalRows - visibleRows));
    };

    // Адаптивный лэайут для того, чтобы влезало 4 карты в строку с соотношением 2/3
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
    
        // Промежутки между картами
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
    
    // Данные о позиции и размере слота по индексу
    static getSlotRect = function(_index) {
        var _lay    = computeLayout();
        var _col    = _index mod cols;
        var _row    = _index div cols;
        var _visRow = _row - scrollRow;
        var _sx = _lay.gridX + _lay.gapX + _col    * (_lay.cw + _lay.gapX);
        var _sy = _lay.gridY + _lay.gapY + _visRow * (_lay.ch + _lay.gapY);
        return { sx: _sx, sy: _sy, sw: _lay.cw, sh: _lay.ch };
    };

    // Вкладки сейчас равномерно распределены по ширине панели, поэтому они никогда 
    // выходят за пределы панели. Они над бэком (ty = y - tabH).
    // Данные о позиции и размере таба по индексу
    static getTabRect = function(_index) {
        var _n = array_length(tabs);
        if (_n == 0) return { tx: x, ty: y - tabH, tw: 0, th: tabH };
        var _tw = (w - tabGap * (_n - 1)) / _n;
        var _tx = x + _index * (_tw + tabGap);
        return { tx: _tx, ty: y - tabH, tw: _tw, th: tabH };
    };

    //// Фокус и выделение
    
    // выделить текущий слот
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

    // Вход в панель слева
    static enterFromLeft = function(_row) { 
        focused = true; 
        onTabRow = false;
        cursorCol = 0;
        cursorRow = clamp(_row, 0, max(0, totalRows - 1));
        selectAtCursor();
        justGainedFocus = true;
    };

    // Вход в панель справа
    static enterFromRight = function(_row) {
        focused = true;   
        onTabRow = false;
        cursorCol = cols - 1;
        cursorRow = clamp(_row, 0, max(0, totalRows - 1));
        selectAtCursor();
        justGainedFocus = true;
    };

    // Метод для обновления состояния панели в степе
    static step = function() {
        if (!focused) return;
        stepKeyboard();
    };

    // Считывание и обновление данных с клавиатуры
    static stepKeyboard = function() {
        if (justGainedFocus) { justGainedFocus = false; return; }

        var _nTabs = array_length(tabs);

        // ---- TAB ROW MODE ----
        if (onTabRow) {
            if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
                if (_nTabs > 0) { activeTab = max(0, activeTab - 1); if (onTabClick != undefined) onTabClick(self, activeTab); }
            }
            if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
                if (_nTabs > 0) { activeTab = min(_nTabs - 1, activeTab + 1); if (onTabClick != undefined) onTabClick(self, activeTab); }
            }
            if (keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) ||
                keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
                onTabRow  = false;
                cursorRow = scrollRow;
                selectAtCursor();
            }
            return;
        }

        // ---- GRID MODE ----
        var _dx = 0, _dy = 0, _moved = false;
        if (keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W"))) { _dy = -1; _moved = true; }
        if (keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S"))) { _dy =  1; _moved = true; }
        if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) { _dx = -1; _moved = true; }
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) { _dx =  1; _moved = true; }

        if (_moved) {
            if (selectedSlot < 0) { cursorCol = 0; cursorRow = 0; selectAtCursor(); }

            // Up from the top row -> go to the tab row
            if (_dy < 0 && cursorRow == 0 && _nTabs > 0) {
                onTabRow = true;
                return;
            }

            var _newCol = cursorCol + _dx;
            var _newRow = cursorRow + _dy;

            if (_newCol < 0)     { if (onPanelSwitch != undefined) onPanelSwitch(self, -1); return; }
            if (_newCol >= cols) { if (onPanelSwitch != undefined) onPanelSwitch(self,  1); return; }

            _newRow = clamp(_newRow, 0, max(0, totalRows - 1));

            var _slotsInRow = array_length(slots) - _newRow * cols;
            if (_slotsInRow <= 0) return;
            _newCol = clamp(_newCol, 0, _slotsInRow - 1);

            cursorCol    = _newCol;
            cursorRow    = _newRow;
            selectedSlot = cursorRow * cols + cursorCol;

            if (cursorRow < scrollRow) scrollRow = cursorRow;
            else if (cursorRow >= scrollRow + visibleRows) scrollRow = cursorRow - visibleRows + 1;
            refreshScroll();
        }

        // Confirm
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            if (selectedSlot >= 0 && selectedSlot < array_length(slots)) {
                var _slot = slots[selectedSlot];
                if (_slot.state != "locked" && onSlotClick != undefined) onSlotClick(self, selectedSlot);
            }
        }

        // Quick tab switch from anywhere
        if (_nTabs > 0) {
            if (keyboard_check_pressed(ord("Q"))) { activeTab = max(0, activeTab - 1);          if (onTabClick != undefined) onTabClick(self, activeTab); }
            if (keyboard_check_pressed(ord("E"))) { activeTab = min(_nTabs - 1, activeTab + 1); if (onTabClick != undefined) onTabClick(self, activeTab); }
        }
    };

    // Метод отрисовки панели (нужно вызывать в Draw GUI) 
    static draw = function() {
        var _oldFont = draw_get_font();

        // Background
        if (bgSprite != undefined) draw_sprite_stretched(bgSprite, 0, x, y, w, h);

        // Slots
        var _first = scrollRow * cols;
        var _last  = min(_first + visibleRows * cols, array_length(slots));
        for (var _i = _first; _i < _last; _i++) {
            var _slot = slots[_i];
            var _r    = getSlotRect(_i);
            switch (_slot.state) {
                case "locked":
                    if (slotSpriteLocked != undefined) draw_sprite_stretched(slotSpriteLocked, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                    break;
                case "empty":
                    if (slotSpriteEmpty != undefined) draw_sprite_stretched(slotSpriteEmpty, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                    break;
                case "filled":
                    if (slotSpriteEmpty != undefined) draw_sprite_stretched(slotSpriteEmpty, 0, _r.sx, _r.sy, _r.sw, _r.sh);
                    if (_slot.card != undefined) drawCard(_slot.card, _r.sx, _r.sy, _r.sw, _r.sh);
                    break;
            }
        }

        // Selection highlight (always) + pointer (only on focused grid)
        if (selectedSlot >= _first && selectedSlot < _last) {
            var _sr = getSlotRect(selectedSlot);
            if (selectSprite != undefined)
                draw_sprite_stretched(selectSprite, 0, _sr.sx - 1, _sr.sy - 1, _sr.sw + 2, _sr.sh + 2);

            if (pointerSprite != undefined && focused && !onTabRow) {
                var _ph    = _sr.sh * 0.5;
                var _scale = _ph / sprite_get_height(pointerSprite);
                var _px    = _sr.sx + _sr.sw * 0.10;
                var _py    = _sr.sy + (_sr.sh - _ph) / 2;
                draw_sprite_ext(pointerSprite, 0, _px, _py, _scale, _scale, 0, c_white, 1);
            }
        }

        // Tabs (above the panel, fit text, never wider than the panel)
        for (var _t = 0; _t < array_length(tabs); _t++) {
            var _tab      = tabs[_t];
            var _tr       = getTabRect(_t);
            var _isActive = (_t == activeTab);

            if (_tab[$ "sprite"] != undefined) {
                draw_sprite_stretched(_tab.sprite, _isActive ? 1 : 0, _tr.tx, _tr.ty, _tr.tw, _tr.th);
            } else {
                draw_set_color(_tab[$ "color"] ?? c_gray);
                draw_set_alpha(_isActive ? 1.0 : 0.6);
                draw_rectangle(_tr.tx, _tr.ty, _tr.tx + _tr.tw - 1, _tr.ty + _tr.th - 1, false);
                draw_set_alpha(1.0);
            }

            draw_set_color(c_white);
            drawFitTextCentered(_tab.name,
                _tr.tx + tabPadding, _tr.ty + 1,
                _tr.tw - tabPadding * 2, _tr.th - 2,
                tabFonts);

            // Focus outline when navigating the tab row
            if (onTabRow && focused && _isActive) {
                draw_set_color(c_yellow);
                draw_rectangle(_tr.tx, _tr.ty, _tr.tx + _tr.tw - 1, _tr.ty + _tr.th - 1, true);
            }
        }

        // Scroll indicator
        if (totalRows > visibleRows) {
            var _barX   = x + w - padding;
            var _barY   = y + padding;
            var _barH   = h - padding * 2;
            var _thumbH = _barH * (visibleRows / totalRows);
            var _thumbY = _barY + (_barH - _thumbH) * (scrollRow / max(1, totalRows - visibleRows));
            draw_set_color(c_dkgray); draw_set_alpha(0.4);
            draw_rectangle(_barX, _barY, _barX + 4, _barY + _barH, false);
            draw_set_color(c_white);  draw_set_alpha(0.8);
            draw_rectangle(_barX, _thumbY, _barX + 4, _thumbY + _thumbH, false);
            draw_set_alpha(1.0);
        }

        draw_set_color(c_white);
        draw_set_font(_oldFont);
    };
}

// Безопасная отрссовка карты
function drawCard(card, cardX, cardY, cardW, cardH) {
    if (card.cardBaseSpr != undefined) 
        draw_sprite_stretched(card.cardBaseSpr, 0, cardX, cardY, cardW, cardH);
    if (card.cardIllustrationSpr != undefined) 
        draw_sprite_stretched(card.cardIllustrationSpr, 0, cardX, cardY, cardW, cardH);
    if (card.cardBorderSpr != undefined)
         draw_sprite_stretched(card.cardBorderSpr, 0, cardX, cardY, cardW, cardH);
    if (card.cardTokenSpr != undefined)
        draw_sprite_stretched(card.cardTokenSpr, 0, cardX, cardY, cardW, cardH);
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
 //   draw_text(cardX + 3, cardY + 3, string(_card.energy));
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
   // draw_text(cardX + cardW / 2, cardY + cardH - 3, _card.name);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}