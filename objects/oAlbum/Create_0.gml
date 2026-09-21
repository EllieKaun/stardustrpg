menuEnsureCrispGui()

if (!variable_global_exists("cardRegistry")) {
    cardIdsInit()
    cardRegistryInit()
}

if (!variable_global_exists("playerData")) {
    if (!(file_exists(PLAYER_SAVE_FILE) && playerDataLoad())) {
        global.playerData = playerDataDefault()
    }
}

panel = albumMakePanel()
albumLayout(panel)

global.uiModal = true
