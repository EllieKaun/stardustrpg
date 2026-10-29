depth = -bbox_bottom

if (global.gamePaused) { exit }

if (!leaderApproached(rearmDistance)) { exit }

if (instance_exists(oShop) && !oShop.open && !global.uiModal) {
    oShop.openShop()
}