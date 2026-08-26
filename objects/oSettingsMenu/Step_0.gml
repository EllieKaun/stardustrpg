var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)

var mouseMoved = (mx != mouseLastX || my != mouseLastY)
var mouseClicked = mouse_check_button_pressed(mb_left)

menu.handleInput(mx, my, mouseMoved, mouseClicked)

if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
    if (menu.index == 0) {
        selectedResIndex = (selectedResIndex - 1 + array_length(resolutions)) mod array_length(resolutions)
        updateMenuLabels()
    } else if (menu.index == 1) {
        selectedFullscreen = !selectedFullscreen
        updateMenuLabels()
    }
}
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
    if (menu.index == 0) {
        selectedResIndex = (selectedResIndex + 1) mod array_length(resolutions)
        updateMenuLabels()
    } else if (menu.index == 1) {
        selectedFullscreen = !selectedFullscreen
        updateMenuLabels()
    }
}

if (keyboard_check_pressed(vk_escape)) {
    if (instance_exists(oMainMenu)) {
        with(oMainMenu) { visible = true; menuCooldown = 2; }
    }
    if (instance_exists(oPauseMenu)) {
        with(oPauseMenu) { visible = true; menuCooldown = 2; }
    }
    instance_destroy()
}

mouseLastX = mx
mouseLastY = my

menuUpdateLayers(backLayers, foreLayers)
