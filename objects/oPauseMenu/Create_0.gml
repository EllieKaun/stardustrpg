menuEnsureCrispGui()
depth = -10000 // поверх интерфейса боя

global.gamePaused = true
global.uiModal = true

close = function() {
    global.gamePaused = false
    global.uiModal = false
    instance_destroy()
}

toMainMenu = function() {
    global.gamePaused = false
    global.uiModal = false
    room_goto(MainMenuRoom)
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
    new MenuItem(loc("menu.resume"), noone, noone, method(id, function(it) { close() })),
    new MenuItem(loc("menu.settings"), noone, noone, function(it) {
        visible = false
        instance_create_layer(0, 0, "Instances", oSettingsMenu)
    }),
    new MenuItem(loc("menu.mainMenu"), noone, noone, method(id, function(it) { toMainMenu() })),
    new MenuItem(loc("menu.quit"), noone, noone, function(it) { game_end() })
], {
    anchorX: 0.6, startY: 0.5, spacing: 0.12, textH: 0.06, halign: fa_center
})

rebuildMenu = function() {
    menu.items[0].label = loc("menu.resume")
    menu.items[1].label = loc("menu.settings")
    menu.items[2].label = loc("menu.mainMenu")
    menu.items[3].label = loc("menu.quit")
}

mouseLastX = -1
mouseLastY = -1

menuCooldown = 0
