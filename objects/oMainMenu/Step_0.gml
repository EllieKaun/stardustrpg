// Анимация слоёв
menuUpdateLayers(backLayers, foreLayers)

// Ввод: клавиатура (внутри handleInput) + мышь
var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)
var mouseMoved = (mx != mouseLastX || my != mouseLastY)
mouseLastX = mx
mouseLastY = my
var mouseClicked = mouse_check_button_pressed(mb_left)

// hitRects заполняются в Draw GUI; на первом кадре пусты — тогда работает только
// клавиатура, это норм.
menu.handleInput(mx, my, mouseMoved, mouseClicked)
