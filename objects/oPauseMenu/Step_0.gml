// Анимация слоёв
menuUpdateLayers(backLayers, foreLayers)

// Esc (открыть/закрыть паузу) обрабатывает oGameController — здесь его не читаем,
// чтобы не было двойного срабатывания на одном нажатии.

// Ввод меню (клавиатура + мышь)
var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)
var mouseMoved = (mx != mouseLastX || my != mouseLastY)
mouseLastX = mx
mouseLastY = my
var mouseClicked = mouse_check_button_pressed(mb_left)

menu.handleInput(mx, my, mouseMoved, mouseClicked)
