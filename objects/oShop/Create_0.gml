dbBaseW = camera_get_view_width(view_camera[0])
dbBaseH = camera_get_view_height(view_camera[0])

open = false
coins = getGold() // баланс

var tabFonts = [fnUI_48, fnUI_32, fnUI_24, fnUI_16, fnUI_14, fnUI_12, fnUI_10, fnUI_8]

categoryForTab = function(tab) {
    switch (tab) {
        case 0: return ShopCategory.Cards
        case 1: return ShopCategory.OtherItems
        default: return ShopCategory.Cards
    }
}

// Панель списка товаров
shopPanel = new Shop({
    x: 0, y: 0, w: 0, h: 0,
    tabFonts: tabFonts,
    rowHeight: 62, // высота строки товара
    tabs: [
        { name: "CARDS", sprite: ShopBtn, color: #CC8844 },
        { name: "OTHER", sprite: ShopBtn, color: #CC8844 }
    ],
    slots: buildShopItems(ShopCategory.Cards),
    onTabClick: function(panel, tabIndex) {
        with (oShop) {
            panel.slots = buildShopItems(categoryForTab(tabIndex))
            panel.scrollY = 0
            panel.cursorRow = 0
            panel.refreshScroll()
            panel.selectAtCursor()
        }
    },
    // Клик/Enter по товару — покупка
    onSlotClick: function(panel, slotIndex) {
        with (oShop) {
            if (slotIndex < 0 || slotIndex >= array_length(panel.slots)) return
            var item = panel.slots[slotIndex]
            if (getGold() < item.price) return // не хватает золота

            if (item.kind == "card") {
                if (spendGold(item.price)) {
                    unlockCard(item.ref.id, item.ref.rarity, 1) // добавляем копию карты
                }
            } else if (item.kind == "slot") {
                if (spendGold(item.price)) {
                    // расширяем деку обоим героям, держим в синхроне
                    unlockDeckSlot(Characters.Lana, 1)
                    unlockDeckSlot(Characters.Viv, 1)
                    playerDataSave()
                    // цена выросла / могли достичь максимума — пересобираем вкладку
                    panel.slots = buildShopItems(ShopCategory.OtherItems)
                    panel.refreshScroll()
                    panel.selectedSlot = min(panel.selectedSlot, array_length(panel.slots) - 1)
                }
            }
            coins = getGold()
        }
    }
})

// Расчитывает размеры шапки и панели
layoutPanels = function() {
    var guiW = display_get_gui_width()
    var guiH = display_get_gui_height()

    // Баннер по центру сверху
    signHeight = guiH * 0.11
    bannerW = signHeight * sprite_get_width(BigShopSignboard) / sprite_get_height(BigShopSignboard)
    bannerX = (guiW - bannerW) * 0.5
    bannerY = guiH * 0.02

    // Головы на краях баннера
    headH = signHeight * 1.15
    headW = headH * sprite_get_width(TurnstarHead) / sprite_get_height(TurnstarHead)

    // Вкладки CARDS и OTHER по бокам от баннера
    var headInset = headW * 0.12
    var tabHt = signHeight * 0.72
    var tabWd = tabHt * sprite_get_width(ShopBtn) / sprite_get_height(ShopBtn)
    var tabYy = bannerY + signHeight * 0.5 - tabHt * 0.5
    var gap = guiW * 0.006
    var leftX  = bannerX - headInset - headW * 0.5 - gap // левее левой головы
    var rightX = bannerX + bannerW + headInset + headW * 0.5 + gap // правее правой головы
    shopPanel.tabRects = [
        { tx: leftX - tabWd, ty: tabYy, tw: tabWd, th: tabHt }, // CARDS слева
        { tx: rightX, ty: tabYy, tw: tabWd, th: tabHt }  // OTHER справа
    ]

    // Панель списка
    var sideMargin = guiW * 0.15
    var top = bannerY + signHeight + guiH * 0.045
    var bottom = guiH * 0.03

    shopPanel.x = sideMargin
    shopPanel.y = top
    shopPanel.w = guiW - sideMargin * 2
    shopPanel.h = guiH - top - bottom
    shopPanel.padding = guiW * 0.010
    shopPanel.tabH = tabHt
    shopPanel.tabPadding = guiW * 0.006
    shopPanel.uiScale = 1
    shopPanel.rowHeight = guiH * 0.18
}
layoutPanels()

shopPanel.focused = true
shopPanel.enterFromLeft(0)

// Открыть магазин
openShop = function() {
    setCrispGui(dbBaseW, dbBaseH)
    layoutPanels()
    open = true
    global.uiModal = true
    coins = getGold() // актуальный баланс
    shopPanel.slots = buildShopItems(categoryForTab(shopPanel.activeTab))
    shopPanel.scrollY = 0
    shopPanel.refreshScroll()
    shopPanel.focused = true
    shopPanel.enterFromLeft(0)
}

// Закрыть магазин
closeShop = function() {
    open = false
    global.uiModal = false
    display_set_gui_size(dbBaseW, dbBaseH)
}
