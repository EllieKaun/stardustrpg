enum Panels { Collection, Deck }

// Конструктор слотаб, который используется для отрисовки в дек билдере
function Slot(_state, _card = undefined) constructor {
    state = _state      // "empty" | "locked" | "filled"
    card = _card
    ref = undefined 
    selected = false
}

// Подобрать шрифт и отрисовать текст центрировано
function drawFitTextCentered(text, areaX, areaY, areaW, areaH, fonts = undefined) {
    if (fonts != undefined && array_length(fonts) > 0) {
        for (var i = 0; i < array_length(fonts); i++) {
            draw_set_font(fonts[i]);
            if (string_width(text) <= areaW && string_height(text) <= areaH) break
        }
    }
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_text(areaX + areaW / 2, areaY + areaH / 2, text)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}

// Попадание точки в прямоугольник
function pointInRect(px, py, rx, ry, rw, rh) {
    return (px >= rx && px < rx + rw && py >= ry && py < ry + rh)
}

// Конфигурация панели, которая отвечает за отрисовку в дек билдере
function Panel(_config) constructor {
    x = _config[$ "x"] ?? 0
    y = _config[$ "y"] ?? 0
    w = _config[$ "w"] ?? 200
    h = _config[$ "h"] ?? 200

    bgSprite = _config[$ "bgSprite"]
    slotSpriteEmpty = _config[$ "slotSpriteEmpty"]
    slotSpriteLocked = _config[$ "slotSpriteLocked"]
    selectSprite = _config[$ "selectSprite"]
    pointerSprite = _config[$ "pointerSprite"]

    tabs = _config[$ "tabs"] ?? []
    tabFonts = _config[$ "tabFonts"] ?? undefined
    activeTab = 0

    cols = 4        
    cardRatio = 2 / 3
    slots = _config[$ "slots"] ?? []
    padding = _config[$ "padding"] ?? 8
    tabH = _config[$ "tabH"] ?? 18
    tabGap = _config[$ "tabGap"] ?? 2
    tabPadding = _config[$ "tabPadding"] ?? 4

    onSlotClick = _config[$ "onSlotClick"] ?? undefined
    onTabClick = _config[$ "onTabClick"] ?? undefined
    onPanelSwitch = _config[$ "onPanelSwitch"] ?? undefined

    visibleRows = max(1, _config[$ "visibleRows"] ?? ceil(array_length(slots) / cols))
    scrollRow = 0;
    totalRows = ceil(array_length(slots) / cols)

    cursorCol = 0
    cursorRow = 0
    selectedSlot = -1
    hoverSlot = -1        // слот под курсором мыши (только подсветка)
    uiScale = 1           // множитель дизайн→окно (ставит layoutPanels) для спрайтов фикс. размера
    focused = false
    onTabRow = false
    justGainedFocus = false
    tag = ""

    // Обновление слотов при скроле
    static refreshScroll = function() {
        totalRows = ceil(array_length(slots) / cols)
        scrollRow = clamp(scrollRow, 0, max(0, totalRows - visibleRows))
    }

    // Адаптивный лэайут для того, чтобы влезало 4 карты в строку с соотношением 2/3
   static computeLayout = function() {
    
        var gridX = x + padding
        var gridY = y + padding
    
        var gridW = w - padding * 2
        var gridH = h - padding * 2
    
        var rows = max(1, visibleRows)
    
        var ratio = 2 / 3

        var minGap = padding * 0.5   // пропорционально паддингу — панель координатно-независима

        // Сколько места минимум займут отступы
        var reservedW = minGap * (cols + 1)
        var reservedH = minGap * (rows + 1)
    
        // Размер карты по ширине
        var cardWidth = (gridW - reservedW) / cols
        var cardHeight= cardWidth / ratio
    
        // Если по высоте не влезает —
        // пересчитываем от высоты
        if (cardHeight * rows > (gridH - reservedH)) {
            cardHeight = (gridH - reservedH) / rows
            cardWidth = cardHeight * ratio
        }
    
        // Остаток пространства
        var freeW = gridW - (cardWidth * cols)
        var freeH = gridH - (cardHeight * rows)
    
        // Промежутки между картами
        var gapX = max(minGap, freeW / (cols + 1))
        var gapY = max(minGap, freeH / (rows + 1))
    
        return {
            gridX : gridX,
            gridY : gridY,
    
            cardWidth: cardWidth,
            cardHeight : cardHeight,
    
            gapX : gapX,
            gapY : gapY
        }
    }
    
    // Данные о позиции и размере слота по индексу
    static getSlotRect = function(index) {
        var layout = computeLayout()
        var column = index mod cols
        var row = index div cols
        var visibleRow = row - scrollRow
        var slotX = layout.gridX + layout.gapX + column * (layout.cardWidth + layout.gapX)
        var slotY = layout.gridY + layout.gapY + visibleRow * (layout.cardHeight + layout.gapY)
        return { sx: slotX, sy: slotY, sw: layout.cardWidth, sh: layout.cardHeight }
    }

    // Вкладки сейчас равномерно распределены по ширине панели, поэтому они никогда 
    // выходят за пределы панели. Они над бэком (ty = y - tabH).
    // Данные о позиции и размере таба по индексу
    static getTabRect = function(index) {
        var tabsCount = array_length(tabs)
        if (tabsCount == 0) return { tx: x, ty: y - tabH, tw: 0, th: tabH }
        var tabWidth = (w - tabGap * (tabsCount - 1)) / tabsCount
        var tabX = x + index * (tabWidth + tabGap)
        return { tx: tabX, ty: y - tabH, tw: tabWidth, th: tabH }
    }

    //// Фокус и выделение
    
    // выделить текущий слот
    static selectAtCursor = function() {
        var slotsInRow = array_length(slots) - cursorRow * cols
        if (slotsInRow <= 0) {
            cursorRow = max(0, totalRows - 1)
            slotsInRow = array_length(slots) - cursorRow * cols
        }
        cursorCol = clamp(cursorCol, 0, max(0, slotsInRow - 1))
        selectedSlot = cursorRow * cols + cursorCol

        if (cursorRow < scrollRow) scrollRow = cursorRow
        else if (cursorRow >= scrollRow + visibleRows) scrollRow = cursorRow - visibleRows + 1
        refreshScroll()
    }

    // Вход в панель слева
    static enterFromLeft = function(row) { 
        focused = true
        onTabRow = false
        cursorCol = 0
        cursorRow = clamp(row, 0, max(0, totalRows - 1))
        selectAtCursor()
        justGainedFocus = true
    }

    // Вход в панель справа
    static enterFromRight = function(row) {
        focused = true
        onTabRow = false
        cursorCol = cols - 1
        cursorRow = clamp(row, 0, max(0, totalRows - 1))
        selectAtCursor()
        justGainedFocus = true
    }

    // Метод для обновления состояния панели в степе
    static step = function() {
        if (!focused) {
            return
        }
        stepKeyboard()
    }

    // Считывание и обновление данных с клавиатуры
    static stepKeyboard = function() {
        if (justGainedFocus) { 
            justGainedFocus = false
            return
        }

        var nTabs = array_length(tabs)

        // Когда выделены таьы
        if (onTabRow) {
            if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
                if (nTabs > 0) { 
                    activeTab = max(0, activeTab - 1)
                    if (onTabClick != undefined) 
                        onTabClick(self, activeTab)
                }
            }
            if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
                if (nTabs > 0) { 
                    activeTab = min(nTabs - 1, activeTab + 1)
                    if (onTabClick != undefined) 
                        onTabClick(self, activeTab)
                }
            }
            if (keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) ||
                keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
                onTabRow  = false
                cursorRow = scrollRow
                selectAtCursor()
            }
            return;
        }

        // Когда выделены карты
        var dx = 0, dy = 0, moved = false
        if (keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W"))) { 
            dy = -1
            moved = true
        }
        if (keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S"))) { 
            dy =  1
            moved = true
        }
        if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) {
            dx = -1
            moved = true
        }
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
             dx =  1
             moved = true
        }

        if (moved) {
            if (selectedSlot < 0) { 
                cursorCol = 0
                cursorRow = 0
                selectAtCursor() 
            }

            // Переход в режим табов
            if (dy < 0 && cursorRow == 0 && nTabs > 0) {
                onTabRow = true
                return
            }

            var newCol = cursorCol + dx
            var newRow = cursorRow + dy

            if (newCol < 0) { 
                if (onPanelSwitch != undefined) 
                    onPanelSwitch(self, -1)
                return
            }
            if (newCol >= cols) { 
                if (onPanelSwitch != undefined) 
                    onPanelSwitch(self,  1)
                return
            }

            newRow = clamp(newRow, 0, max(0, totalRows - 1))

            var slotsInRow = array_length(slots) - newRow * cols
            if (slotsInRow <= 0) return
            newCol = clamp(newCol, 0, slotsInRow - 1)

            cursorCol = newCol
            cursorRow = newRow
            selectedSlot = cursorRow * cols + cursorCol

            if (cursorRow < scrollRow) scrollRow = cursorRow
            else if (cursorRow >= scrollRow + visibleRows) scrollRow = cursorRow - visibleRows + 1
            refreshScroll()
        }

        // Обработка ентера
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            if (selectedSlot >= 0 && selectedSlot < array_length(slots)) {
                var slot = slots[selectedSlot]
                if (slot.state != "locked" && onSlotClick != undefined) onSlotClick(self, selectedSlot)
            }
        }

        // На всякий случай переключение табов горячими клавишами
        if (nTabs > 0) {
            if (keyboard_check_pressed(ord("Q"))) { 
                activeTab = max(0, activeTab - 1)     
                if (onTabClick != undefined) 
                    onTabClick(self, activeTab)
            }
            if (keyboard_check_pressed(ord("E"))) { 
                activeTab = min(nTabs - 1, activeTab + 1) 
                if (onTabClick != undefined) 
                    onTabClick(self, activeTab)
            }
        }
    }

    // Считывание и обработка мыши. Работает независимо от фокуса (наведение +
    // клик по табам/слотам). Возвращает true, если курсор над этой панелью.
    static stepMouse = function() {
        hoverSlot = -1
        // панель свёрстана прямо в координатах GUI (окна), поэтому мышь берём как есть
        var mx = device_mouse_x_to_gui(0)
        var my = device_mouse_y_to_gui(0)

        // область панели вместе со строкой табов над ней
        if (!pointInRect(mx, my, x, y - tabH, w, h + tabH)) return false

        var clicked = mouse_check_button_pressed(mb_left)

        // Табы
        for (var t = 0; t < array_length(tabs); t++) {
            var tr = getTabRect(t)
            if (pointInRect(mx, my, tr.tx, tr.ty, tr.tw, tr.th)) {
                if (clicked) {
                    oDeckBuilder.focusPanel(self)
                    onTabRow = true
                    activeTab = t
                    if (onTabClick != undefined) onTabClick(self, t)
                }
                return true
            }
        }

        // Слоты
        var first = scrollRow * cols
        var last  = min(first + visibleRows * cols, array_length(slots))
        for (var i = first; i < last; i++) {
            var sr = getSlotRect(i)
            if (pointInRect(mx, my, sr.sx, sr.sy, sr.sw, sr.sh)) {
                hoverSlot = i
                if (clicked) {
                    oDeckBuilder.focusPanel(self)
                    onTabRow = false
                    cursorRow = i div cols
                    cursorCol = i mod cols
                    selectedSlot = i
                    var slot = slots[i]
                    if (slot.state != "locked" && onSlotClick != undefined) onSlotClick(self, i)
                }
                return true
            }
        }

        // Колесо — прокрутка списка
        if (mouse_wheel_down()) scrollRow = clamp(scrollRow + 1, 0, max(0, totalRows - visibleRows))
        if (mouse_wheel_up())   scrollRow = clamp(scrollRow - 1, 0, max(0, totalRows - visibleRows))
        return true
    }

    // Метод отрисовки панели (нужно вызывать в Draw GUI)
    static draw = function() {
        var oldFont = draw_get_font()

        // Бёк
        if (bgSprite != undefined) draw_sprite_stretched(bgSprite, 0, x, y, w, h)

        // Слоты
        var first = scrollRow * cols
        var last  = min(first + visibleRows * cols, array_length(slots))
        for (var i = first; i < last; i++) {
            var slot = slots[i]
            var slotRect = getSlotRect(i)
            switch (slot.state) {
                case "locked":
                    if (slotSpriteLocked != undefined)
                        draw_sprite_stretched(slotSpriteLocked, 
                            0, 
                            slotRect.sx, 
                            slotRect.sy, 
                            slotRect.sw, 
                            slotRect.sh)
                    break
                case "empty":
                    if (slotSpriteEmpty != undefined) 
                        draw_sprite_stretched(slotSpriteEmpty, 
                            0, 
                            slotRect.sx,
                            slotRect.sy, 
                            slotRect.sw,
                            slotRect.sh)
                    break
                case "filled":
                    if (slotSpriteEmpty != undefined) 
                        draw_sprite_stretched(slotSpriteEmpty, 
                            0, 
                            slotRect.sx, 
                            slotRect.sy,
                            slotRect.sw, 
                            slotRect.sh)
                    if (slot.card != undefined)
                         drawCard(slot.card, 
                            slotRect.sx, 
                            slotRect.sy, 
                            slotRect.sw, 
                            slotRect.sh)
                    break
            }
        }

        // Выделение (сейчас работает всегда) + указатель (только на фокусированном слоте в фокусированной доске)
        if (selectedSlot >= first && selectedSlot < last) {
            var slotRect = getSlotRect(selectedSlot)
            if (selectSprite != undefined)
                draw_sprite_stretched(selectSprite, 
                    0, 
                    slotRect.sx - 1, 
                    slotRect.sy - 1, 
                    slotRect.sw + 2, 
                    slotRect.sh + 2)

            if (pointerSprite != undefined && focused && !onTabRow) {
                var pointerX = slotRect.sx + slotRect.sw * 0.10
                var pointerY = slotRect.sy + (slotRect.sh) / 2
                draw_sprite_ext(pointerSprite, 0, pointerX, pointerY, uiScale, uiScale, 0, c_white, 1)
            }
        }

        // Подсветка слота под курсором мыши
        if (hoverSlot >= first && hoverSlot < last && hoverSlot != selectedSlot) {
            var hoverRect = getSlotRect(hoverSlot)
            draw_set_color(c_yellow)
            draw_set_alpha(0.6)
            draw_rectangle(hoverRect.sx - 1, hoverRect.sy - 1,
                hoverRect.sx + hoverRect.sw, hoverRect.sy + hoverRect.sh, true)
            draw_set_alpha(1)
            draw_set_color(c_white)
        }

        // Табы
        for (var tabIndex = 0; tabIndex < array_length(tabs); tabIndex++) {
            var tab = tabs[tabIndex]
            var tabRow = getTabRect(tabIndex)
            var isActive = (tabIndex == activeTab)

            if (tab[$ "sprite"] != undefined) {
                draw_sprite_stretched(tab.sprite, isActive ? 1 : 0, tabRow.tx, tabRow.ty, tabRow.tw, tabRow.th)
            } else {
                draw_set_color(tab[$ "color"] ?? c_gray)
                draw_set_alpha(isActive ? 1.0 : 0.6)
                draw_rectangle(tabRow.tx, tabRow.ty, tabRow.tx + tabRow.tw - 1, tabRow.ty + tabRow.th - 1, false)
                draw_set_alpha(1.0)
            }

            // Подпись вкладки рисуется на месте (координаты уже оконные, GUI в
            // нативном разрешении) шрифтом uiFont() — чётко, без отдельного прохода.
            draw_set_font(uiFont())
            draw_set_color(tab[$ "textColor"] ?? c_white)
            draw_set_halign(fa_center)
            draw_set_valign(fa_middle)
            var labelScale = uiTextScale(tab.name, tabRow.th * 0.55, tabRow.tw - tabPadding * 2)
            draw_text_transformed(tabRow.tx + tabRow.tw / 2, tabRow.ty + tabRow.th / 2,
                tab.name, labelScale, labelScale, 0)
            draw_set_halign(fa_left)
            draw_set_valign(fa_top)

            if (onTabRow && focused && isActive) {
                draw_set_color(c_yellow)
                draw_rectangle(tabRow.tx, tabRow.ty, tabRow.tx + tabRow.tw - 1, tabRow.ty + tabRow.th - 1, true)
            }
        }

        // Скролл индткатор
        if (totalRows > visibleRows) {
            var barW   = 4 * uiScale
            var barX   = x + w - padding
            var barY   = y + padding
            var barH   = h - padding * 2
            var thumbH = barH * (visibleRows / totalRows)
            var thumbY = barY + (barH - thumbH) * (scrollRow / max(1, totalRows - visibleRows))
            draw_set_color(c_dkgray)
            draw_set_alpha(0.4)
            draw_rectangle(barX, barY, barX + barW, barY + barH, false)
            draw_set_color(c_white)
            draw_set_alpha(0.8)
            draw_rectangle(barX, thumbY, barX + barW, thumbY + thumbH, false)
            draw_set_alpha(1.0)
        }

        draw_set_color(c_white)
        draw_set_font(oldFont)
    };
}

// Безопасная отрссовка карты
function drawCard(card, cardX, cardY, cardW, cardH) {
    if (card.cardBaseSpr != undefined) 
        draw_sprite_stretched(card.cardBaseSpr, 0, cardX, cardY, cardW, cardH)
    if (card.cardIllustrationSpr != undefined) 
        draw_sprite_stretched(card.cardIllustrationSpr, 0, cardX, cardY, cardW, cardH)
    if (card.cardBorderSpr != undefined)
         draw_sprite_stretched(card.cardBorderSpr, 0, cardX, cardY, cardW, cardH)
    if (card.cardTokenSpr != undefined)
        draw_sprite_stretched(card.cardTokenSpr, 0, cardX, cardY, cardW, cardH)
    
    draw_set_color(c_white)
    draw_set_halign(fa_left)
 //   draw_text(cardX + 3, cardY + 3, string(_card.energy))
    draw_set_halign(fa_center)
    draw_set_valign(fa_bottom)
   // draw_text(cardX + cardW / 2, cardY + cardH - 3, _card.name)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}