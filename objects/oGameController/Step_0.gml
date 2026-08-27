// Катсцена босса
if (global.cutsceneActive) {
    var csSpd = sprite_get_speed(cutsceneSprite)
    if (sprite_get_speed_type(cutsceneSprite) == spritespeed_framespersecond) {
        csSpd /= game_get_speed(gamespeed_fps)
    }
    // страховка: если у спрайта нет анимации (ккорость 0 / один кадр) —
    // показываем 1.5 сек и завершаем, иначе катсцена зависнет
    if (csSpd <= 0) csSpd = sprite_get_number(cutsceneSprite) / (1.5 * game_get_speed(gamespeed_fps))
    cutsceneFrame += csSpd
    if (cutsceneFrame >= sprite_get_number(cutsceneSprite)) {
        global.cutsceneActive = false
        global.uiModal = false
        with (oTransition) {
            target_room = oGameController.cutsceneTargetRoom
            state = "fade_out"
        }
    }
    exit
}

// F11 - на весь экран
if (keyboard_check_pressed(vk_f11)) {
    setDisplayMode(!global.displayFullscreen)
}

// Esc - переключатель паузы 
if (keyboard_check_pressed(vk_escape)) {
    if (instance_exists(oPauseMenu)) {
        with (oPauseMenu) close()
    } else if (!global.uiModal) {
        instance_create_layer(0, 0, "Instances", oPauseMenu)
    }
}

// Открыть/закрыть декбилдер 
if (keyboard_check_pressed(vk_tab) && instance_exists(oDeckBuilder)) {
    if (oDeckBuilder.open) {
        oDeckBuilder.closeBuilder()
    } else if (!global.uiModal) { // не открываем поверх паузы/диалога
        oDeckBuilder.openBuilder()
    }
//    say([
//    dialogLine("Lana", placeholderLana, "left",
//        "Hey hey"),
//    dialogLine("Viv", placeholderViv, "right",
//        "Yeh yeh")
//], function() {
//    show_debug_message("dialog finished")
//})
}
if (keyboard_check_pressed(vk_lcontrol)) { 
    switchCharacter()
}