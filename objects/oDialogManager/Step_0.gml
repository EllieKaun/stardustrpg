if (!active) exit

if (!fullyRevealed()) charProgress += charsPerStep

var confirm = uiConfirmPressed()

var opts = currentOptions()
if (opts != undefined) {
    if (!fullyRevealed()) {
        if (confirm) charProgress = string_length(currentText())
    } else {
        var n = array_length(opts)
        if (keyboard_check_pressed(vk_up))   selectedOption = (selectedOption - 1 + n) mod n
        if (keyboard_check_pressed(vk_down)) selectedOption = (selectedOption + 1) mod n
        if (confirm) {
            var cb = opts[selectedOption].onSelect
            endDialog()
            if (cb != undefined) cb()
        }
    }
    exit
}

if (confirm) advance()