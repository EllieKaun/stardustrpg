menuEnsureCrispGui()
albumLayout(panel)

panel.stepMouse()
panel.focused = true
panel.step()

// Закрытие
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_tab)) {
    global.uiModal = false
    if (instance_exists(oMainMenu)) {
        with (oMainMenu) { visible = true; menuCooldown = 2; }
    }
    instance_destroy()
}
