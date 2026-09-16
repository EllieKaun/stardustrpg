if (chestBlocked()) { exit }

switch (chestState) {
    case ChestState.Closed:
        // дубликат уже открытой записи — убрать
        if (chestIndex >= 0 && chestIndex < array_length(global.chests)
            && global.chests[chestIndex].opened) {
            instance_destroy()
            break
        }
        // Открытие по близости героя (надёжнее события Collision)
        var hero = instance_nearest(x, y, oHero)
        if (instance_exists(hero) && point_distance(x, y, hero.x, hero.y) < interactDist) {
            changeChestState(ChestState.Opening)
        }
    break

    case ChestState.Opening:
        var openSpr = asset_get_index("sprChestOpen")
        if (openSpr != noone && sprite_exists(openSpr) && sprite_get_number(openSpr) > 1) {
            var spd = sprite_get_speed(openSpr)
            if (sprite_get_speed_type(openSpr) == spritespeed_framespersecond) spd /= game_get_speed(gamespeed_fps)
            if (spd <= 0) spd = sprite_get_number(openSpr) / (0.5 * game_get_speed(gamespeed_fps))
            openTimer += spd
            if (openTimer >= sprite_get_number(openSpr) - 1) changeChestState(ChestState.Done)
        } else {
            openTimer += 1
            if (openTimer >= 0.4 * game_get_speed(gamespeed_fps)) changeChestState(ChestState.Done)
        }
    break
}
