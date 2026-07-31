// F11 — borderless на весь экран ↔ окно
if (keyboard_check_pressed(vk_f11)) {
    setDisplayMode(!global.displayFullscreen)
}

// Esc — переключатель паузы (единственный обработчик, чтобы не было гонки
// открыл/закрыл на одном нажатии). Открываем только если нет другой модалки
// (деккбилдер/диалог ставят global.uiModal).
if (keyboard_check_pressed(vk_escape)) {
    if (instance_exists(oPauseMenu)) {
        with (oPauseMenu) close()
    } else if (!global.uiModal) {
        instance_create_layer(0, 0, "Instances", oPauseMenu)
    }
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