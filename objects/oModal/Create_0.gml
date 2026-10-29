windows = []
uiModalBefore = false 
releasePending = false 
mouseLastX = -1
mouseLastY = -1

pushWindow = function(modalWindow) {
    if (array_length(windows) == 0 && !releasePending) {
        uiModalBefore = global.uiModal
    }
    releasePending = false 
    array_push(windows, modalWindow)
    global.uiModal = true
    modalWindow.enterPage(0)
    if (modalWindow.spec.onOpen != undefined) {
        modalWindow.spec.onOpen(modalWindow)
    }
}

topWindow = function() {
    var count = array_length(windows)
    return (count > 0) ? windows[count - 1] : undefined
}

hasWindow = function(tag) {
    for (var windowIndex = 0; windowIndex < array_length(windows); windowIndex++) {
        var modalWindow = windows[windowIndex]
        if (!modalWindow.closed && (tag == undefined || modalWindow.spec.tag == tag)) { 
            return true 
        }
    }
    return false
}

removeClosed = function() {
    var removed = false 
    for (var windowIndex = array_length(windows) - 1; windowIndex >= 0; windowIndex--) {
        if (windows[windowIndex].closed) {
            array_delete(windows, windowIndex, 1)
            removed = true
        }
    }
    if (removed && array_length(windows) == 0) {
        releasePending = true
    }
}

readInput = function() {
    var guiX = device_mouse_x_to_gui(0)
    var guiY = device_mouse_y_to_gui(0)
    var moved = (guiX != mouseLastX || guiY != mouseLastY)
    mouseLastX = guiX
    mouseLastY = guiY

    return {
        guiX: guiX,
        guiY: guiY,
        moved: moved,
        clicked: mouse_check_button_pressed(mb_left),
        confirm: uiConfirmPressed(),
        cancel: mouse_check_button_pressed(mb_right) 
                || keyboard_check_pressed(vk_escape) 
                || keyboard_check_pressed(ord("C")),
        left: keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")),
        right: keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")),
        up: keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")),
        down: keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))
    }
}