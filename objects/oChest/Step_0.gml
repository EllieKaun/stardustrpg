if (global.gamePaused || global.uiModal) exit
if (variable_global_exists("cutsceneActive") && global.cutsceneActive) exit
if (variable_global_exists("introWalk") && global.introWalk) exit
if (variable_global_exists("deckTutorialStage") && global.deckTutorialStage != DeckTutorialStage.Inactive && global.deckTutorialStage != DeckTutorialStage.Done) exit

if (chestState == ChestState.Done) exit

if (chestState == ChestState.Closed
    && chestIndex >= 0 && chestIndex < array_length(global.chests)
    && global.chests[chestIndex].opened) {
    instance_destroy()
    exit
}

if (chestState == ChestState.Opening) {
    var openSpr = asset_get_index("sprChestOpen")
    if (openSpr != noone && sprite_exists(openSpr) && sprite_get_number(openSpr) > 1) {
        var spd = sprite_get_speed(openSpr)
        if (sprite_get_speed_type(openSpr) == spritespeed_framespersecond) spd /= game_get_speed(gamespeed_fps)
        if (spd <= 0) spd = sprite_get_number(openSpr) / (0.5 * game_get_speed(gamespeed_fps))
        openTimer += spd
        if (openTimer >= sprite_get_number(openSpr) - 1) doChestAction()
    } else {
        openTimer += 1
        if (openTimer >= 0.4 * game_get_speed(gamespeed_fps)) doChestAction()
    }
    exit
}

var leader = oGameController.selected_character
if (!instance_exists(leader)) exit
if (point_distance(x, y, leader.x, leader.y) > interactDist) exit

chestState = ChestState.Opening
openTimer = 0
opened = true
if (chestIndex >= 0 && chestIndex < array_length(global.chests)) {
    global.chests[chestIndex].opened = true
}
