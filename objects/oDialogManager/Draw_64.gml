if (!active) exit

var screenWidth = display_get_gui_width()
var screenHeight = display_get_gui_height()
var line = lines[lineIndex]

// Верстка портретов
var margin = 8
var boxH = floor(screenHeight * 0.28)
var boxY = screenHeight - boxH - margin
var boxX = margin
var boxW = screenWidth - margin * 2

// Координаты портрета
var pSize = portraitSize
var onLeft = (line.side != "right")
var portraitX = onLeft ? margin : (screenWidth - margin - pSize)
var portraitY = boxY - pSize + 8

// Координаты и размеры текста
var pad = 8
var textX = boxX + pad + (onLeft ? pSize : 0)
var textW = boxW - pad * 2 - pSize
var textY = boxY + pad

// --- box ---
//draw_sprite_stretched(sprCardDeskFull, 0, boxX, boxY, boxW, boxH)

// Рисуем портрет
if (line.portrait != undefined && sprite_exists(line.portrait)) {
    draw_sprite_stretched(line.portrait, 0, portraitX, portraitY, pSize, pSize)
}


// --- body text (typewriter + word wrap) ---
var bodyY   = textY + 16;
var shown   = string_copy(currentText(), 1, floor(charProgress));
draw_set_font(boxFont);
draw_set_color(c_white);
draw_text_ext(textX, bodyY, shown, 12, textW)

// --- continue indicator ---
if (fullyRevealed()) {
    var iy = boxY + boxH - 12 + floor(2 * sin(current_time / 200));  // little bob
    draw_sprite(sPointer, 0, boxX + boxW - 16, iy);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);