// Анимация слоёв
menuUpdateLayers(backLayers, foreLayers)

// Первый кадр после открытия: игнорируем ввод, чтобы Esc, которым открыли паузу,
// не закрыл её тут же.
if (openedThisFrame) { openedThisFrame = false; exit }

// Esc — выйти из паузы. После close() инстанс уничтожен — дальше не работаем.
if (keyboard_check_pressed(vk_escape)) {
    close()
    exit
}

// Ввод меню (клавиатура + мышь)
var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)
var mouseMoved = (mx != mouseLastX || my != mouseLastY)
mouseLastX = mx
mouseLastY = my
var mouseClicked = mouse_check_button_pressed(mb_left)

menu.handleInput(mx, my, mouseMoved, mouseClicked)
