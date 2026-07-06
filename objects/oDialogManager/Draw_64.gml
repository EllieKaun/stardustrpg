if (!active) exit

var screenWidth = display_get_gui_width()
var screenHeight = display_get_gui_height()
var line = lines[lineIndex]

// Оверлэй
draw_set_color(c_black)
draw_set_alpha(0.6)
draw_rectangle(0, 0, screenWidth, screenHeight, false)
draw_set_alpha(1)
draw_set_color(c_white)

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
var pMidY = portraitY + pSize / 2
var shown = string_copy(currentText(), 1, floor(charProgress))
draw_set_font(boxFont)
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_middle)
draw_text_ext(textX, pMidY, shown, 12, textW) 

draw_set_valign(fa_top)

// Продолжить 
if (fullyRevealed()) {
    var iy = boxY + boxH - 12 + floor(2 * sin(current_time / 200))  
    draw_sprite(sPointer, 0, boxX + boxW - 16, iy)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)