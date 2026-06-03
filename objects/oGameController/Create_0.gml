cardRegistryInit()
playerDataInit()

if (!instance_exists(oTransition)) {
    instance_create_layer(0, 0, "Instances", oTransition)
}
global.uiModal = false