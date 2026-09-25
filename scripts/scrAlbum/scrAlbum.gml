// Альбом карт

// Слоты альбома
function buildAlbumSlots() {
    var refs = getCollectionRefs()
    var slots = []
    for (var refIndex = 0; refIndex < array_length(refs); refIndex++) {
        var cardRef = refs[refIndex]
        var card = cardFromRef(cardRef)
        if (card == undefined) { continue }
        if (card.cardAlbumSpr == noone || !sprite_exists(card.cardAlbumSpr)) { continue }
        var newSlot = new Slot("filled", card)
        newSlot.ref = { id: cardRef.id, rarity: cardRef.rarity }
        newSlot.count = cardRef.count
        newSlot.addable = false
        array_push(slots, newSlot)
    }
    return slots
}

// Рендер одной карты альбома
function albumDrawCard(slot, rect, isSelected) {
    var card = slot.card
    var prevFilter = gpu_get_tex_filter()
    gpu_set_tex_filter(true) 
    var albumSprite = (card != undefined) ? card.cardAlbumSpr : noone
    if (albumSprite != noone && sprite_exists(albumSprite)) {
        draw_sprite_stretched(albumSprite, 0, rect.sx, rect.sy, rect.sw, rect.sh)
    } else {

        draw_set_color(make_color_rgb(28, 32, 46))
        draw_rectangle(rect.sx, rect.sy, rect.sx + rect.sw, rect.sy + rect.sh, false)
        draw_set_color(make_color_rgb(70, 78, 100))
        draw_rectangle(rect.sx, rect.sy, rect.sx + rect.sw, rect.sy + rect.sh, true)
        draw_set_color(c_white)
        if (card != undefined) {
            draw_set_font(uiFont())
            drawFitTextCentered(cardDisplayName(card),
                rect.sx + rect.sw * 0.08, rect.sy + rect.sh * 0.06,
                rect.sw * 0.84, rect.sh * 0.28, UI_FONT_STACK)
        }
    }

    // Описание
    if (card != undefined && cardDisplayDesc(card) != "") {
        var textX = rect.sx + rect.sw * (CARD_TEXT_X / CARD_ART_W)
        var textY = rect.sy + rect.sh * (CARD_TEXT_Y / CARD_ART_H)
        var textW = rect.sw * (CARD_TEXT_W / CARD_ART_W)
        var textH = rect.sh * (CARD_TEXT_H / CARD_ART_H)
        // Как на лице карты: перенос строк + подбор шрифта под область, тёмный текст (область описания белая)
        var fittedText = fitWrappedText(cardDisplayDesc(card), textW, textH)
        draw_set_font(fittedText.font)
        draw_set_halign(fa_center)
        draw_set_valign(fa_middle)
        drawTextBold(textX + textW * 0.5, textY + textH * 0.5, fittedText.text, fittedText.scale, 0, c_black, 1)
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(c_white)
    }

    gpu_set_tex_filter(prevFilter)

    if (isSelected && sprite_exists(sprCardSelected)) {
        draw_sprite_stretched(sprCardSelected, 0, rect.sx, rect.sy, rect.sw, rect.sh)
    }
}

// Панель альбома
function albumMakePanel() {
    var panel = new Panel({
        x: 0, y: 0, w: 100, h: 100,
        bgSprite: box2,
        tabs: [],
        scrollable: true,
        pointerSprite: sPointer,
        selectSprite: sprCardSelected,
        cardRenderer: albumDrawCard,
        slots: buildAlbumSlots()
    })
    panel.tag = "Album"
    panel.focused = true
    return panel
}

// Верстка аль бома
function albumLayout(panel) {
    var guiWidth = display_get_gui_width()
    var guiHeight = display_get_gui_height()
    var uiScale = guiWidth / 320

    var topMargin = guiHeight * 0.14      // место под заголовок ALBUM
    var bottomMargin = guiHeight * 0.04

    panel.x = guiWidth * 0.06
    panel.y = topMargin
    panel.w = guiWidth * 0.88
    panel.h = guiHeight - topMargin - bottomMargin
    panel.padding = 8 * uiScale
    panel.uiScale = uiScale
    panel.refreshScroll()
}
