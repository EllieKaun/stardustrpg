randomize()
cardIdsInit()
cardRegistryInit()
playerDataInit()
if (!instance_exists(oTransition)) {
    instance_create_layer(0, 0, "Instances", oTransition)
}
global.battleSection = 1
global.uiModal = false
global.zoneConfig = {
    cx: room_width / 2,
    cy: room_height / 2,
    innerHalf:  240,
    middleHalf: 480 
}
