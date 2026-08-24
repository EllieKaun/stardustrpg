menuEnsureCrispGui()

// Слои
backLayers = [new MenuLayer(MainMenuBack, { name: "fg-back" })]
foreLayers = [
    new MenuLayer(MainMenuViv, { name: "fg-back", bobAmp: 0.015, bobFreq: 0.08, scale: 1.10, placeholderColor: make_color_rgb(24, 28, 40) }),
    new MenuLayer(MainMenuLana, { name: "fg-front", bobAmp: 0.025, bobFreq: 0.12, scale: 1.14, placeholderColor: make_color_rgb(34, 40, 56) })
]
itemsAboveForeground = true

var hasSave = file_exists(PLAYER_SAVE_FILE)

menu = new Menu([
    new MenuItem("New Game", noone, noone, function(it) { 
        global.startNewGame = true
        room_goto(DemoWorld) 
    }),
    new MenuItem("Continue", noone, noone, function(it) { 
        global.startNewGame = false
        room_goto(DemoWorld) 
    }),
    new MenuItem("Settings", noone, noone, function(it) { show_debug_message("MainMenu: Settings") }),
    new MenuItem("Quit", noone, noone, function(it) { game_end() })
], {
    anchorX: 0.75, startY: 0.45, spacing: 0.11, textH: 0.055, halign: fa_center
})

menu.items[1].enabled = hasSave

playMusicNamed("MainMenuMusic") // музыка меню

// для детекта движения мыши
mouseLastX = -1
mouseLastY = -1
