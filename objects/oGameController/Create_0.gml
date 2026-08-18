randomize()

gpu_set_tex_filter(false)

// --- Режим отображения: borderless (безрамочный на весь экран) / окно --------
setDisplayMode = function(fullscreen) {
    global.displayFullscreen = fullscreen
    if (fullscreen) {
        // полноэкранный режим
        window_set_showborder(false)
        window_set_size(display_get_width(), display_get_height())
        window_set_position(0, 0)
    } else {
        // обычное окно
        var ww = 1280, wh = 720
        window_set_showborder(true)
        window_set_size(ww, wh)
        window_set_position((display_get_width() - ww) div 2, (display_get_height() - wh) div 2)
    }
}
// применяем borderless
if (!variable_global_exists("displayModeReady")) {
    global.displayModeReady = true
    setDisplayMode(true)
}
uiFontInit() // кэш UI-шрифта и высоты строки
initEffectRegistry() // регистрация эффектов
cardIdsInit() // инициализация карт ид
cardRegistryInit() // регистация карт  
if (variable_global_exists("startNewGame") && global.startNewGame) {
    global.startNewGame = false
    playerDataNewGame() // новая игра 
} else {
    playerDataInit() // инициализация данных пользователя
}
if (!instance_exists(oTransition)) {
    instance_create_layer(0, 0, "Instances", oTransition)
}

partyMembers = [oLana, oViv]
selectedIndex = 0;
selected_character = partyMembers[0]

global.walkSound = asset_get_index("GrassWalk") // звук ходьбы по траве (-1 пока ассета нет)

global.returningFromBattle = false // флаг возврата из боя (обрабатывается на Room Start)
global.fightEnemy = noone           // враг, с которым дрались

global.mpGrid = -1 // Motion Planning
global.battleSection = 1
global.uiModal = false // Флаг для метки если запускается какое-то модальное окно, чтобы блокировать движение в основном экране
global.gamePaused = false // Полная пауза мира 
global.zoneConfig = { // нужно для определение секций и зон на карте
    cx: room_width / 2,
    cy: room_height / 2,
    innerHalf:  240, // ширина внутренней зоны
    middleHalf: 480  // ширина средней зоны
}
switchCharacter = function() {
    if (global.uiModal) {
        return
    }
    selectedIndex = (selectedIndex + 1) % array_length(partyMembers)
    selected_character = partyMembers[selectedIndex]
}