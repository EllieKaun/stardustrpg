menuEnsureCrispGui()

// Загрузка настроек
initAudioVolumes()
initDisplaySettings()

// Слои
backLayers = [new MenuLayer(MainMenuBack, { name: "fg-back" })]
foreLayers = [
    new MenuLayer(MainMenuViv, { name: "fg-back", bobAmp: -0.015, bobFreq: 0.14, scale: 1.10, placeholderColor: make_color_rgb(24, 28, 40) }),
    new MenuLayer(MainMenuLana, { name: "fg-front", bobAmp: 0.025, bobFreq: 0.14, scale: 1.14, placeholderColor: make_color_rgb(34, 40, 56) })
]
itemsAboveForeground = true

hasSave = file_exists(PLAYER_SAVE_FILE)
confirmPrompt = ""
menuCooldown = 0

menuConfig = { anchorX: 0.75, startY: 0.45, spacing: 0.11, textH: 0.055, halign: fa_center }

startNewGameNow = function() {
    global.startNewGame = true
    room_goto(DemoWorld)
}
startContinue = function() {
    global.startNewGame = false
    room_goto(DemoWorld)
}
openSettings = function() {
    visible = false
    instance_create_layer(0, 0, "Instances", oSettingsMenu)
}
openAlbum = function() {
    visible = false
    instance_create_layer(0, 0, "Instances", oAlbum)
}

buildMainMenu = function() {
    var items = []
    if (hasSave) {
        array_push(items, new MenuItem("Continue", noone, noone, function(it) { startContinue() }))
    }
    array_push(items, new MenuItem("New Game", noone, noone, function(it) {
        if (hasSave) {
            confirmPrompt = "Overwrite your save?"
            menu = buildConfirmMenu()
            menuCooldown = 2
        } else {
            startNewGameNow()
        }
    }))
    array_push(items, new MenuItem("Album", noone, noone, function(it) { openAlbum() }))
    array_push(items, new MenuItem("Settings", noone, noone, function(it) { openSettings() }))
    array_push(items, new MenuItem("Quit", noone, noone, function(it) { game_end() }))
    return new Menu(items, menuConfig)
}

buildConfirmMenu = function() {
    return new Menu([
        new MenuItem("No, keep playing", noone, noone, function(it) {
            confirmPrompt = ""
            menu = buildMainMenu()
            menuCooldown = 2
        }),
        new MenuItem("Yes, start new game", noone, noone, function(it) {
            startNewGameNow()
        })
    ], menuConfig)
}

menu = buildMainMenu()

playMusicNamed("MainMenuMusic") // музыка меню

// для детекта движения мыши
mouseLastX = -1
mouseLastY = -1
