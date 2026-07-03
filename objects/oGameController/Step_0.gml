if (keyboard_check_pressed(vk_tab) && !global.uiModal) {
    //oDeckBuilder.openBuilder()
    say([
    dialogLine("Lana", placeholderLana, "left",
        "Hey hey"),
    dialogLine("Viv", placeholderViv, "right",
        "Yeh yeh")
], function() {
    show_debug_message("dialog finished");
    // e.g. start the boss fight, unlock a door, advance a quest flag...
});
}