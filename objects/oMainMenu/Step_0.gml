if (!visible) { exit }

if (menuCooldown > 0) {
    menuCooldown--
    exit
}

// Анимация слоёв
menuUpdateLayers(backLayers, foreLayers)

// Ввод: клавиатура + мышь
var mouseX = device_mouse_x_to_gui(0)
var mouseY = device_mouse_y_to_gui(0)
var mouseMoved = (mouseX != mouseLastX || mouseY != mouseLastY)
mouseLastX = mouseX
mouseLastY = mouseY
var mouseClicked = mouse_check_button_pressed(mb_left)

menu.handleInput(mouseX, mouseY, mouseMoved, mouseClicked)
