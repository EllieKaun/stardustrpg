var mouseX = device_mouse_x_to_gui(0)
var mouseY = device_mouse_y_to_gui(0)

var mouseMoved = (mouseX != mouseLastX || mouseY != mouseLastY)
var mouseClicked = mouse_check_button_pressed(mb_left)

menu.handleInput(mouseX, mouseY, mouseMoved, mouseClicked)

if (keyboard_check_pressed(vk_escape)) {
    selectedVolMaster = global.volMaster
    selectedVolMusic = global.volMusic
    selectedVolSounds = global.volSounds
    previewAudioVolumes()
    
    if (instance_exists(oMainMenu)) {
        with(oMainMenu) { 
            visible = true
            menuCooldown = 2
        }
    }
    if (instance_exists(oPauseMenu)) {
        with(oPauseMenu) { 
            visible = true
            menuCooldown = 2 
        }
    }
    instance_destroy()
}

mouseLastX = mouseX
mouseLastY = mouseY

menuUpdateLayers(backLayers, foreLayers)
