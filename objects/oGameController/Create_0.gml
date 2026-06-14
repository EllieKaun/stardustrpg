randomize()
cardRegistryInit()
playerDataInit()

if (!instance_exists(oTransition)) {
    instance_create_layer(0, 0, "Instances", oTransition)
}
global.uiModal = false
global.battleRewardPool = { ids: [], rarities: [CardsRarity.Default] }
global.battleEncounter = createCrackerNutEncounter
global.zoneConfig = {
    cx: room_width / 2,
    cy: room_height / 2,
    innerHalf:  120,
    middleHalf: 240 
}