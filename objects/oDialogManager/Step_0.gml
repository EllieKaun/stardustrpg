if (!active) { exit }

if (!fullyRevealed()) { charProgress += charsPerStep }

var confirm = uiConfirmPressed()

var opts = currentOptions()
if (opts != undefined) {
    if (!fullyRevealed()) {
        if (confirm) { charProgress = string_length(currentText()) }
    } else {
        var n = array_length(opts)
        if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) { selectedOption = (selectedOption - 1 + n) mod n }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) { selectedOption = (selectedOption + 1) mod n }
        if (confirm) {
            var callback = opts[selectedOption].onSelect
            endDialog()
            if (callback != undefined) { callback() }
        }
    }
    exit
}

if (confirm) { advance() }