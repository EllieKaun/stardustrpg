menuEnsureCrispGui()

// Слои
backLayers = []
foreLayers = [
    new MenuLayer(noone, { name: "fg-back",  scrollX: 6,               placeholderColor: make_color_rgb(24, 28, 40) }),
    new MenuLayer(noone, { name: "fg-front", scrollX: 14, bobAmp: 3, bobFreq: 0.15, placeholderColor: make_color_rgb(34, 40, 56) })
]
itemsAboveForeground = true

menu = new Menu([
    new MenuItem("New Game", noone, noone, function(it) { show_debug_message("MainMenu: New Game") }),
    new MenuItem("Continue", noone, noone, function(it) { show_debug_message("MainMenu: Continue") }),
    new MenuItem("Settings", noone, noone, function(it) { show_debug_message("MainMenu: Settings") }),
    new MenuItem("Quit", noone, noone, function(it) { game_end() })
], {
    anchorX: 0.5, startY: 0.45, spacing: 0.11, textH: 0.055, halign: fa_center
})

// для детекта движения мыши
mouseLastX = -1
mouseLastY = -1
