randomize()
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