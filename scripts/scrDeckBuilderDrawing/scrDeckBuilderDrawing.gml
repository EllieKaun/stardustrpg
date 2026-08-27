enum Panels { Collection, Deck }

// Конструктор слотов, который используется для отрисовки в дек билдере
function Slot(_state, _card = undefined) constructor {
    state = _state // "empty" | "locked" | "filled"
    card = _card
    ref = undefined
    selected = false
    count = 1 // сколько одинаковых карт в этом слоте
    dimmed = false // затемнить (карта занята чужой декой)
    ownerIcon = noone // иконка-метка владельца (LanaIcon/VivIcon)
    addable = true // можно ли добавить эту карту в деку
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
    tabOffsetX = _config[$ "tabOffsetX"] ?? 0 // отступ ряда вкладок слева
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

    scrollY = 0 // пиксельный скролл сетки 
    scrollable = _config[$ "scrollable"] ?? true
    totalRows = ceil(array_length(slots) / cols)

    cursorCol = 0
    cursorRow = 0
    selectedSlot = -1
    hoverSlot = -1 // слот под курсором мыши
    uiScale = 1 
    focused = false
    onTabRow = false
    justGainedFocus = false
    tag = ""

    // Шаг между строками карт (высота карты + вертикальный отступ)
    static rowPitch = function() {
        var layout = computeLayout()
        return layout.cardHeight + layout.gapY
    }

    // Максимальный пиксельный скролл
    static scrollMax = function() {
        var layout = computeLayout()
        var pitch = layout.cardHeight + layout.gapY
        var contentBottom = layout.gridY + (totalRows - 1) * pitch + layout.cardHeight
        var visibleBottom = y + h - padding
        return max(0, contentBottom - visibleBottom)
    }

    // Пересчёт строк для скролла
    static refreshScroll = function() {
        totalRows = ceil(array_length(slots) / cols)
        if (!scrollable) { 
            scrollY = 0
            return 
        }
        scrollY = clamp(scrollY, 0, scrollMax())
    }

    // Доскроллить так, чтобы строка row была видна целиком
    static scrollToRow = function(row) {
        if (!scrollable) return
        var layout = computeLayout()
        var pitch = layout.cardHeight + layout.gapY
        var rowTop = layout.gridY + row * pitch
        var rowBottom = rowTop + layout.cardHeight
        var visTop = layout.gridY
        var visBottom = y + h - padding
        if (rowTop - scrollY < visTop) scrollY = rowTop - visTop
        else if (rowBottom - scrollY > visBottom) scrollY = rowBottom - visBottom
        refreshScroll()
    }

    // Адаптивный лэайут
   static computeLayout = function() {
        var topPad = padding * 0.75 // верхний отступ меньше бокового
        var gridX = x + padding
        var gridY = y + topPad

        var gridW = w - padding * 2
        var gridH = h - topPad - padding

        var ratio = 2 / 3
        var minGap = padding * 0.5 
        var gapY = 6 * uiScale

        // Размер карты
        var reservedW = minGap * (cols + 1)
        var cardWidth = (gridW - reservedW) / cols
        var cardHeight = cardWidth / ratio

        // Статичная панель 
        if (!scrollable) {
            var rows = max(1, ceil(array_length(slots) / cols))
            var neededH = rows * cardHeight + (rows - 1) * gapY
            if (neededH > gridH) {
                var k = gridH / neededH
                cardHeight *= k
                cardWidth  *= k
            }
        }

        // Горизонтальные промежутки
        var freeW = gridW - (cardWidth * cols)
        var gapX = max(minGap, freeW / (cols + 1))

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
        var slotX = layout.gridX + layout.gapX + column * (layout.cardWidth + layout.gapX)
        var slotY = layout.gridY + row * (layout.cardHeight + layout.gapY) - scrollY
        return { sx: slotX, sy: slotY, sw: layout.cardWidth, sh: layout.cardHeight }
    }

    static getTabWidths = function() {
        var tabsCount = array_length(tabs)
        var widths = array_create(tabsCount, 0)
        var total = 0
        var prevFont = draw_get_font()
        for (var i = 0; i < tabsCount; i++) {
            var spr = tabs[i][$ "sprite"]
            var sc = uiTextScale(tabs[i].name, tabH * 0.8, 1000000)
            var inset = (tabs[i][$ "textInset"] ?? 0) * tabH
            var textNeed = inset + string_width(tabs[i].name) * sc + tabPadding
            var tabWidth
            if (spr != undefined) {
                var btnOff = (tabs[i][$ "btnOffsetX"] ?? 0) * tabH
                var artNeed = btnOff + tabH * sprite_get_width(spr) / sprite_get_height(spr)
                tabWidth = max(artNeed, textNeed)
            } else {
                tabWidth = textNeed
            }
            widths[i] = tabWidth
            total += tabWidth
        }
        draw_set_font(prevFont)
        var avail = w - tabOffsetX - tabGap * max(0, tabsCount - 1)
        var k = (total > avail && total > 0) ? avail / total : 1
        return { widths: widths, k: k }
    }

    // Данные о позиции и размере таба по индексу
    static getTabRect = function(index) {
        var tabsCount = array_length(tabs)
        if (tabsCount == 0) return { tx: x, ty: y - tabH, tw: 0, th: tabH }
        var tw = getTabWidths()
        var tabX = x + tabOffsetX
        for (var i = 0; i < index; i++) tabX += tw.widths[i] * tw.k + tabGap
        return { tx: tabX, ty: y - tabH, tw: tw.widths[index] * tw.k, th: tabH }
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
        scrollToRow(cursorRow) 
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
                // первая видимая строка при текущем скролле
                cursorRow = max(0, floor(scrollY / rowPitch()))
                selectAtCursor()
            }
            return;
        }

        // Когда выделены карты
        var dx = 0, dy = 0, moved = false
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) { 
            dy = -1
            moved = true
        }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) { 
            dy =  1
            moved = true
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
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
            scrollToRow(cursorRow) // плавная докрутка к курсору
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

    // Считывание и обработка мыши (наведение +
    // клик по табам/слотам). Возвращает true, если курсор над этой панелью
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
        
        // Видимость слотов
        for (var i = 0; i < array_length(slots); i++) {
            var sr = getSlotRect(i)
            if (pointInRect(mx, my, sr.sx, sr.sy, sr.sw, sr.sh)
                && pointInRect(mx, my, x, y, w, h)) {
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

        // Прокрутка колесом
        if (scrollable) {
            var wheelStep = rowPitch() * 0.5
            if (mouse_wheel_down()) scrollY = clamp(scrollY + wheelStep, 0, scrollMax())
            if (mouse_wheel_up()) scrollY = clamp(scrollY - wheelStep, 0, scrollMax())
        }
        return true
    }

    // Метод отрисовки панели (нужно вызывать в Draw GUI)
    static draw = function() {
        var oldFont = draw_get_font()

        // Бэк
        if (bgSprite != undefined) draw_sprite_stretched(bgSprite, 0, x, y, w, h)

        // Клип сетки по прямоугольнику фона 
        var prevScissor = gpu_get_scissor()
        gpu_set_scissor(floor(x), floor(y + 16), ceil(w), ceil(h - 32))

        // Рисуем все слоты, лишнее обрежет scissor
        var first = 0
        var last  = array_length(slots)
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
                            slotRect.sh,
                            selectedSlot == i)
                    drawSlotOverlays(slot, slotRect)
                    break
            }
        }

        // Выделение
        if (selectedSlot >= first && selectedSlot < last) {
            var slotRect = getSlotRect(selectedSlot)
             
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

        // конец клипа сетки
        gpu_set_scissor(prevScissor)

        // Табы
        for (var tabIndex = 0; tabIndex < array_length(tabs); tabIndex++) {
            var tab = tabs[tabIndex]
            var tabRow = getTabRect(tabIndex)
            var isActive = (tabIndex == activeTab)
            if (tab[$ "sprite"] != undefined) {
                // таб 1 показывает активный таб
                var tabSub = min(isActive ? 1 : 0, sprite_get_number(tab.sprite) - 1)
                draw_set_alpha(isActive ? 1.0 : 0.6)

                // кнопка может быть сдвинута вправо 
                var btnOff = (tab[$ "btnOffsetX"] ?? 0) * tabRow.th
                draw_sprite_stretched(tab.sprite, tabSub,
                    tabRow.tx + btnOff, tabRow.ty, tabRow.tw - btnOff, tabRow.th)

                // иконка поверх кнопки 
                var tabIcon = tab[$ "icon"]
                if (tabIcon != undefined) {
                    var artScale = tabRow.th / sprite_get_height(tab.sprite)
                    var iconW = sprite_get_width(tabIcon) * artScale
                    var iconH = sprite_get_height(tabIcon) * artScale
                    var iconX = tabRow.tx + (tab[$ "iconOffsetX"] ?? 0) * tabRow.th
                    var iconY = tabRow.ty + (tabRow.th - iconH) * 0.5
                    draw_sprite_stretched(tabIcon, 0, iconX, iconY, iconW, iconH)
                }
                draw_set_alpha(1.0)
            } else {
                draw_set_color(tab[$ "color"] ?? c_gray)
                draw_set_alpha(isActive ? 1.0 : 0.6)
                draw_rectangle(tabRow.tx, tabRow.ty, tabRow.tx + tabRow.tw - 1, tabRow.ty + tabRow.th - 1, false)
                draw_set_alpha(1.0)
            }

            // Подпись вкладки
            var labelInset = (tab[$ "textInset"] ?? 0) * tabRow.th
            draw_set_font(uiFont())
            draw_set_color(tab[$ "textColor"] ?? c_white)
            draw_set_valign(fa_middle)
            var labelMaxW = tabRow.tw - labelInset - tabPadding
            var labelScale = uiTextScale(tab.name, tabRow.th * 0.8, labelMaxW)
            if (labelInset > 0) {
                draw_set_halign(fa_left)
                draw_text_transformed(tabRow.tx + labelInset, tabRow.ty + tabRow.th / 2,
                    tab.name, labelScale, labelScale, 0)
            } else {
                draw_set_halign(fa_center)
                draw_text_transformed(tabRow.tx + tabRow.tw / 2, tabRow.ty + tabRow.th / 2,
                    tab.name, labelScale, labelScale, 0)
            }
            draw_set_halign(fa_left)
            draw_set_valign(fa_top)

            if (onTabRow && focused && isActive) {
                draw_set_color(c_yellow)
                draw_rectangle(tabRow.tx, tabRow.ty, tabRow.tx + tabRow.tw - 1, tabRow.ty + tabRow.th - 1, true)
            }
        }

        draw_set_color(c_white)
        draw_set_font(oldFont)
    };
}

// Отрисовка карты
function drawCard(card, cardX, cardY, cardW, cardH, isSelected = false) {
    if (card.cardBaseSpr == undefined) {
        return
    }
    drawCardFace(card, cardX + cardW * 0.5, cardY + cardH * 0.5, cardW, cardH, 0, 1, 1, isSelected)
}

// Оверлеи слота коллекции: затемнение, иконка владельца и число копий
function drawSlotOverlays(slot, rect) {
    // затемнение занятой чужой декой карты
    if (slot.dimmed) {
        draw_set_color(c_black)
        draw_set_alpha(0.55)
        draw_rectangle(rect.sx, rect.sy, rect.sx + rect.sw, rect.sy + rect.sh, false)
        draw_set_alpha(1)
        draw_set_color(c_white)
    }

    // иконка владельца 
    if (slot.ownerIcon != noone && sprite_exists(slot.ownerIcon)) {
        var icoH = rect.sh * 0.2
        var icoScale = icoH / sprite_get_height(slot.ownerIcon)
        var icoW = sprite_get_width(slot.ownerIcon) * icoScale
        var icoX = rect.sx + rect.sw * 0.95
        var icoY = rect.sy + rect.sh * 0.04 
        draw_sprite_ext(slot.ownerIcon, 0, icoX, icoY, icoScale, icoScale, 0, c_white, 1)
    }

    // число копий (показываем при count > 1) 
    if (slot.count > 1) {
        var badgeH = rect.sh * 0.2
        var badgeScale = badgeH / sprite_get_height(AmountBtn)
        var badgeW = sprite_get_width(AmountBtn) * badgeScale
        var bx = rect.sx + rect.sw * 0.05
        var by = rect.sy + rect.sh * 0.04 
        draw_sprite_ext(AmountBtn, 0, bx, by, badgeScale, badgeScale, 0, c_white, 1)

        var prevFont = draw_get_font()
        draw_set_font(uiFont())
        draw_set_halign(fa_center)
        draw_set_valign(fa_middle)
        draw_set_color(c_black)
        var txt = string(slot.count)
        var tsc = uiTextScale(txt, badgeH * 0.8, badgeW * 0.8)
        draw_text_transformed(bx, by, txt, tsc, tsc, 0)
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_font(prevFont)
    }
}