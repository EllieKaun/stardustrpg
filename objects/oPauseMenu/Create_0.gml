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
    new MenuLayer(noone, { name: "pause-bg", alpha: 0.55, placeholderColor: make_color_rgb(6, 8, 14) })
]
foreLayers = [
    new MenuLayer(noone, { name: "pause-fg", scrollX: 8, alpha: 0.18, placeholderColor: make_color_rgb(40, 46, 64) })
]
itemsAboveForeground = true

menu = new Menu([
    new MenuItem("Resume", noone, noone, method(id, function(it) { close() })),
    new MenuItem("Settings", noone, noone, function(it) { show_debug_message("Pause: Settings") }),
    new MenuItem("Quit", noone, noone, function(it) { game_end() })
], {
    anchorX: 0.5, startY: 0.42, spacing: 0.12, textH: 0.06, halign: fa_center
})

mouseLastX = -1
mouseLastY = -1
