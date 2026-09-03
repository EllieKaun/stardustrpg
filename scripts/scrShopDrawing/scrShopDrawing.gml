enum ShopCategory { Cards, OtherItems }

#macro SHOP_CARD_PRICE 100 // цена карты
#macro SHOP_SLOT_BASE 100 // базовая цена расширения слота деки

// Модель товара магазина
// kind: "card" или "slot"
function ShopItem(_kind, _price) constructor {
    kind = _kind
    price = _price
    card = undefined // для карт
    ref = undefined // { id, rarity } для карт
    label = "" // подпись (для слотов)
    state = "filled"
}

// Цена следующего расширения слота деки x1.5
function deckSlotUpgradePrice() {
    var purchased = deckOf(Characters.Lana).unlocked - DECK_DEFAULT_UNLOCKED
    return floor(SHOP_SLOT_BASE * power(1.5, max(0, purchased)))
}

// Список товаров для категории
function buildShopItems(category) {
    var items = []

    if (category == ShopCategory.Cards) {
        // Карты, которые игрок уже открыл
        var refs = getCollectionRefs()
        for (var i = 0; i < array_length(refs); i++) {
            var card = cardFromRef(refs[i])
            if (card == undefined) continue
            var it = new ShopItem("card", SHOP_CARD_PRICE)
            it.card = card
            it.ref = { id: refs[i].id, rarity: refs[i].rarity }
            array_push(items, it)
        }
    } else {
        // Расширение слотов деки 
        if (deckOf(Characters.Lana).unlocked < DECK_CAPACITY) {
            var it = new ShopItem("slot", deckSlotUpgradePrice())
            it.label = "New deck slot"
            array_push(items, it)
        }
    }
    return items
}

// Текстовые строки описания товара
function shopItemLines(item) {
    var lines = []

    if (item.kind == "slot") {
        array_push(lines, item.label)
        array_push(lines, "Adds a deck card slot")
        array_push(lines, "for both heroes")
        return lines
    }

    var card = item.card
    array_push(lines, "Type: " + (card.actionType == StarriorStates.Attack ? "Atc" : "Cast"))

    var costLabel = (card.costType() == CostType.Mana) ? "mp" : "hp"
    array_push(lines, "Cost: " + string(card.costValue()) + costLabel)

    // тип урона (если есть урон)
    for (var i = 0; i < array_length(card.effects); i++) {
        var effect = card.effects[i]
        if (variable_struct_exists(effect, "type") && effect.type == EffectTypes.Damage) {
            array_push(lines, "Damage Type: " + (effect.damageType == DamageTypes.Magical ? "magical" : "physical"))
            break
        }
    }
    array_push(lines, card.description)
    return lines
}

// Отрисовка одной строки-товара в прямоугольнике rect {sx,sy,sw,sh}
function drawShopItem(item, rect, uiScale) {
    // рамка товара
    draw_sprite_stretched(box, 0, rect.sx, rect.sy, rect.sw, rect.sh)

    var pad = rect.sh * 0.12
    var contentH = rect.sh - pad * 2
    var textX = rect.sx + pad
    var textTop = rect.sy + pad

    // карта слева
    if (item.kind == "card" && item.card != undefined) {
        var cardH = contentH
        var cardW = cardH * 2 / 3
        drawCardFace(item.card, rect.sx + pad + cardW * 0.5, textTop + cardH * 0.5, cardW, cardH, 0)
        textX = rect.sx + pad + cardW + pad
    }

    // описание
    var lines = shopItemLines(item)
    var lineH = contentH / max(5, array_length(lines))
    draw_set_font(uiFont())
    draw_set_color(c_white)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    for (var i = 0; i < array_length(lines); i++) {
        drawUiText(textX, textTop + i * lineH, lines[i], lineH * 0.8)
    }

    // цена
    var coinH = rect.sh * 0.34
    var coinScale = coinH / sprite_get_height(CoinIcon)
    var coinW = sprite_get_width(CoinIcon) * coinScale
    var coinCX = rect.sx + rect.sw - pad - coinW * 0.5
    var coinCY = rect.sy + rect.sh * 0.5

    var priceStr = string(item.price)
    draw_set_halign(fa_right)
    draw_set_valign(fa_middle)
    draw_set_color(c_white)
    var priceScale = uiTextScale(priceStr, coinH * 0.9, rect.sw * 0.2)
    draw_text_transformed(coinCX - coinW * 0.5 - pad * 0.4, coinCY, priceStr, priceScale, priceScale, 0)

    draw_sprite_ext(CoinIcon, 0, coinCX, coinCY, coinScale, coinScale, 0, c_white, 1)

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
}

// анель списка товаров 
function Shop(_config) constructor {
    x = _config[$ "x"] ?? 0
    y = _config[$ "y"] ?? 0
    w = _config[$ "w"] ?? 200
    h = _config[$ "h"] ?? 200

    tabs = _config[$ "tabs"] ?? []
    tabFonts = _config[$ "tabFonts"] ?? undefined
    activeTab = 0

    cols = 1
    slots = _config[$ "slots"] ?? []
    padding = _config[$ "padding"] ?? 8
    tabH = _config[$ "tabH"] ?? 18
    tabGap = _config[$ "tabGap"] ?? 2
    tabPadding = _config[$ "tabPadding"] ?? 4
    rowHeight = _config[$ "rowHeight"] ?? 60 // высота строки-товара в дизайн-px

    onSlotClick = _config[$ "onSlotClick"] ?? undefined
    onTabClick = _config[$ "onTabClick"] ?? undefined
    onPanelSwitch = _config[$ "onPanelSwitch"] ?? undefined

    scrollY = 0
    scrollable = _config[$ "scrollable"] ?? true
    totalRows = array_length(slots)

    // прямоугольники вкладок 
    tabRects = _config[$ "tabRects"] ?? undefined

    cursorRow = 0
    selectedSlot = -1
    hoverSlot = -1
    mouseLastX = -1 // для детекта движения мыши 
    mouseLastY = -1
    uiScale = 1
    focused = true
    onTabRow = false
    justGainedFocus = false

    // Раскладка списка
    static computeLayout = function() {
        var gridX = x + padding
        var gridY = y + padding
        var gridW = w - padding * 2
        var rowH = rowHeight * uiScale
        var gapY = padding * 0.6
        return { gridX: gridX, gridY: gridY, rowW: gridW, rowH: rowH, gapY: gapY }
    }

    static rowPitch = function() {
        var l = computeLayout()
        return l.rowH + l.gapY
    }

    static scrollMax = function() {
        var l = computeLayout()
        var contentBottom = l.gridY + (array_length(slots) - 1) * (l.rowH + l.gapY) + l.rowH
        var visibleBottom = y + h - padding
        return max(0, contentBottom - visibleBottom)
    }

    static refreshScroll = function() {
        totalRows = array_length(slots)
        if (!scrollable) { scrollY = 0; return }
        scrollY = clamp(scrollY, 0, scrollMax())
    }

    static scrollToRow = function(row) {
        if (!scrollable) return
        var l = computeLayout()
        var pitch = l.rowH + l.gapY
        var rowTop = l.gridY + row * pitch
        var rowBottom = rowTop + l.rowH
        var visTop = l.gridY
        var visBottom = y + h - padding
        if (rowTop - scrollY < visTop) scrollY = rowTop - visTop
        else if (rowBottom - scrollY > visBottom) scrollY = rowBottom - visBottom
        refreshScroll()
    }

    static getSlotRect = function(index) {
        var l = computeLayout()
        var slotY = l.gridY + index * (l.rowH + l.gapY) - scrollY
        return { sx: l.gridX, sy: slotY, sw: l.rowW, sh: l.rowH }
    }

    // Вкладки
    static getTabWidths = function() {
        var tabsCount = array_length(tabs)
        var widths = array_create(tabsCount, 0)
        var total = 0
        var prevFont = draw_get_font()
        for (var i = 0; i < tabsCount; i++) {
            var spr = tabs[i][$ "sprite"]
            var sc = uiTextScale(tabs[i].name, tabH * 0.8, 1000000)
            var textNeed = string_width(tabs[i].name) * sc + tabPadding * 2
            var tabWidth = (spr != undefined)
                ? max(textNeed, tabH * sprite_get_width(spr) / sprite_get_height(spr))
                : textNeed
            widths[i] = tabWidth
            total += tabWidth
        }
        draw_set_font(prevFont)
        var avail = w - tabGap * max(0, tabsCount - 1)
        var k = (total > avail && total > 0) ? avail / total : 1
        return { widths: widths, k: k }
    }

    static getTabRect = function(index) {
        if (tabRects != undefined && index < array_length(tabRects)) return tabRects[index]

        var tabsCount = array_length(tabs)
        if (tabsCount == 0) return { tx: x, ty: y - tabH, tw: 0, th: tabH }
        var tw = getTabWidths()
        var tabX = x
        for (var i = 0; i < index; i++) tabX += tw.widths[i] * tw.k + tabGap
        return { tx: tabX, ty: y - tabH, tw: tw.widths[index] * tw.k, th: tabH }
    }

    // Фокус
    static selectAtCursor = function() {
        cursorRow = clamp(cursorRow, 0, max(0, array_length(slots) - 1))
        selectedSlot = cursorRow
        scrollToRow(cursorRow)
    }

    static enterFromLeft = function(row) {
        focused = true
        onTabRow = false
        cursorRow = clamp(row, 0, max(0, array_length(slots) - 1))
        selectAtCursor()
        justGainedFocus = true
    }
    static enterFromRight = function(row) { enterFromLeft(row) }

    static step = function() {
        if (!focused) return
        stepKeyboard()
    }

    static stepKeyboard = function() {
        if (justGainedFocus) { justGainedFocus = false; return }
        var nTabs = array_length(tabs)

        if (onTabRow) {
            if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
                if (nTabs > 0) { activeTab = max(0, activeTab - 1); if (onTabClick != undefined) onTabClick(self, activeTab) }
            }
            if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
                if (nTabs > 0) { activeTab = min(nTabs - 1, activeTab + 1); if (onTabClick != undefined) onTabClick(self, activeTab) }
            }
            if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")) ||
                keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
                onTabRow = false
                cursorRow = max(0, floor(scrollY / rowPitch()))
                selectAtCursor()
            }
            return
        }

        var moved = false
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
            if (cursorRow == 0 && nTabs > 0) { onTabRow = true; return }
            cursorRow = max(0, cursorRow - 1); moved = true
        }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
            cursorRow = min(array_length(slots) - 1, cursorRow + 1); moved = true
        }
        if (moved) selectAtCursor()

        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            if (selectedSlot >= 0 && selectedSlot < array_length(slots)) {
                var slot = slots[selectedSlot]
                if (slot.state != "locked" && onSlotClick != undefined) onSlotClick(self, selectedSlot)
            }
        }

        if (nTabs > 0) {
            if (keyboard_check_pressed(ord("Q"))) { activeTab = max(0, activeTab - 1); if (onTabClick != undefined) onTabClick(self, activeTab) }
            if (keyboard_check_pressed(ord("E"))) { activeTab = min(nTabs - 1, activeTab + 1); if (onTabClick != undefined) onTabClick(self, activeTab) }
        }
    }

    static stepMouse = function() {
        hoverSlot = -1
        var mx = device_mouse_x_to_gui(0)
        var my = device_mouse_y_to_gui(0)
        var moved = (mx != mouseLastX || my != mouseLastY) // мышь двигается?
        mouseLastX = mx
        mouseLastY = my
        var clicked = mouse_check_button_pressed(mb_left)

        // Вкладки 
        for (var t = 0; t < array_length(tabs); t++) {
            var tr = getTabRect(t)
            if (pointInRect(mx, my, tr.tx, tr.ty, tr.tw, tr.th)) {
                if (clicked) { focused = true; onTabRow = true; activeTab = t; if (onTabClick != undefined) onTabClick(self, t) }
                return true
            }
        }

        // в пределах панели списка
        if (!pointInRect(mx, my, x, y, w, h)) return false

        if (scrollable) {
            var wheelStep = rowPitch() * 0.5
            if (mouse_wheel_down()) scrollY = clamp(scrollY + wheelStep, 0, scrollMax())
            if (mouse_wheel_up())   scrollY = clamp(scrollY - wheelStep, 0, scrollMax())
        }

        // товары
        for (var i = 0; i < array_length(slots); i++) {
            var sr = getSlotRect(i)
            if (pointInRect(mx, my, sr.sx, sr.sy, sr.sw, sr.sh)) {
                hoverSlot = i
                if (moved) {
                    selectedSlot = i
                    cursorRow = i
                    onTabRow = false
                }
                if (clicked) {
                    focused = true
                    onTabRow = false
                    selectedSlot = i
                    cursorRow = i
                    var slot = slots[i]
                    if (slot.state != "locked" && onSlotClick != undefined) onSlotClick(self, i)
                }
                break
            }
        }
        return true
    }

    // Отрисовка (в Draw GUI)
    static draw = function() {
        var oldFont = draw_get_font()

        // фон
        draw_sprite_stretched(box, 0, x, y, w, h)

        // Клип списка по прямоугольнику контейнера
        var prevScissor = gpu_get_scissor()
        var padTop = padding
        gpu_set_scissor(floor(x + padding), floor(y + padTop),
                        ceil(w - padding * 2), ceil(h - padTop - padding))

        for (var i = 0; i < array_length(slots); i++) {
            drawShopItem(slots[i], getSlotRect(i), uiScale)
        }

        // Обводка выделенного товара
        if (selectedSlot >= 0 && selectedSlot < array_length(slots)) {
            var sr = getSlotRect(selectedSlot)
            var ow = max(2, round(uiScale * 3)) // толщина обводки
            draw_set_color(c_yellow)
            for (var k = 0; k < ow; k++) {
                draw_rectangle(sr.sx + k, sr.sy + k, sr.sx + sr.sw - 1 - k, sr.sy + sr.sh - 1 - k, true)
            }
            draw_set_color(c_white)
        }

        gpu_set_scissor(prevScissor)

        // Вкладки 
        for (var ti = 0; ti < array_length(tabs); ti++) {
            var tab = tabs[ti]
            var tr = getTabRect(ti)
            var isActive = (ti == activeTab)

            if (tab[$ "sprite"] != undefined) {
                var sub = min(isActive ? 1 : 0, sprite_get_number(tab.sprite) - 1)
                draw_set_alpha(isActive ? 1.0 : 0.6)
                draw_sprite_stretched(tab.sprite, sub, tr.tx, tr.ty, tr.tw, tr.th)
                draw_set_alpha(1.0)
            } else {
                draw_set_color(tab[$ "color"] ?? c_gray)
                draw_set_alpha(isActive ? 1.0 : 0.6)
                draw_rectangle(tr.tx, tr.ty, tr.tx + tr.tw - 1, tr.ty + tr.th - 1, false)
                draw_set_alpha(1.0)
            }

            draw_set_font(uiFont())
            draw_set_color(tab[$ "textColor"] ?? c_white)
            draw_set_halign(fa_center)
            draw_set_valign(fa_middle)
            var labelScale = uiTextScale(tab.name, tr.th * 0.55, tr.tw - tabPadding * 2)
            draw_text_transformed(tr.tx + tr.tw / 2, tr.ty + tr.th / 2, tab.name, labelScale, labelScale, 0)
            draw_set_halign(fa_left)
            draw_set_valign(fa_top)
        }

        draw_set_color(c_white)
        draw_set_font(oldFont)
    }
}
