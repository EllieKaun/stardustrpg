prevGuiW = display_get_gui_width()
prevGuiH = display_get_gui_height()
menuEnsureCrispGui()

global.gamePaused = true
global.uiModal = true

close = function() {
    global.gamePaused = false
    global.uiModal = false
    display_set_gui_size(prevGuiW, prevGuiH)
    instance_destroy()
}

backLayers = [
    new MenuLayer(noone, { alpha: 0.55, placeholderColor: make_color_rgb(6, 8, 14) })
]
foreLayers = [
    new MenuLayer(PauseLana, { name: "pause-fg", scrollX: 0, alpha: 1, placeholderColor: make_color_rgb(40, 46, 64) })
]
itemsAboveForeground = true

menu = new Menu([
    new MenuItem("Resume", noone, noone, method(id, function(it) { close() })),
    new MenuItem("Settings", noone, noone, function(it) { 
        visible = false
        instance_create_layer(0, 0, "Instances", oSettingsMenu) 
    }),
    new MenuItem("Quit", noone, noone, function(it) { game_end() })
], {
    anchorX: 0.6, startY: 0.5, spacing: 0.12, textH: 0.06, halign: fa_center
})

mouseLastX = -1
mouseLastY = -1

menuCooldown = 0
