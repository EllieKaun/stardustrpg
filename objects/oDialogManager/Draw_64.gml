if (!active) { exit }

var screenWidth = display_get_gui_width()
var screenHeight = display_get_gui_height()
var line = lines[lineIndex]

// Оверлэй
drawScreenDim(0.6)

// Доска с диалогом
var margin = round(screenWidth * 0.02)
var boxH = floor(screenHeight * 0.30)
var boxW = screenWidth - margin * 2
var boxX = margin
var boxY = screenHeight - boxH - margin
var pad = boxH * 0.12 // отступ текста от рамки
var pointerScale = max(1, floor(screenWidth / dialogBaseW * 0.5)) // указатель 

var hasPortrait = (line.portrait != undefined && sprite_exists(line.portrait))
var onLeft = (line.side != "right")

// Портрет
if (hasPortrait) {
    var portraitH = floor(screenHeight * 0.36)
    var portraitSc = portraitH / sprite_get_height(line.portrait)
    if (portraitSc >= 1) { portraitSc = floor(portraitSc) } 
    var portraitW = sprite_get_width(line.portrait) * portraitSc
    portraitH = sprite_get_height(line.portrait) * portraitSc
    var portraitInset = pad * 1.5
    var portraitLeft = onLeft ? (boxX + portraitInset) : (boxX + boxW - portraitInset - portraitW)
    var portraitTop = boxY + boxH * 0.03 - portraitH
    draw_sprite_ext(line.portrait, 0,
        portraitLeft + sprite_get_xoffset(line.portrait) * portraitSc,
        portraitTop + sprite_get_yoffset(line.portrait) * portraitSc,
        portraitSc, portraitSc, 0, c_white, 1)
}

// Доска рисуется поверх низа портрета
draw_sprite_stretched(box, 0, boxX, boxY, boxW, boxH)

// Координаты и размеры текста
var padX = pad * 1.5
var padY = pad
var textX = boxX + padX
var textW = boxW - padX * 2
var textY = boxY + padY

// Текст
var fullText = currentText()
var textAreaH = boxH - padY * 2
var maxLineH = boxH * 0.2
var answerOptions = currentOptions()
var fontLadder = UI_FONT_STACK
var chosenFont = fontLadder[array_length(fontLadder) - 1]
for (var fontIndex = 0; fontIndex < array_length(fontLadder); fontIndex++) {
    draw_set_font(fontLadder[fontIndex])
    var fontLineHeight = string_height("Ay")
    var fontLineSep = round(fontLineHeight * 1.15)
    var neededHeight = string_height_ext(fullText, fontLineSep, textW)
    if (answerOptions != undefined) { // варианты ответа тем же шрифтом, что и текст диалога
        neededHeight += fontLineSep * 0.5
        for (var optionIndex = 0; optionIndex < array_length(answerOptions); optionIndex++) neededHeight += string_height_ext("> " + answerOptions[optionIndex].text, fontLineSep, textW)
    }
    if (fontLineHeight <= maxLineH && neededHeight <= textAreaH) {
        chosenFont = fontLadder[fontIndex]
        break
    }
}

draw_set_font(chosenFont)
var lineSep = round(string_height("Ay") * 1.15)
var fullH = string_height_ext(fullText, lineSep, textW)
var drawY = (answerOptions != undefined) ? textY : textY + max(0, (textAreaH - fullH) * 0.5)
// Без портрета
var drawX = hasPortrait ? textX : boxX + (boxW - string_width_ext(fullText, lineSep, textW)) * 0.5
var shown = string_copy(fullText, 1, floor(charProgress))
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_text_ext(drawX, drawY, shown, lineSep, textW)

if (answerOptions != undefined && fullyRevealed()) {
    // Варианты ответа
    var optionY = drawY + fullH + lineSep * 0.5
    for (var i = 0; i < array_length(answerOptions); i++) {
        var isSelected = (i == selectedOption)
        draw_set_color(isSelected ? c_yellow : c_white)
        var optStr = (isSelected ? "> " : "   ") + answerOptions[i].text
        draw_text_ext(textX, optionY, optStr, lineSep, textW)
        optionY += string_height_ext(optStr, lineSep, textW)
    }
    draw_set_color(c_white)
} else if (fullyRevealed()) {
    var pointerY = boxY + boxH - padY - pointerScale * 2 + floor(pointerScale * 2 * sin(current_time / 200))
    draw_sprite_ext(sPointer, 0, boxX + boxW - padX, pointerY, pointerScale, pointerScale, 0, c_white, 1)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
