// Катсцена появления босса — спрайт на весь экран поверх мира
if (!global.cutsceneActive || !sprite_exists(cutsceneSprite)) exit

var sw = display_get_gui_width()
var sh = display_get_gui_height()

draw_set_color(c_black)
draw_set_alpha(0.5)
draw_rectangle(0, 0, sw, sh, false)
draw_set_color(c_white)
draw_set_alpha(1)

var frame = min(floor(cutsceneFrame), sprite_get_number(cutsceneSprite) - 1)
draw_sprite_stretched(cutsceneSprite, frame, 0, 0, sw, sh)
