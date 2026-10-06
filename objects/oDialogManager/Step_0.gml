if (!active) { exit }

if (!fullyRevealed()) { charProgress += charsPerStep }

var mouseClicked = mouse_check_button_pressed(mb_left)
var confirm = uiConfirmPressed()

var opts = currentOptions()
if (opts != undefined) {
    if (!fullyRevealed()) {
        if (confirm || mouseClicked) { charProgress = string_length(currentText()) }
    } else {
        var n = array_length(opts)
        if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) { selectedOption = (selectedOption - 1 + n) mod n }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) { selectedOption = (selectedOption + 1) mod n }

        // Мышь: наведение выбирает вариант, клик по варианту подтверждает.
        // Клик мимо вариантов ничего не выбирает, чтобы не ответить случайно
        var mouseGuiX = device_mouse_x_to_gui(0)
        var mouseGuiY = device_mouse_y_to_gui(0)
        var mouseMoved = (mouseGuiX != mouseLastX || mouseGuiY != mouseLastY)
        mouseLastX = mouseGuiX
        mouseLastY = mouseGuiY
        for (var optionIndex = 0; optionIndex < array_length(optionRects); optionIndex++) {
            var optionRect = optionRects[optionIndex]
            if (pointInRect(mouseGuiX, mouseGuiY, optionRect.x, optionRect.y, optionRect.w, optionRect.h)) {
                if (mouseMoved || mouseClicked) { selectedOption = optionIndex }
                if (mouseClicked) { confirm = true }
                break
            }
        }

        if (confirm) {
            var callback = opts[selectedOption].onSelect
            endDialog()
            if (callback != undefined) { callback() }
        }
    }
    exit
}

// Обычная реплика листается и клавишей, и кликом в любом месте
if (confirm || mouseClicked) { advance() }
