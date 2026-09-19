enum ShopCategory { Cards, OtherItems }

// Модель товара магазина
// kind: ShopItemKind.Card или ShopItemKind.Slot
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
    return floor(SHOP_SLOT_BASE * power(SHOP_SLOT_GROWTH, max(0, purchased)))
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
            var shopItem = new ShopItem(ShopItemKind.Card, SHOP_CARD_PRICE)
            shopItem.card = card
            shopItem.ref = { id: refs[i].id, rarity: refs[i].rarity }
            array_push(items, shopItem)
        }
    } else {
        // Расширение слотов деки 
        if (deckOf(Characters.Lana).unlocked < deckSlotLimit()) {
            var shopItem = new ShopItem(ShopItemKind.Slot, deckSlotUpgradePrice())
            shopItem.label = "New deck slot"
            array_push(items, shopItem)
        }
    }
    return items
}

// Текстовые строки описания товара
function shopItemLines(item) {
    var lines = []

    if (item.kind == ShopItemKind.Slot) {
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

// Отрисовка одной строки-товара в прямоугольнике rect {left,top,width,height}
function drawShopItem(item, rect, uiScale) {
    // рамка товара
    draw_sprite_stretched(ItemShadow, 0, rect.left, rect.top, rect.width, rect.height)

    var pad = rect.height * 0.12
    var contentH = rect.height - pad * 2
    var textX = rect.left + pad
    var textTop = rect.top + pad

    // карта слева
    if (item.kind == ShopItemKind.Card && item.card != undefined) {
        var cardH = contentH
        var cardW = cardH * 2 / 3
        drawCardFace(item.card, rect.left + pad + cardW * 0.5, textTop + cardH * 0.5, cardW, cardH, 0)
        textX = rect.left + pad + cardW + pad
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
    var coinH = rect.height * 0.34
    var coinScale = coinH / sprite_get_height(CoinIcon)
    var coinW = sprite_get_width(CoinIcon) * coinScale
    var coinCX = rect.left + rect.width - pad - coinW * 0.5
    var coinCY = rect.top + rect.height * 0.5

    var priceStr = string(item.price)
    draw_set_halign(fa_right)
    draw_set_valign(fa_middle)
    draw_set_color(c_white)
    var priceScale = uiTextScale(priceStr, coinH * 0.9, rect.width * 0.2)
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
        var layout = computeLayout()
        return layout.rowH + layout.gapY
    }

    static scrollMax = function() {
        var layout = computeLayout()
        var contentBottom = layout.gridY + (array_length(slots) - 1) * (layout.rowH + layout.gapY) + layout.rowH
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
        var layout = computeLayout()
        var pitch = layout.rowH + layout.gapY
        var rowTop = layout.gridY + row * pitch
        var rowBottom = rowTop + layout.rowH
        var visTop = layout.gridY
        var visBottom = y + h - padding
        if (rowTop - scrollY < visTop) scrollY = rowTop - visTop
        else if (rowBottom - scrollY > visBottom) scrollY = rowBottom - visBottom
        refreshScroll()
    }

    static getSlotRect = function(index) {
        var layout = computeLayout()
        var slotY = layout.gridY + index * (layout.rowH + layout.gapY) - scrollY
        return { left: layout.gridX, top: slotY, width: layout.rowW, height: layout.rowH }
    }

    // Вкладки
    static getTabWidths = function() {
        var tabsCount = array_length(tabs)
        var widths = array_create(tabsCount, 0)
        var total = 0
        var prevFont = draw_get_font()
        for (var i = 0; i < tabsCount; i++) {
            var tabSprite = tabs[i][$ "sprite"]
            var tabNameScale = uiTextScale(tabs[i].name, tabH * 0.8, 1000000)
            var textNeed = string_width(tabs[i].name) * tabNameScale + tabPadding * 2
            var tabWidth = (tabSprite != undefined)
                ? max(textNeed, tabH * sprite_get_width(tabSprite) / sprite_get_height(tabSprite))
                : textNeed
            widths[i] = tabWidth
            total += tabWidth
        }
        draw_set_font(prevFont)
        var avail = w - tabGap * max(0, tabsCount - 1)
        var shrinkFactor = (total > avail && total > 0) ? avail / total : 1
        return { widths: widths, shrink: shrinkFactor }
    }

    static getTabRect = function(index) {
        if (tabRects != undefined && index < array_length(tabRects)) return tabRects[index]

        var tabsCount = array_length(tabs)
        if (tabsCount == 0) return { left: x, top: y - tabH, width: 0, height: tabH }
        var tabWidths = getTabWidths()
        var tabX = x
        for (var i = 0; i < index; i++) tabX += tabWidths.widths[i] * tabWidths.shrink + tabGap
        return { left: tabX, top: y - tabH, width: tabWidths.widths[index] * tabWidths.shrink, height: tabH }
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
        if (!focused) { return } 
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
        var mouseX = device_mouse_x_to_gui(0)
        var mouseY = device_mouse_y_to_gui(0)
        var moved = (mouseX != mouseLastX || mouseY != mouseLastY) // мышь двигается?
        mouseLastX = mouseX
        mouseLastY = mouseY
        var clicked = mouse_check_button_pressed(mb_left)

        // Вкладки 
        for (var tabIndex = 0; tabIndex < array_length(tabs); tabIndex++) {
            var tabRect = getTabRect(tabIndex)
            if (pointInRect(mouseX, mouseY, tabRect.left, tabRect.top, tabRect.width, tabRect.height)) {
                if (clicked) { focused = true; onTabRow = true; activeTab = tabIndex; if (onTabClick != undefined) onTabClick(self, tabIndex) }
                return true
            }
        }

        // в пределах панели списка
        if (!pointInRect(mouseX, mouseY, x, y, w, h)) return false

        if (scrollable) {
            var wheelStep = rowPitch() * 0.5
            if (mouse_wheel_down()) scrollY = clamp(scrollY + wheelStep, 0, scrollMax())
            if (mouse_wheel_up())   scrollY = clamp(scrollY - wheelStep, 0, scrollMax())
        }

        // товары
        for (var i = 0; i < array_length(slots); i++) {
            var slotRect = getSlotRect(i)
            if (pointInRect(mouseX, mouseY, slotRect.left, slotRect.top, slotRect.width, slotRect.height)) {
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
        guiSetScissor(x + padding, y + padTop, w - padding * 2, h - padTop - padding)

        for (var i = 0; i < array_length(slots); i++) {
            drawShopItem(slots[i], getSlotRect(i), uiScale)
        }

        gpu_set_scissor(prevScissor)

        // Вкладки 
        for (var tabIndex = 0; tabIndex < array_length(tabs); tabIndex++) {
            var tab = tabs[tabIndex]
            var tabRect = getTabRect(tabIndex)
            var isActive = (tabIndex == activeTab)

            if (tab[$ "sprite"] != undefined) {
                var subimage = min(isActive ? 1 : 0, sprite_get_number(tab.sprite) - 1)
                draw_set_alpha(isActive ? 1.0 : 0.6)
                draw_sprite_stretched(tab.sprite, subimage, tabRect.left, tabRect.top, tabRect.width, tabRect.height)
                draw_set_alpha(1.0)
            } else {
                draw_set_color(tab[$ "color"] ?? c_gray)
                draw_set_alpha(isActive ? 1.0 : 0.6)
                draw_rectangle(tabRect.left, tabRect.top, tabRect.left + tabRect.width - 1, tabRect.top + tabRect.height - 1, false)
                draw_set_alpha(1.0)
            }

            draw_set_font(uiFont())
            draw_set_color(tab[$ "textColor"] ?? c_white)
            draw_set_halign(fa_center)
            draw_set_valign(fa_middle)
            var labelScale = uiTextScale(tab.name, tabRect.height * 0.55, tabRect.width - tabPadding * 2)
            draw_text_transformed(tabRect.left + tabRect.width / 2, tabRect.top + tabRect.height / 2, tab.name, labelScale, labelScale, 0)
            draw_set_halign(fa_left)
            draw_set_valign(fa_top)
        }

        draw_set_color(c_white)
        draw_set_font(oldFont)
    }
}
