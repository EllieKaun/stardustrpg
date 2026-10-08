//// Текстовые хелперы: шрифтовая лесенка, подбор размера, перенос и отрисовка

function uiFontInit() {
    var candidates = ["fnUI_7","fnUI_8", "fnUI_9", "fnUI_10", "fnUI_12", "fnUI_14", "fnUI_15", "fnUI_16", "fnUI_17", "fnUI_18", "fnUI_20", "fnUI_24", "fnUI_28", "fnUI_32", "fnUI_40", "fnUI_48", "fnUI"]
    var ladder = []
    var prevFont = draw_get_font()
    for (var index = 0; index < array_length(candidates); index++) {
        var fontAsset = asset_get_index(candidates[index])
        if (fontAsset >= 0 && font_exists(fontAsset)) {
            draw_set_font(fontAsset)
            array_push(ladder, { font: fontAsset, lineH: max(1, string_height("0")) })
        }
    }
    if (array_length(ladder) == 0) {
        draw_set_font(fnUI_24)
        array_push(ladder, { font: fnUI_24, lineH: max(1, string_height("0")) })
    }
    if (prevFont >= 0) { draw_set_font(prevFont) }
    array_sort(ladder, function(first, second) { return first.lineH - second.lineH })
    global.uiFontLadder = ladder
    global.uiFontCurrent = ladder[array_length(ladder) - 1].font
}

function uiFont() {
    if (!variable_global_exists("uiFontLadder")) { uiFontInit() }
    return global.uiFontCurrent
}

// Подбирает шрифт под высоту targetH и ширину maxW
function uiTextScale(text, targetH, maxW) {
    if (!variable_global_exists("uiFontLadder")) { uiFontInit() }
    var ladder = global.uiFontLadder
    var pickIndex = 0
    for (var index = 0; index < array_length(ladder); index++) {
        if (ladder[index].lineH <= targetH) { pickIndex = index }
    }

    if (ladder[pickIndex].lineH > targetH) {
        var pick = ladder[pickIndex]
        global.uiFontCurrent = pick.font
        draw_set_font(pick.font)
        var textScale = targetH / pick.lineH
        var textWidth = string_width(text) * textScale
        if (textWidth > maxW) { textScale *= maxW / max(1, textWidth) }
        return textScale
    }

    // пока текст не влезет по ширине без масштабирования
    while (pickIndex > 0) {
        draw_set_font(ladder[pickIndex].font)
        if (string_width(text) <= maxW) { break }
        pickIndex--
    }
    var pick = ladder[pickIndex]
    global.uiFontCurrent = pick.font
    draw_set_font(pick.font)
    var overflowWidth = string_width(text)
    if (overflowWidth > maxW) { return maxW / max(1, overflowWidth) } // не влез даже самый мелкий
    return 1
}

// Ручной перенос строк под ширину maxW текущим шрифтом
function wrapTextToWidth(text, maxW) {
    var wrappedText = ""
    var currentLine = ""
    var word = ""
    var textLength = string_length(text)
    for (var index = 1; index <= textLength + 1; index++) {
        var currentChar = (index <= textLength) ? string_char_at(text, index) : "\n"
        if (currentChar == " " || currentChar == "\n") {
            if (word != "") {
                var candidateLine = (currentLine == "") ? word : currentLine + " " + word
                if (currentLine != "" && string_width(candidateLine) > maxW) {
                    wrappedText += currentLine + "\n"
                    currentLine = word
                } else {
                    currentLine = candidateLine
                }
                word = ""
            }
            if (currentChar == "\n") {
                wrappedText += currentLine
                if (index <= textLength) { wrappedText += "\n" }
                currentLine = ""
            }
        } else {
            word += currentChar
        }
    }
    return wrappedText
}

// Подбор шрифта под область
function fitWrappedText(text, areaW, areaH) {
    if (!variable_global_exists("uiFontLadder")) { uiFontInit() }
    var ladder = global.uiFontLadder
    var prevFont = draw_get_font()
    var best = undefined // лучший без масштабирования
    var fallback = undefined // запасной с ужатием
    var fallbackSize = -1
    for (var index = 0; index < array_length(ladder); index++) {
        draw_set_font(ladder[index].font)
        var wrapped = wrapTextToWidth(text, areaW)
        var textWidth = string_width(wrapped)
        var textHeight = string_height(wrapped)
        if (textWidth <= areaW && textHeight <= areaH) {
            best = { font: ladder[index].font, scale: 1, text: wrapped }
            continue
        }
        var fitScale = min(1, min(areaW / max(1, textWidth), areaH / max(1, textHeight)))
        var effective = fitScale * ladder[index].lineH // итоговая высота строки на экране
        if (effective >= fallbackSize) {
            fallbackSize = effective
            fallback = { font: ladder[index].font, scale: fitScale, text: wrapped }
        }
    }
    draw_set_font(prevFont)
    return best ?? fallback
}

function drawUiText(textX, textY, text, targetHeight, maxWidth = 1000000) {
    var textScale = uiTextScale(text, targetHeight, maxWidth)
    draw_text_transformed(floor(textX), floor(textY), text, textScale, textScale, 0)
    return textScale
}

// Чуть более жирный текст: рисуем дважды со смещением вдоль оси X карты
function drawTextBold(textX, textY, text, scale, angle, color, alpha) {
    textX = floor(textX)
    textY = floor(textY)
    draw_text_transformed_colour(textX, textY, text, scale, scale, angle, color, color, color, color, alpha)

    var lineHeightOnScreen = string_height("0") * scale
    if (lineHeightOnScreen < 16) { return }
    var boldOffset = max(1, round(scale * 0.4))
    draw_text_transformed_colour(textX + dcos(angle) * boldOffset, textY - dsin(angle) * boldOffset, text, scale, scale, angle, color, color, color, color, alpha)
}

function drawFitTextInArea(
    text,
    areaX,
    areaY,
    areaWidth,
    areaHeight
) {
    var fonts = UI_FONT_STACK

    for (var index = 0; index < array_length(fonts); index++) {
        draw_set_font(fonts[index])

        if (string_width_ext(text, -1, areaWidth) <= areaWidth &&
            string_height_ext(text, -1, areaHeight) <= areaHeight) {
            draw_text(areaX, areaY, text)
            break
        }
    }
}

// Подобрать шрифт и отрисовать текст центрировано
function drawFitTextCentered(text, areaX, areaY, areaW, areaH, fonts = undefined) {
    if (fonts != undefined && array_length(fonts) > 0) {
        for (var fontIndex = 0; fontIndex < array_length(fonts); fontIndex++) {
            draw_set_font(fonts[fontIndex]);
            if (string_width(text) <= areaW && string_height(text) <= areaH) { break }
        }
    }
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)

    draw_text(floor(areaX + areaW / 2), floor(areaY + areaH / 2), text)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}
