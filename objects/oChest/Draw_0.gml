var openSpr = asset_get_index("sprChestOpen")

if (chestState == ChestState.Opening && openSpr != noone && sprite_exists(openSpr)) {
    var frame = min(floor(openTimer), sprite_get_number(openSpr) - 1)
    draw_sprite(openSpr, frame, x, y)
    exit
}

var closedSpr = asset_get_index("sprChest")
if (closedSpr != noone && sprite_exists(closedSpr)) {
    draw_sprite(closedSpr, 0, x, y)
    exit
}

var s = 6
var col = c_gray
if (chestKind == ChestKind.Gold) col = c_yellow
else if (chestKind == ChestKind.Card) col = c_aqua
else if (chestKind == ChestKind.Enemy) col = c_red

draw_set_color(col)
draw_rectangle(x - s, y - s, x + s, y + s, false)
draw_set_color(c_black)
draw_rectangle(x - s, y - s, x + s, y + s, true)
draw_set_color(c_white)
