// Альбом карт

// Слоты альбома
function buildAlbumSlots() {
    var refs = getCollectionRefs()
    var slots = []
    for (var i = 0; i < array_length(refs); i++) {
        var ref = refs[i]
        var card = cardFromRef(ref)
        if (card == undefined) continue
        var s = new Slot("filled", card)
        s.ref = { id: ref.id, rarity: ref.rarity }
        s.count = ref.count
        s.addable = false
        array_push(slots, s)
    }
    return slots
}

// Рендер одной карты альбома
function albumDrawCard(slot, rect, isSelected) {
    var card = slot.card
    var prevFilter = gpu_get_tex_filter()
    gpu_set_tex_filter(true) 
    var spr = (card != undefined) ? card.cardAlbumSpr : noone
    if (spr != noone && sprite_exists(spr)) {
        draw_sprite_stretched(spr, 0, rect.sx, rect.sy, rect.sw, rect.sh)
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
        var bandY = rect.sy + rect.sh * 0.66
        var bandH = rect.sh * 0.30
        draw_set_color(c_black)
        draw_set_alpha(0.45)
        draw_rectangle(rect.sx, bandY, rect.sx + rect.sw, bandY + bandH, false)
        draw_set_alpha(1)
        draw_set_color(c_white)
        draw_set_font(uiFont())
        drawFitTextCentered(cardDisplayDesc(card),
            rect.sx + rect.sw * 0.08, bandY,
            rect.sw * 0.84, bandH, UI_FONT_STACK)
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
    var gw = display_get_gui_width()
    var gh = display_get_gui_height()
    var uiScale = gw / 320

    var top = gh * 0.14      // место под заголовок ALBUM
    var bottom = gh * 0.04

    panel.x = gw * 0.06
    panel.y = top
    panel.w = gw * 0.88
    panel.h = gh - top - bottom
    panel.padding = 8 * uiScale
    panel.uiScale = uiScale
    panel.refreshScroll()
}
