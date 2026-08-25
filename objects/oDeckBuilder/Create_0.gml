
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
    bgSprite: box,
    slotSpriteEmpty: EmptyCardPlace,
    slotSpriteLocked: LockedCardPlace,
    selectSprite: sprCardSelected,
    pointerSprite: sPointer,
    tabFonts: tabFonts,
    tabs: [
        { name: "MAGIC", color: #9944CC },
        { name: "BUFF", color: #CC44CC },
        { name: "HEAL", color: #44CC44 },
        { name: "ATTACK", color: #CC4444 },
        { name: "SPECIAL", color: c_white, textColor: c_black }
    ],
    visibleRows: 3,
    slots: buildCollectionSlots(CardCategory.Magic),
    onTabClick: function(panel, tabIndex) {
        with (oDeckBuilder) {
            var category = categoryForTab(tabIndex)
            panel.slots = buildCollectionSlots(category)
            panel.scrollRow = 0
            panel.cursorRow = 0
            panel.cursorCol = 0
            panel.refreshScroll()
            panel.selectAtCursor()
        }
    },
    onSlotClick: function(panel, slotIndex) {
        with (oDeckBuilder) switchFocusTo(deckPanel, collectionPanel.cursorRow)
    },
    onPanelSwitch: panelSwitchCallback
})
collectionPanel.tag = Panels.Collection

// Панель деки
deckPanel = new Panel({
    x: 0, y: 0, w: 0, h: 0,
    bgSprite: box,
    slotSpriteEmpty: EmptyCardPlace,
    slotSpriteLocked: LockedCardPlace,
    selectSprite: sprCardSelected,
    pointerSprite: sPointer,
    tabFonts: tabFonts,
    tabs: [
        { name: "LANA", color: #4488CC },
        { name: "VIV", color: #44CC88 }
    ],
    visibleRows: 3,
    slots: buildDeckSlots(Characters.Lana),
    onTabClick: function(panel, tabIndex) {
        with (oDeckBuilder) {
            editingCharacter = (tabIndex == 0) ? Characters.Lana : Characters.Viv
            panel.slots = buildDeckSlots(editingCharacter)
            panel.scrollRow = 0
            panel.cursorRow = 0
            panel.cursorCol = 0
            panel.refreshScroll()
            panel.selectAtCursor()
        }
    },
    onSlotClick: function(panel, slotIndex) {
        with (oDeckBuilder) {
            if (collectionPanel.selectedSlot < 0) return
            var src = collectionPanel.slots[collectionPanel.selectedSlot]
            if (src.state != "filled" || src.ref == undefined) return
            
            if (setDeckSlot(editingCharacter, slotIndex, src.ref.id, src.ref.rarity)) {
                panel.slots = buildDeckSlots(editingCharacter)
                playerDataSave()
            } else {
                show_debug_message("setDeckSlot failed: id=" + string(src.ref.id)
                    + " rarity=" + string(src.ref.rarity)
                    + " slot=" + string(slotIndex)
                    + " unlocked=" + string(deckOf(editingCharacter).unlocked)) 
        }
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

// Верстает обе панели
layoutPanels = function() {
    var s = display_get_gui_width() / dbBaseW
    var mg  = 8  * s // внешний отступ
    var tH  = 18 * s // высота вкладок
    var pw  = (dbBaseW * s - mg * 2) / 2
    var top = mg + tH
    var ph  = dbBaseH * s - top - mg

    var panels = [collectionPanel, deckPanel]
    for (var i = 0; i < 2; i++) {
        var p = panels[i]
        p.x = mg + i * pw
        p.y = top
        p.w = pw
        p.h = ph
        p.padding = 8 * s
        p.tabH = tH
        p.tabGap = 2 * s
        p.tabPadding = 4 * s
        p.uiScale = s // для спрайтов фикс. размера
    }
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
    collectionPanel.slots = buildCollectionSlots(categoryForTab(collectionPanel.activeTab))
    collectionPanel.scrollRow = 0
    collectionPanel.refreshScroll()
    deckPanel.slots = buildDeckSlots(editingCharacter)
    deckPanel.scrollRow = 0
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