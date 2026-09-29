if (!active) { exit }
if (inputGuard > 0) { 
    inputGuard--
    exit 
}

if (mouse_check_button_pressed(mb_left) || uiConfirmPressed()) {
    active = false
    global.uiModal = false
    instance_destroy()
}
