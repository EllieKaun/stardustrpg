if (global.gamePaused || global.uiModal) { exit }

depth = -bbox_bottom

if (pickId != "" && questFoxIsPicked(pickId)) { instance_destroy(); exit }

if (questFoxState() != QuestFoxState.Active) { exit }

if (!canBePicked()) { exit }

var leader = oGameController.selected_character

if (instance_exists(leader) && place_meeting(x, y, leader)) {
    playSfx(pickupSound, 8, false)
    questFoxAddItem(itemKind)
    questFoxMarkPicked(pickId)
    instance_destroy()
}
