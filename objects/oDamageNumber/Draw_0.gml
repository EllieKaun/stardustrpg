draw_set_alpha(image_alpha)
draw_set_colour(color)
draw_set_font(fnUI_12)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
var textString = string(value)
var textScale = 1
if (maxWidth > 0) {
    var textWidth = string_width(textString)
    if (textWidth > maxWidth) { textScale = maxWidth / textWidth }
}
draw_text_transformed(x, y, textString, textScale, textScale, 0)
draw_set_alpha(1)