// F11 — borderless на весь экран ↔ окно
if (keyboard_check_pressed(vk_f11)) {
    setDisplayMode(!global.displayFullscreen)
}

// Esc — пауза с полной заморозкой мира. Не открываем поверх другой модалки
// (деккбилдер/диалог ставят global.uiModal) и если пауза уже открыта.
if (keyboard_check_pressed(vk_escape) && !global.uiModal && !instance_exists(oPauseMenu)) {
    instance_create_layer(0, 0, "Instances", oPauseMenu)
    exit
}

if (keyboard_check_pressed(vk_tab) && !global.uiModal) {
    oDeckBuilder.openBuilder()
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