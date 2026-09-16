if (!active) exit

var screenWidth = display_get_gui_width()
var screenHeight = display_get_gui_height()
var line = lines[lineIndex]

// Оверлэй
drawScreenDim(0.6)

// Верстка портретов
var margin = 8
var boxH = floor(screenHeight * 0.28)
var boxY = screenHeight - boxH
var boxX = margin
var boxW = screenWidth - margin * 2

// Координаты портрета
var pSize = portraitSize
var onLeft = (line.side != "right")
var portraitX = onLeft ? margin : (screenWidth - margin - pSize)
var portraitY = boxY + boxH - pSize

// Координаты и размеры текста
var pad = 8
var textX = boxX + pad + (onLeft ? pSize : 0)
var textW = boxW - pad * 2 - pSize
var textY = boxY + pad

// Рисуем портрет
if (line.portrait != undefined && sprite_exists(line.portrait)) {
    draw_sprite_stretched(line.portrait, 0, portraitX, portraitY, pSize, pSize)
}

// Текст
var full = currentText()
var textAreaH = boxH - pad * 2
var maxLineH = boxH * 0.16
var fontLadder = [fnUI_14, fnUI_12, fnUI_10, fnUI_9, fnUI_8, fnUI_7]
var chosenFont = fontLadder[array_length(fontLadder) - 1]
for (var fi = 0; fi < array_length(fontLadder); fi++) {
    draw_set_font(fontLadder[fi])
    var lh = string_height("Ay")
    if (lh <= maxLineH && string_height_ext(full, round(lh * 1.15), textW) <= textAreaH) {
        chosenFont = fontLadder[fi]
        break
    }
}

draw_set_font(chosenFont)
var lineSep = round(string_height("Ay") * 1.15)
var fullH = string_height_ext(full, lineSep, textW)
var opts = currentOptions()
var drawY = (opts != undefined) ? textY : textY + max(0, (textAreaH - fullH) * 0.5)
var shown = string_copy(full, 1, floor(charProgress))
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_text_ext(textX, drawY, shown, lineSep, textW)

if (opts != undefined && fullyRevealed()) {
    var optH = min(maxLineH, boxH * 0.14)
    var oy = drawY + fullH + optH * 0.5
    for (var i = 0; i < array_length(opts); i++) {
        var sel = (i == selectedOption)
        draw_set_color(sel ? c_yellow : c_white)
        var prefix = sel ? "> " : "   "
        drawUiText(textX, oy + i * (optH * 1.35), prefix + opts[i].text, optH)
    }
    draw_set_color(c_white)
} else if (fullyRevealed()) {
    var iy = boxY + boxH - 12 + floor(2 * sin(current_time / 200))
    draw_sprite(sPointer, 0, boxX + boxW - 16, iy)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)