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
    analyticsNewGame() // аналитика: новая игра
    room_goto(DemoWorld)
}
startContinue = function() {
    global.startNewGame = false
    analyticsContinue() // аналитика: продолжить игру
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
        array_push(items, new MenuItem(loc("menu.continue"), noone, noone, function(it) { startContinue() }))
    }
    array_push(items, new MenuItem(loc("menu.newGame"), noone, noone, function(it) {
        if (hasSave) {
            confirmPrompt = loc("menu.overwriteSave")
            menu = buildConfirmMenu()
            menuCooldown = 2
        } else {
            startNewGameNow()
        }
    }))
    array_push(items, new MenuItem(loc("menu.album"), noone, noone, function(it) { openAlbum() }))
    array_push(items, new MenuItem(loc("menu.settings"), noone, noone, function(it) { openSettings() }))
    array_push(items, new MenuItem(loc("menu.quit"), noone, noone, function(it) { game_end() }))
    return new Menu(items, menuConfig)
}

buildConfirmMenu = function() {
    return new Menu([
        new MenuItem(loc("menu.noKeepPlaying"), noone, noone, function(it) {
            confirmPrompt = ""
            menu = buildMainMenu()
            menuCooldown = 2
        }),
        new MenuItem(loc("menu.yesNewGame"), noone, noone, function(it) {
            startNewGameNow()
        })
    ], menuConfig)
}

menu = buildMainMenu()

rebuildMenu = function() { menu = buildMainMenu() }

playMusicNamed("MainMenuMusic") // музыка меню

// для детекта движения мыши
mouseLastX = -1
mouseLastY = -1
