
dbBaseW = camera_get_view_width(view_camera[0])
dbBaseH = camera_get_view_height(view_camera[0])
display_set_gui_size(dbBaseW, dbBaseH)

activePanel = 0 // 0 = коллекция всех карт, 1 = дека

var tabFonts = [fnUI_48, fnUI_32, fnUI_24, fnUI_16,
                 fnUI_14, fnUI_12, fnUI_10,  fnUI_8]

// Смена фокуса панели на определнную строку
switchFocusTo = function(target, row) {
    with (oDeckBuilder) {
        var src = (target.tag == Panels.Collection) ? deckPanel : collectionPanel
        collectionPanel.focused = (target.tag == Panels.Collection)
        deckPanel.focused = (target.tag == Panels.Deck)
        activePanel = (target.tag == Panels.Collection) ? Panels.Collection : Panels.Deck
        if (target.x < src.x) target.enterFromRight(row)
        else target.enterFromLeft(row)
    }
}

// Смена фокуса панелей
panelSwitchCallback = function(panel, direction) {
    with (oDeckBuilder) {
        var otherPanel = (panel.tag == Panels.Collection) ? deckPanel : collectionPanel
        if ((direction > 0 && panel.x < otherPanel.x) 
            || (direction < 0 && panel.x > otherPanel.x)) {
            switchFocusTo(otherPanel, panel.cursorRow)
        }
    }
}

editingCharacter = Characters.Lana // Персонаж, чья дека отображается/редактируется

categoryForTab = function(tab) { // Мап индекса таба фильтра в категорию карт
    switch (tab) {
        case 0: return CardCategory.Magic
        case 1: return CardCategory.Buff
        case 2: return CardCategory.Heal
        case 3: return CardCategory.Attack
        case 4: return CardCategory.Special
        default: return undefined
    }
}

// Панель коллекции всех карт 
collectionPanel = new Panel({
    x: 0, y: 0, w: 0, h: 0,
    bgSprite: box2,
    slotSpriteEmpty: EmptyCard,
    slotSpriteLocked: LockedCard,
    selectSprite: sprCardSelected,
    pointerSprite: sPointer,
    tabFonts: tabFonts,
    tabs: [
        { name: "MAGIC", sprite: MagicBtn, color: #9944CC },
        { name: "BUFF", sprite: BuffBtn, color: #CC44CC },
        { name: "HEAL", sprite: HealBtn, color: #44CC44 },
        { name: "ATTACK", sprite: AttackBtn, color: #CC4444 },
        { name: "SPECIAL", sprite: SpecialBtn, color: c_white, textColor: c_black }
    ],
    visibleRows: 3,
    slots: buildCollectionSlots(CardCategory.Magic),
    onTabClick: function(panel, tabIndex) {
        with (oDeckBuilder) {
            var category = categoryForTab(tabIndex)
            panel.slots = buildCollectionSlots(category, 4, editingCharacter)
            panel.scrollY = 0
            panel.cursorRow = 0
            panel.cursorCol = 0
            panel.refreshScroll()
            panel.selectAtCursor()
        }
    },
    // Клик/Enter по карте коллекции добавляет в первый свободный слот деки
    onSlotClick: function(panel, slotIndex) {
        with (oDeckBuilder) {
            if (slotIndex < 0 || slotIndex >= array_length(panel.slots)) { // Если индекс слота не существует
                return
            }
            var src = panel.slots[slotIndex]
            // Если в слоте нет карты, или карта не существует, или слот залоченный
            if (src.state != "filled" || src.ref == undefined || !src.addable) { 
                return
            }

            var freeSlot = firstFreeDeckSlot(editingCharacter) // Ищем свободный слот в деке
            if (freeSlot < 0) {
                return // свободных слотов деки нет
            } 
            // Добавление карты в слот и проверка, добавился ли
            if (setDeckSlot(editingCharacter, freeSlot, src.ref.id, src.ref.rarity)) {
                // Если добавился, обновляем коллекцию сотов текущего персонажа 
                deckPanel.slots = buildDeckSlots(editingCharacter)
                refreshCollection() // Обновляем визуал
                playerDataSave() // Сохраняем все
            }
        }
    },
    onPanelSwitch: panelSwitchCallback
})
collectionPanel.tag = Panels.Collection

// Панель деки
deckPanel = new Panel({
    x: 0, y: 0, w: 0, h: 0,
    bgSprite: box3,
    slotSpriteEmpty: EmptyCard,
    slotSpriteLocked: LockedCard,
    selectSprite: sprCardSelected,
    pointerSprite: sPointer,
    tabFonts: tabFonts,
    tabs: [
        // icon — портрет поверх кнопки
        // iconOffsetX — сдвиг иконки
        // btnOffsetX — сдвиг кнопки вправо 
        // textInset — сдвиг текста вправо
        { name: "LANA", sprite: LanaBtn, icon: LanaIcon, iconOffsetX: 0, btnOffsetX: 0.5,
          color: #4488CC, textInset: 1.3 },
        { name: "VIV", sprite: VivBtn, icon: VivIcon, iconOffsetX: 0, btnOffsetX: 0.5,
          color: #44CC88, textInset: 1.3 }
    ],
    scrollable: false, 
    slots: buildDeckSlots(Characters.Lana),
    onTabClick: function(panel, tabIndex) {
        with (oDeckBuilder) {
            editingCharacter = (tabIndex == 0) ? Characters.Lana : Characters.Viv
            panel.slots = buildDeckSlots(editingCharacter)
            panel.scrollY = 0
            panel.cursorRow = 0
            panel.cursorCol = 0
            panel.refreshScroll()
            panel.selectAtCursor()
            // при смене деки перестраиваем коллекцию
            refreshCollection()
        }
    },
    // Клик/Enter по карте в деке убирает её из деки
    onSlotClick: function(panel, slotIndex) {
        with (oDeckBuilder) {
            // Проверка на правильность индекса слота
            if (slotIndex < 0 || slotIndex >= array_length(panel.slots)) {
                return
            }
            var slot = panel.slots[slotIndex]
            // Если карты нет в слоте, ничего не делаем
            if (slot.state != "filled") {
                 return 
            }
            clearDeckSlot(editingCharacter, slotIndex) // Убираем карту из слота
            panel.slots = buildDeckSlots(editingCharacter) // Перестраиваем слоты
            refreshCollection() // Обновляем визуал
            playerDataSave() // Обновляем данные пользователя
        }
    },
    onPanelSwitch: panelSwitchCallback
})
deckPanel.tag = Panels.Deck

// Сфокусировать конкретную панель (используется мышью)
focusPanel = function(panel) {
    collectionPanel.focused = (panel == collectionPanel)
    deckPanel.focused = (panel == deckPanel)
    activePanel = (panel == collectionPanel) ? Panels.Collection : Panels.Deck
}

// Перестроить панель коллекции под текущую категорию и открытую деку
refreshCollection = function() {
    var category = categoryForTab(collectionPanel.activeTab)
    collectionPanel.slots = buildCollectionSlots(category, 4, editingCharacter)
    collectionPanel.refreshScroll()
    if (collectionPanel.selectedSlot >= array_length(collectionPanel.slots))
        collectionPanel.selectedSlot = -1
}

// Верстает обе панели
layoutPanels = function() {
    var scaleUI = display_get_gui_width() / dbBaseW
    var margin  = 8  * scaleUI // внешний отступ
    // Высота вкладок: 44 px арта при окне шириной 1366, дальше скейлится пропорционально окну
    var tabHeight = 44 * (display_get_gui_width() / 1366)
    var panelWidth = (dbBaseW * scaleUI - margin * 2) / 2
    var top = margin + tabHeight
    var panelHeight  = dbBaseH * scaleUI - top - margin

    var panels = [collectionPanel, deckPanel]
    for (var i = 0; i < 2; i++) {
        var panel = panels[i]
        panel.x = margin + i * panelWidth
        panel.y = top
        panel.w = panelWidth
        panel.h = panelHeight
        panel.padding = 8 * scaleUI
        panel.tabH = tabHeight
        panel.tabGap = 2 * scaleUI
        panel.tabPadding = 4 * scaleUI
        panel.uiScale = scaleUI 
    }
    // отступ вкладок слева от края панели 
    collectionPanel.tabOffsetX = 0
    deckPanel.tabOffsetX = 0
}
layoutPanels()

// Инициализация панелей
collectionPanel.focused = true
deckPanel.focused = false
collectionPanel.enterFromLeft(0)
activePanel = Panels.Collection

open = false

openBuilder = function() {
    setCrispGui(dbBaseW, dbBaseH)
    layoutPanels()
    open = true
    global.uiModal = true
    collectionPanel.slots = buildCollectionSlots(categoryForTab(collectionPanel.activeTab), 4, editingCharacter)
    collectionPanel.scrollY = 0
    collectionPanel.refreshScroll()
    deckPanel.slots = buildDeckSlots(editingCharacter)
    deckPanel.scrollY = 0
    deckPanel.refreshScroll()

    collectionPanel.focused = true
    deckPanel.focused = false
    collectionPanel.enterFromLeft(0)
    activePanel = Panels.Collection
}

closeBuilder = function() {
    open = false
    global.uiModal = false
    display_set_gui_size(dbBaseW, dbBaseH)
}