randomize()

// --- Режим отображения: borderless (безрамочный на весь экран) / окно --------
setDisplayMode = function(fullscreen) {
    global.displayFullscreen = fullscreen
    if (fullscreen) {
        // безрамочное окно в размер экрана
        window_set_showborder(false)
        window_set_size(display_get_width(), display_get_height())
        window_set_position(0, 0)
    } else {
        // обычное окно 4× базового разрешения (1280×720), по центру
        var ww = 1280, wh = 720
        window_set_showborder(true)
        window_set_size(ww, wh)
        window_set_position((display_get_width() - ww) div 2, (display_get_height() - wh) div 2)
    }
}
// применяем borderless один раз за запуск (Create может сработать повторно при
// возврате в комнату — тогда не сбрасываем выбранный игроком режим)
if (!variable_global_exists("displayModeReady")) {
    global.displayModeReady = true
    setDisplayMode(true)
}
uiFontInit() // кэш UI-шрифта и высоты строки (см. scrDrawing)
initEffectRegistry() // регистрация эффектов
cardIdsInit() // инициализация карт ид
cardRegistryInit() // регистация карт  
playerDataInit() // инициализация данных пользователя
if (!instance_exists(oTransition)) {
    instance_create_layer(0, 0, "Instances", oTransition)
}

partyMembers = [oLana, oViv]
selectedIndex = 0;
selected_character = partyMembers[0]

global.mpGrid = -1 // Motion Planning
global.battleSection = 1
global.uiModal = false // Флаг для метки если запускается какое-то модальное окно, чтобы блокировать движение в основном экране
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