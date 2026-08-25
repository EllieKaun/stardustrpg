// F11 — borderless на весь экран
if (keyboard_check_pressed(vk_f11)) {
    setDisplayMode(!global.displayFullscreen)
}

// Esc — переключатель паузы 
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