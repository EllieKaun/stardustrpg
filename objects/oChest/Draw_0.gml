depth = -bbox_bottom
switch (chestState) {
    case ChestState.Opening:
        var openSpr = asset_get_index("sprChestOpen")
        if (openSpr != noone && sprite_exists(openSpr)) {
            var frame = min(floor(openTimer), sprite_get_number(openSpr) - 1)
            draw_sprite(openSpr, frame, x, y)
        } else {
            draw_self()
        }
    break

    default:
        draw_self()
    break
}
