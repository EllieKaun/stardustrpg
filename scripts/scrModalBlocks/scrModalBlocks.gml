// Мой фреймворк для верстки диалогов с готовыми отрисовщиками независимо от использования

function modalBlockInit() {
    global.modalBlocks = {}

    variable_struct_set(
        global.modalBlocks, 
        "column", 
        {
            draw: function(block, modalWindow, rect) {
                modalLayoutBlocks( modalWindow, block.children, rect, false)
            }
        }
    )

    variable_struct_set(
        global.modalBlocks, 
        "row", 
        {
            draw: function(block, modalWindow, rect) {
                modalLayoutBlocks( modalWindow, block.children, rect, true)
            }
        }
    )

    variable_struct_set(global.modalBlocks, "custom", {
        draw: function(block, modalWindow, rect) { block.drawFn(modalWindow, rect) }
    })

    // title — одна строка, подгоняется под высоту блока
    variable_struct_set(global.modalBlocks, "title", {
        draw: function(block, modalWindow, rect) { 
            draw_set_color(block.color)
            draw_set_halign(block.align)
            draw_set_valign(fa_middle)
            var titleX = modalAlignX(rect, block.align)
            var titleY = rect.y + rect.h * 0.5
            if (block.outline) {
                drawUiTextOutline(titleX, titleY, block.text, rect.h * block.size, c_black, max(2, round(guiScale())), rect.w)
                return
            }
            drawUiText(titleX, titleY, block.text, rect.h * block.size, rect.w)
        }
    })

    // панель со своими отступами, внутри столбик блоков
    variable_struct_set(global.modalBlocks, "box", {
        draw: function(block, modalWindow, rect) {
            draw_sprite_stretched(block.sprite, 0, rect.x, rect.y, rect.w, rect.h)
            var inset = block.inset * guiScale()
            modalLayoutBlocks(modalWindow, block.children, {
                x: rect.x + inset,
                y: rect.y + inset,
                w: rect.w - inset * 2,
                h: rect.h - inset * 2
            }, false)
        }
    })

    // text — абзац с переносами, если нужно для диалогов печатается по буквам
    variable_struct_set(global.modalBlocks, "text", {
        draw: function(block, modalWindow, rect) { 
            if (block.text == "" || rect.h <= 0) { return }
            var fitted = fitWrappedText(block.text, rect.w, rect.h, block.maxLineH * guiScale())
            if (fitted == undefined) { return }
            block.revealLength = string_length(fitted.text)
            var shown = block.typewriter 
                ? string_copy(fitted.text, 1, floor(modalWindow.charProgress)) 
                : fitted.text
                
            var prevFont = draw_get_font()
            draw_set_font(fitted.font)
            var fullW = string_width(fitted.text) * fitted.scale
            var fullH = string_height(fitted.text) * fitted.scale
            var textX = modalAlignX(rect, block.align, fullW)
            var textY = (block.valign == fa_middle) ? rect.y + (rect.h - fullH) * 0.5 : rect.y
            draw_set_color(block.color)
            draw_text_transformed(floor(textX), floor(textY), shown, fitted.scale, fitted.scale, 0)
            draw_set_font(prevFont)
        }
    })

    variable_struct_set(global.modalBlocks, "sprite", {
        draw: function(block, modalWindow, rect) {
            var side = min(rect.w, rect.h)
            if (block.frame) {
                draw_set_color(c_white)
                draw_rectangle(rect.x, rect.y, rect.x + side, rect.y + side, false)
            }
            if (block.sprite == undefined || !sprite_exists(block.sprite)) { return }
            if (block.stretch) {
                draw_sprite_stretched(block.sprite, 0, rect.x, rect.y, side, side)
                return
            }
            var spriteScale = min(side / sprite_get_width(block.sprite), 
                                    side / sprite_get_height(block.sprite))
            draw_sprite_ext(block.sprite, 
                            0, 
                            rect.x + side / 2, 
                            rect.y + side / 2, 
                            spriteScale, 
                            spriteScale, 
                            0, 
                            c_white, 
                            1)
        }
    })  

    // карта по центру 
    variable_struct_set(global.modalBlocks, "card", {
        draw: function(block, modalWindow, rect) {
            if (block.card == undefined) { return }
            var cardH = min(rect.h, rect.w * 3 / 2)
            drawCardFace(block.card, rect.x + rect.w * 0.5, rect.y + rect.h * 0.5, cardH * 2 / 3, cardH, 0, 1, 1, false)
        }
    })  

    // несколько кнопок подряд
    variable_struct_set(global.modalBlocks, "buttons", {
        draw: function(block, modalWindow, rect) {
            var scaleToGui = guiScale()
            var count = array_length(block.items)
            var btnW = block.buttonW * scaleToGui
            var btnH = min(rect.h, block.buttonH * scaleToGui)
            var buttonGap = 8 * scaleToGui
            var outlineSize = max(2, round(scaleToGui * 0.5))
            var startX = rect.x + (rect.w - (btnW * count + buttonGap * (count - 1))) / 2
            var btnY = floor(rect.y + (rect.h - btnH) / 2)
            draw_set_halign(fa_center)
            draw_set_valign(fa_middle)
            for (var buttonIndex = 0; buttonIndex < count; buttonIndex++) {
                var item = block.items[buttonIndex]
                var buttonX = floor(startX + buttonIndex * (btnW + buttonGap))
                var isSelected = (modalWindow.cursor == item.index)
                var isCancel = item[$ "cancel"] ?? (count > 1 && buttonIndex == 0)
                var buttonSprite = isCancel ? sprDialogButton : sprDialogConfirm
                modalWindow.addItemRect(item, buttonX, btnY, btnW, btnH)
                if (isSelected) { drawStretchedOutline(buttonSprite, buttonX, btnY, btnW, btnH, c_yellow, outlineSize) }
                draw_sprite_stretched(buttonSprite, 0, buttonX, btnY, btnW, btnH)
                draw_set_color(isCancel ? DIALOG_NAVY : c_white)
                drawUiText(buttonX + btnW / 2, btnY + btnH / 2, item.label, btnH * 0.55, btnW * 0.85)
            }
        }
    })

    // ответы в диалоге столбиком, появляются после печати текста
    variable_struct_set(global.modalBlocks, "options", {
        draw: function(block, modalWindow, rect) {
            if (!modalWindow.fullyRevealed()) { return }
            var count = array_length(block.items)
            var lineH = rect.h / max(count, block.minLines)
            for (var optionIndex = 0; optionIndex < count; optionIndex++) {
                var item = block.items[optionIndex]
                var isSelected = (modalWindow.cursor == item.index)
                var optionY = rect.y + optionIndex * lineH
                draw_set_color(isSelected ? c_yellow : c_white)
                drawUiText(rect.x, optionY, (isSelected ? "> " : "   ") + item.label, lineH * 0.8, rect.w)
                modalWindow.addItemRect(item, rect.x, optionY, rect.w, lineH)
            }
        }
    })

    // выбор карты-награды
    variable_struct_set(global.modalBlocks, "cardChoice", {
        draw: function(block, modalWindow, rect) {
            var scaleToGui = guiScale()
            var count = array_length(block.items)
            var cardGap = 16 * scaleToGui
            var noteH = 12 * scaleToGui
            var noteGap = 5 * scaleToGui
            var cardH = (rect.h - noteH - noteGap) * 0.5
            var cardW = floor(min(cardH * 2 / 3, (rect.w - (count - 1) * cardGap) / count))
            cardH = floor(cardW * 3 / 2)
            var startX = rect.x + (rect.w - (count * cardW + (count - 1) * cardGap)) / 2
            var startY = floor(rect.y + (rect.h - cardH - noteH - noteGap) / 2)
            for (var cardIndex = 0; cardIndex < count; cardIndex++) {
                var item = block.items[cardIndex]
                var cardX = floor(startX + cardIndex * (cardW + cardGap))
                var isSelected = (modalWindow.cursor == item.index)
                var cardY = isSelected ? startY - 3 * scaleToGui : startY
                modalWindow.addItemRect(item, cardX, startY, cardW, cardH)
                drawCard(item.card, cardX, cardY, cardW, cardH, isSelected, 1)
                if (item[$ "note"] != undefined) {
                    var noteW = cardW * 0.8
                    var noteX = cardX + (cardW - noteW) / 2
                    var noteY = startY + cardH + noteGap
                    draw_sprite_stretched(sprDialogButton, 0, noteX, noteY, noteW, noteH)
                    draw_set_halign(fa_center)
                    draw_set_valign(fa_middle)
                    draw_set_color(DIALOG_NAVY)
                    drawUiText(noteX + noteW / 2, noteY + noteH / 2, item.note, noteH * 0.55, noteW * 0.85)
                    draw_set_color(c_white)
                }
            }
        }
    })

    // инфо панель в бою
    variable_struct_set(global.modalBlocks, "lines", {
        draw: function(block, modalWindow, rect) {
            var scaleToGui = guiScale()
            var lineH = block.lineH * scaleToGui
            var textH = lineH * 0.72
            var rowY = rect.y
            for (var rowIndex = 0; rowIndex < array_length(block.rows); rowIndex++) {
                var row = block.rows[rowIndex]
                if (row[$ "gap"] ?? false) {
                    rowY += lineH * 0.5
                    continue
                }
                draw_set_color(row[$ "color"] ?? c_white)
                if (row[$ "wrap"] ?? false) {
                    var fitted = fitWrappedText(row.text, rect.w, lineH * 2)
                    var prevFont = draw_get_font()
                    draw_set_font(fitted.font)
                    draw_text_transformed(floor(rect.x), floor(rowY), fitted.text, fitted.scale, fitted.scale, 0)
                    rowY += string_height(fitted.text) * fitted.scale + 2 * scaleToGui
                    draw_set_font(prevFont)
                    continue
                }
                var textX = rect.x
                var icon = row[$ "icon"] ?? noone
                if (icon != noone) {
                    draw_sprite_stretched(icon, 0, rect.x, rowY, textH, textH)
                    textX += textH + 4 * scaleToGui
                }
                drawUiText(textX, rowY, row.text, textH, rect.x + rect.w - textX)
                rowY += lineH
            }
        }
    })
}


function modalBlock(kind, params) {
    params.kind = kind
    if (!variable_struct_exists(params, "h")) {
        params.h = "fill" 
    }
    if (!variable_struct_exists(params, "w")) { 
        params.w = "fill" 
    }
    return params
}

function modalAlignX(rect, align, contentW = 0) {
    if (align == fa_left) {
        return rect.x
    }
    if (align == fa_right) {
        return rect.x + rect.w - contentW
    }
    return rect.x + (rect.w - contentW) * 0.5
}

// Блоки UI элементов 

function ModalTitle(text, params = {}) {
    return modalBlock(
        "title",
        modalMerge({
            text: text,
            h: 0.2,
            size: 0.8,
            align: fa_center,
            color: c_white,
            outline: false
        },
        params)
    )
}

function ModalBox(children, params = {}) {
    return modalBlock("box", modalMerge({ children: children, sprite: sprDialogBig, inset: 10 }, params))
}

function ModalText(text, params = {}) {
    return modalBlock("text", modalMerge({
        text: text, align: fa_left, valign: fa_top, color: c_white, typewriter: false, maxLineH: 11 }, params))
}

function ModalSprite(sprite, params = {}) {
    return modalBlock("sprite", modalMerge({ sprite: sprite, frame: false, stretch: false }, params))
}

function ModalCard(card, params = {}) {
    return modalBlock("card", modalMerge({ card: card }, params))
}

function ModalButtons(items, params = {}) {
    return modalBlock("buttons", modalMerge({ items: items, buttonW: 40, buttonH: 12 }, params))
}

function ModalOptions(items, params = {}) {
    return modalBlock("options", modalMerge({ items: items, minLines: 3 }, params))
}

function ModalCardChoice(items, params = {}) {
    return modalBlock("cardChoice", modalMerge({ items: items }, params))
}

function ModalLines(rows, params = {}) {
    return modalBlock("lines", modalMerge({ rows: rows, lineH: 14 }, params))
}

function ModalRow(children, params = {}) {
    return modalBlock("row", modalMerge({ children: children }, params))
}

function ModalColumn(children, params = {}) {
    return modalBlock("column", modalMerge({ children: children }, params))
}

function ModalCustom(drawFn, params = {}) {
    return modalBlock("custom", modalMerge({ drawFn: drawFn }, params))
}