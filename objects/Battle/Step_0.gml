var space = keyboard_check_pressed(vk_space)
if space {
    selectNextCharacter()
}

var leftPressed = keyboard_check_pressed(vk_left)
var rightPressed = keyboard_check_pressed(vk_right)
var changeIndex = leftPressed - rightPressed
if changeIndex != 0 {
    if changeIndex < 0 {
        selectedCard = selectedCard + 1 >= array_length(cards) ? 0 : selectedCard + 1
    } else {
        selectedCard = selectedCard - 1 < 0 ? array_length(cards) - 1 : selectedCard - 1
    }
}