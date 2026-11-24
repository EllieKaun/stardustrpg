enum ShopCategory { Cards, OtherItems }

// Модель товара магазина
// kind: ShopItemKind.Card или ShopItemKind.Slot
function ShopItem(_kind, _price) constructor {
    kind = _kind
    price = _price
    card = undefined // для карт
    ref = undefined // { id, rarity } для карт
    label = "" // подпись (для слотов)
    character = undefined
    descLines = []
    cardSet = undefined
    state = "filled"
}

function shopPackSets() {
    return [CardSet.Base, CardSet.Forest]
}

function packUnlocked(cardSet) {
    if (cardSet == CardSet.Forest) { return variable_global_exists("foxJoined") && global.foxJoined }
    return true
}

function packShopInfo(cardSet) {
    if (cardSet == CardSet.Forest) {
        return { sprite: sprBoosterForest, title: loc("shop.packForest"), desc: loc("shop.packForestDesc") }
    }
    return { sprite: sprBoosterStars, title: loc("shop.packStar"), desc: loc("shop.packStarDesc") }
}

function packPoolSpec(cardSet) {
    var content = zoneContent()
    var ids = []
    if (cardSet == CardSet.Forest) {
        appendRewardIds(ids, content.rewardForestSet)
    } else {
        appendRewardIds(ids, content.rewardAlways)
        appendRewardIds(ids, content.rewardNightOnly)
        appendRewardIds(ids, content.rewardAfterBoss)
    }
    return { ids: ids, rarities: content.rewardRarities }
}

function openCardPack(cardSet) {
    var spec = packPoolSpec(cardSet)
    if (array_length(spec.ids) == 0) { return undefined }
    var ref = rollOneReward(spec)
    unlockCard(ref.id, ref.rarity, 1)
    playerDataSave()
    var card = cardFromRef(ref)
    showCardReward(card, loc("ui.newCard") + " " + cardDisplayName(card))
    return ref
}

// Цена следующего расширения слота деки x1.5
function deckSlotUpgradePrice(character = Characters.Lana) {
    var purchased = deckOf(character).unlocked - deckDefaultUnlocked(character)
    return floor(SHOP_SLOT_BASE * power(SHOP_SLOT_GROWTH, max(0, purchased)))
}

// Карты, которые нельзя выставлять на продажу в магазине
function shopNonSellableIds() {
    return [ global.CardId.stealCard ]
}

function cardShopSellable(cardId) {
    var nonSellableIds = shopNonSellableIds()
    for (var i = 0; i < array_length(nonSellableIds); i++) {
        if (nonSellableIds[i] == cardId) { return false }
    }
    return true
}

// Список товаров для категории
function buildShopItems(category) {
    var items = []

    if (category == ShopCategory.Cards) {
        var packSets = shopPackSets()
        for (var packIndex = 0; packIndex < array_length(packSets); packIndex++) {
            var packSet = packSets[packIndex]
            if (!packUnlocked(packSet)) { continue }
            var packInfo = packShopInfo(packSet)
            var packItem = new ShopItem(ShopItemKind.Pack, SHOP_PACK_PRICE)
            packItem.cardSet = packSet
            packItem.label = packInfo.title
            packItem.descLines = [packInfo.desc]
            array_push(items, packItem)
        }
    } else {
        // Расширение слотов деки 
        if (deckOf(Characters.Lana).unlocked < deckSlotLimit()) {
            var shopItem = new ShopItem(ShopItemKind.Slot, deckSlotUpgradePrice())
            shopItem.label = loc("shop.newSlot")
            shopItem.descLines = [loc("shop.slotDesc1"), loc("shop.slotDesc2")]
            array_push(items, shopItem)
        }
        var companions = [Characters.Safar, Characters.Fox]
        for (var companionIndex = 0; companionIndex < array_length(companions); companionIndex++) {
            var companion = companions[companionIndex]
            if (!companionUnlocked(companion)) { continue }
            if (deckOf(companion).unlocked >= deckSlotLimitFor(companion)) { continue }
            var companionItem = new ShopItem(ShopItemKind.Slot, deckSlotUpgradePrice(companion))
            companionItem.character = companion
            companionItem.label = loc("shop.newSlot")
            companionItem.descLines = [loc("shop.slotDesc1"), loc(companion == Characters.Safar ? "shop.slotDescSafar" : "shop.slotDescFox")]
            array_push(items, companionItem)
        }
    }
    return items
}

// Текстовые строки описания товара
function shopItemLines(item) {
    var lines = []

    if (item.kind == ShopItemKind.Slot || item.kind == ShopItemKind.Pack) {
        array_push(lines, item.label)
        for (var descIndex = 0; descIndex < array_length(item.descLines); descIndex++) {
            array_push(lines, item.descLines[descIndex])
        }
        return lines
    }

    var card = item.card
    array_push(lines, loc("shop.type") + (card.actionType == StarriorStates.Attack ? loc("shop.typeAtc") : loc("shop.typeCast")))

    var costLabel = (card.costType() == CostType.Mana) ? loc("shop.mp") : loc("shop.hp")
    array_push(lines, loc("shop.cost") + string(card.costValue()) + costLabel)

    // тип урона (если есть урон)
    for (var i = 0; i < array_length(card.effects); i++) {
        var effect = card.effects[i]
        if (variable_struct_exists(effect, "type") && effect.type == EffectTypes.Damage) {
            array_push(lines, loc("shop.damageType") + (effect.damageType == DamageTypes.Magical ? loc("shop.magical") : loc("shop.physical")))
            break
        }
    }
    array_push(lines, cardDisplayDesc(card))
    return lines
}

#macro SHOP_ITEM_FRAME_INSET 6 // ширина рамки ItemShadow в пикселях GUI
#macro SHOP_TITLE_LINE_H 0.22 // высота строки названия пака/слота (доля высоты содержимого)
#macro SHOP_PRICE_H 0.26 // высота цены и монеты
#macro SHOP_DESC_LINE_H 0.17 // высота строки описания пака/слота
#macro SHOP_POINTER_SIZE 0.28 // размер пальца у выбранного товара (доля высоты товара)
#macro SHOP_CARD_MIN_LINES 4 // на сколько строк делится высота у карты; меньше - крупнее текст

// Картинка товара слева на карточке
function shopItemImage(item) {
    if (item.kind == ShopItemKind.Pack) { return packShopInfo(item.cardSet).sprite }
    if (item.kind == ShopItemKind.Slot) { return CardBack }
    return noone
}

// Карточка пака/слота в стиле бустера: рамка товара, картинка слева, текст справа
function drawShopCard(item, rect, isSelected) {
    var L = rect.left, T = rect.top, W = rect.width, H = rect.height
    draw_sprite_stretched(ItemShadow, 0, L, T, W, H)

    var inset = SHOP_ITEM_FRAME_INSET
    var panelL = L + inset, panelT = T + inset
    var panelW = W - inset * 2, panelH = H - inset * 2
    var pad = panelH * 0.08
    var contentT = panelT + pad
    var contentH = panelH - pad * 2

    var spr = shopItemImage(item)
    var rightL = panelL + pad
    if (spr != noone) {
        var scl = contentH / sprite_get_height(spr)
        var maxImgW = panelW * 0.42
        if (sprite_get_width(spr) * scl > maxImgW) { scl = maxImgW / sprite_get_width(spr) }
        var imgW = sprite_get_width(spr) * scl
        draw_sprite_ext(spr, 0, panelL + pad + imgW * 0.5, contentT + contentH * 0.5, scl, scl, 0, c_white, 1)
        rightL = panelL + pad + imgW + pad
    }

    var rightW = (panelL + panelW - pad) - rightL
    var prevFont = draw_get_font()
    draw_set_color(c_white)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)

    var titleFit = fitWrappedText(item.label, rightW, contentH * 0.32, contentH * SHOP_TITLE_LINE_H)
    draw_set_font(titleFit.font)
    draw_text_transformed(floor(rightL), floor(contentT), titleFit.text, titleFit.scale, titleFit.scale, 0)

    var priceStr = string(item.price)
    var coinH = contentH * SHOP_PRICE_H
    var coinScale = coinH / sprite_get_height(CoinIcon)
    var coinW = sprite_get_width(CoinIcon) * coinScale
    var priceCY = contentT + contentH * 0.5
    draw_set_font(uiFont())
    draw_set_valign(fa_middle)
    var pScale = uiTextScale(priceStr, coinH, rightW * 0.5)
    draw_text_transformed(floor(rightL), floor(priceCY), priceStr, pScale, pScale, 0)
    draw_sprite_ext(CoinIcon, 0, rightL + string_width(priceStr) * pScale + coinW * 0.6, priceCY, coinScale, coinScale, 0, c_white, 1)
    draw_set_valign(fa_top)

    var descText = ""
    for (var i = 0; i < array_length(item.descLines); i++) { descText += (i > 0 ? " " : "") + item.descLines[i] }
    var descFit = fitWrappedText(descText, rightW, contentH * 0.36, contentH * SHOP_DESC_LINE_H)
    draw_set_font(descFit.font)
    draw_text_transformed(floor(rightL), floor(contentT + contentH * 0.64), descFit.text, descFit.scale, descFit.scale, 0)

    draw_set_font(prevFont)
    draw_set_color(c_white)
}

// Отрисовка одной строки-товара в прямоугольнике rect {left,top,width,height}
function drawShopItem(item, rect, uiScale, isSelected = false) {
    if (item.kind == ShopItemKind.Pack || item.kind == ShopItemKind.Slot) {
        drawShopCard(item, rect, isSelected)
        return
    }

    // рамка товара
    draw_sprite_stretched(ItemShadow, 0, rect.left, rect.top, rect.width, rect.height)

    var padding = rect.height * 0.12
    var contentH = rect.height - padding * 2
    var textX = rect.left + padding
    var textTop = rect.top + padding

    // карта слева
    if (item.kind == ShopItemKind.Card && item.card != undefined) {
        var cardH = contentH
        var cardW = cardH * 2 / 3
        drawCardFace(item.card, rect.left + padding + cardW * 0.5, textTop + cardH * 0.5, cardW, cardH, 0, 1, 1, false)
        textX = rect.left + padding + cardW + padding
    }

    if (item.kind == ShopItemKind.Pack) {
        var packInfo = packShopInfo(item.cardSet)
        var packSpr = packInfo.sprite
        var packH = contentH
        var packScale = packH / sprite_get_height(packSpr)
        var packW = sprite_get_width(packSpr) * packScale
        draw_sprite_ext(packSpr, 0, rect.left + padding + packW * 0.5, textTop + packH * 0.5, packScale, packScale, 0, c_white, 1)
        textX = rect.left + padding + packW + padding
    }

    // описание
    var lines = shopItemLines(item)
    var lineH = contentH / max(SHOP_CARD_MIN_LINES, array_length(lines))
    var textMaxW = rect.left + rect.width * 0.7 - textX
    draw_set_font(uiFont())
    draw_set_color(c_white)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    for (var i = 0; i < array_length(lines); i++) {
        drawUiText(textX, textTop + i * lineH, lines[i], lineH * 0.85, textMaxW)
    }

    // цена
    var coinH = rect.height * 0.34
    var coinScale = coinH / sprite_get_height(CoinIcon)
    var coinW = sprite_get_width(CoinIcon) * coinScale
    var coinCX = rect.left + rect.width - padding - coinW * 0.5
    var coinCY = rect.top + rect.height * 0.5

    var priceStr = string(item.price)
    draw_set_halign(fa_right)
    draw_set_valign(fa_middle)
    draw_set_color(c_white)
    var priceScale = uiTextScale(priceStr, coinH * 0.9, rect.width * 0.2)
    draw_text_transformed(coinCX - coinW * 0.5 - padding * 0.4, coinCY, priceStr, priceScale, priceScale, 0)

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

    cols = _config[$ "cols"] ?? 1
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
    totalRows = ceil(array_length(slots) / cols)

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
    clipSurface = -1 // поверхность клипа списка (см. guiClipBegin)

    // Раскладка списка
    static computeLayout = function() {
        var gridX = x + padding
        var gridY = y + padding
        var gridW = w - padding * 2
        var rowH = rowHeight * uiScale
        var gapY = padding * 0.6
        var gapX = padding * 0.6
        var colW = (gridW - gapX * (cols - 1)) / cols
        return { gridX: gridX, gridY: gridY, rowW: gridW, colW: colW, rowH: rowH, gapX: gapX, gapY: gapY }
    }

    static rowPitch = function() {
        var layout = computeLayout()
        return layout.rowH + layout.gapY
    }

    static scrollMax = function() {
        var layout = computeLayout()
        var rowCount = ceil(array_length(slots) / cols)
        var contentBottom = layout.gridY + (rowCount - 1) * (layout.rowH + layout.gapY) + layout.rowH
        var visibleBottom = y + h - padding
        return max(0, contentBottom - visibleBottom)
    }

    static refreshScroll = function() {
        totalRows = ceil(array_length(slots) / cols)
        if (!scrollable) { scrollY = 0; return }
        scrollY = clamp(scrollY, 0, scrollMax())
    }

    static scrollToRow = function(row) {
        if (!scrollable) { return }
        var layout = computeLayout()
        var pitch = layout.rowH + layout.gapY
        var rowTop = layout.gridY + row * pitch
        var rowBottom = rowTop + layout.rowH
        var visTop = layout.gridY
        var visBottom = y + h - padding
        if (rowTop - scrollY < visTop) { scrollY = rowTop - visTop }
        else if (rowBottom - scrollY > visBottom) { scrollY = rowBottom - visBottom }
        refreshScroll()
    }

    static getSlotRect = function(index) {
        var layout = computeLayout()
        var column = index mod cols
        var row = index div cols
        var slotX = layout.gridX + column * (layout.colW + layout.gapX)
        var slotY = layout.gridY + row * (layout.rowH + layout.gapY) - scrollY
        return { left: slotX, top: slotY, width: layout.colW, height: layout.rowH }
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
        if (tabRects != undefined && index < array_length(tabRects)) { return tabRects[index] }

        var tabsCount = array_length(tabs)
        if (tabsCount == 0) { return { left: x, top: y - tabH, width: 0, height: tabH } }
        var tabWidths = getTabWidths()
        var tabX = x
        for (var i = 0; i < index; i++) tabX += tabWidths.widths[i] * tabWidths.shrink + tabGap
        return { left: tabX, top: y - tabH, width: tabWidths.widths[index] * tabWidths.shrink, height: tabH }
    }

    // Фокус
    static selectAtCursor = function() {
        cursorRow = clamp(cursorRow, 0, max(0, array_length(slots) - 1))
        selectedSlot = cursorRow
        scrollToRow(cursorRow div cols)
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
                if (nTabs > 0) { activeTab = max(0, activeTab - 1); if (onTabClick != undefined) { onTabClick(self, activeTab) } }
            }
            if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
                if (nTabs > 0) { activeTab = min(nTabs - 1, activeTab + 1); if (onTabClick != undefined) { onTabClick(self, activeTab) } }
            }
            if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")) ||
                keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
                onTabRow = false
                cursorRow = max(0, floor(scrollY / rowPitch())) * cols
                selectAtCursor()
            }
            return
        }

        var moved = false
        var lastIndex = array_length(slots) - 1
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
            if (cursorRow < cols && nTabs > 0) { onTabRow = true; return }
            cursorRow = max(0, cursorRow - cols); moved = true
        }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
            if (cursorRow + cols <= lastIndex) { cursorRow += cols }
            else if ((cursorRow div cols) < (lastIndex div cols)) { cursorRow = lastIndex }
            moved = true
        }
        if (cols > 1 && (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")))) {
            if ((cursorRow mod cols) > 0) { cursorRow -= 1; moved = true }
        }
        if (cols > 1 && (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")))) {
            if ((cursorRow mod cols) < cols - 1 && cursorRow < lastIndex) { cursorRow += 1; moved = true }
        }
        if (moved) { selectAtCursor() }

        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            if (selectedSlot >= 0 && selectedSlot < array_length(slots)) {
                var slot = slots[selectedSlot]
                if (slot.state != "locked" && onSlotClick != undefined) { onSlotClick(self, selectedSlot) }
            }
        }

        if (nTabs > 0) {
            if (keyboard_check_pressed(ord("Q"))) { activeTab = max(0, activeTab - 1); if (onTabClick != undefined) { onTabClick(self, activeTab) } }
            if (keyboard_check_pressed(ord("E"))) { activeTab = min(nTabs - 1, activeTab + 1); if (onTabClick != undefined) { onTabClick(self, activeTab) } }
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
                if (clicked) { focused = true; onTabRow = true; activeTab = tabIndex; if (onTabClick != undefined) { onTabClick(self, tabIndex) } }
                return true
            }
        }

        // в пределах панели списка
        if (!pointInRect(mouseX, mouseY, x, y, w, h)) { return false }

        if (scrollable) {
            var wheelStep = rowPitch() * 0.5
            if (mouse_wheel_down()) { scrollY = clamp(scrollY + wheelStep, 0, scrollMax()) }
            if (mouse_wheel_up()) {   scrollY = clamp(scrollY - wheelStep, 0, scrollMax()) }
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
                    if (slot.state != "locked" && onSlotClick != undefined) { onSlotClick(self, i) }
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
        var clipX = x + padding
        var clipY = y + padding
        var clipW = w - padding * 2
        var clipH = h - padding * 2
        clipSurface = guiClipBegin(clipSurface, clipX, clipY, clipW, clipH)

        var showSelection = focused && !onTabRow
        for (var i = 0; i < array_length(slots); i++) {
            var slotRect = getSlotRect(i)
            if (slotRect.top > clipY + clipH || slotRect.top + slotRect.height < clipY) { continue }
            drawShopItem(slots[i], slotRect, uiScale, showSelection && i == selectedSlot)
        }

        guiClipEnd(clipSurface, clipX, clipY)

        // Палец у выбранного товара, поверх клипа, чтобы не срезался у левой колонки
        if (showSelection && selectedSlot >= 0 && selectedSlot < array_length(slots)) {
            var selectedRect = getSlotRect(selectedSlot)
            var pointerCenterY = selectedRect.top + selectedRect.height * 0.5
            if (pointerCenterY > clipY && pointerCenterY < clipY + clipH) {
                var pointerScale = selectedRect.height * SHOP_POINTER_SIZE / sprite_get_height(sPointer)
                draw_sprite_ext(sPointer, 0, selectedRect.left, pointerCenterY, pointerScale, pointerScale, 0, c_white, 1)
            }
        }

        // Вкладки 
        for (var tabIndex = 0; tabIndex < array_length(tabs); tabIndex++) {
            var currentTab = tabs[tabIndex]
            var tabRect = getTabRect(tabIndex)
            var isActive = (tabIndex == activeTab)

            if (currentTab[$ "sprite"] != undefined) {
                var subimage = min(isActive ? 1 : 0, sprite_get_number(currentTab.sprite) - 1)
                draw_set_alpha(isActive ? 1.0 : 0.6)
                draw_sprite_stretched(currentTab.sprite, subimage, tabRect.left, tabRect.top, tabRect.width, tabRect.height)
                draw_set_alpha(1.0)
            } else {
                draw_set_color(currentTab[$ "color"] ?? c_gray)
                draw_set_alpha(isActive ? 1.0 : 0.6)
                draw_rectangle(tabRect.left, tabRect.top, tabRect.left + tabRect.width - 1, tabRect.top + tabRect.height - 1, false)
                draw_set_alpha(1.0)
            }

            draw_set_font(uiFont())
            draw_set_color(currentTab[$ "textColor"] ?? c_white)
            draw_set_halign(fa_center)
            draw_set_valign(fa_middle)
            var labelScale = uiTextScale(currentTab.name, tabRect.height * 0.55, tabRect.width - tabPadding * 2)
            draw_text_transformed(tabRect.left + tabRect.width / 2, tabRect.top + tabRect.height / 2, currentTab.name, labelScale, labelScale, 0)
            draw_set_halign(fa_left)
            draw_set_valign(fa_top)
        }

        draw_set_color(c_white)
        draw_set_font(oldFont)
    }
}
