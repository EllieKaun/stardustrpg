menuEnsureCrispGui()

// Загрузка настроек
ini_open("settings.ini")
var resInd = ini_read_real("Display", "ResolutionIndex", 2)
var fs = ini_read_real("Display", "Fullscreen", 0)
ini_close()

var res = [
    [1280, 720],
    [1600, 900],
    [1920, 1080],
    [2560, 1440],
    [3840, 2160]
]
if (resInd >= 0 && resInd < array_length(res)) {
    window_set_fullscreen(fs)
    if (!fs) {
        window_set_size(res[resInd][0], res[resInd][1])
    }
}

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
    new MenuItem("Settings", noone, noone, function(it) { 
        visible = false
        instance_create_layer(0, 0, "Instances", oSettingsMenu) 
    }),
    new MenuItem("Quit", noone, noone, function(it) { game_end() })
], {
    anchorX: 0.75, startY: 0.45, spacing: 0.11, textH: 0.055, halign: fa_center
})

menu.items[1].enabled = hasSave

// для детекта движения мыши
mouseLastX = -1
mouseLastY = -1

menuCooldown = 0
