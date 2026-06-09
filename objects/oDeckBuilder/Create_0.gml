// Ресайз размера GUI под размер игры 
display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]))

var camW = camera_get_view_width(view_camera[0])
var camH = camera_get_view_height(view_camera[0])
var margin = 8
var tabH = 18
var panelW = (camW - margin * 2) / 2;
var panelTop = margin + tabH       
var panelH = camH - panelTop - margin

activePanel = 0; // 0 = коллекция всех карт, 1 = дека

var tabFonts = [fnM3x6_22, fnM3x6_14, fnM3x6_13, fnM3x6_12,
                 fnM3x6_11, fnM3x6_10, fnM3x6_9,  fnM3x6_8, fnM3x6_7]

// Смена фокуса панели на определнную строку
switchFocusTo = function(target, row) {
    with (oDeckBuilder) {
        var src = (target.tag == Panels.Collection) ? deckPanel : collectionPanel
        collectionPanel.focused = (target.tag == Panels.Collection)
        deckPanel.focused  = (target.tag == Panels.Deck)
        activePanel = (target.tag == Panels.Collection) ? Panels.Collection : Panels.Deck
        if (target.x < src.x) target.enterFromRight(row)
        else target.enterFromLeft(row)
    }
}

// Смена фокуса панелей
panelSwitchCallback = function(panel, direction) {
    with (oDeckBuilder) {
        var otherPanel = (panel.tag == Panels.Collection) ? deckPanel : collectionPanel
        if ((direction > 0 && panel.x < otherPanel.x) || (direction < 0 && panel.x > otherPanel.x)) {
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
        default: return undefined
    }
}

// Панель коллекции всех карт
collectionPanel = new Panel({
    x: margin, 
    y: panelTop, 
    w: panelW, 
    h: panelH,
    bgSprite: sprCardDeskFull,
    slotSpriteEmpty: EmptyCardPlace,
    slotSpriteLocked: LockedCardPlace,
    selectSprite: sprCardSelected,
    pointerSprite: sPointer,
    tabFonts: tabFonts,
    tabs: [
        { name: "MAGIC", color: #9944CC },
        { name: "BUFF", color: #CC44CC },
        { name: "HEAL", color: #44CC44 },
        { name: "ATTACK", color: #CC4444 }
    ],
    visibleRows: 3, 
    tabH: tabH, 
    padding: 8,
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
    x: margin + panelW, 
    y: panelTop, 
    w: panelW, 
    h: panelH,
    bgSprite: sprCardDeskFull,
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
    tabH: tabH, 
    padding: 8,
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

// Инициализация панелей
collectionPanel.focused = true
deckPanel.focused = false
collectionPanel.enterFromLeft(0)
activePanel = Panels.Collection

open = false

openBuilder = function() {
    display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]))
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
}