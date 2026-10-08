if (global.gamePaused || global.uiModal) { exit }

depth = -bbox_bottom

if (pickId != "" && questIsPicked(questId, pickId)) { instance_destroy(); exit }

if (questState(questId) != QuestState.Active) { exit }

if (!canBePicked()) { exit }

var leader = oGameController.selected_character

if (instance_exists(leader) && place_meeting(x, y, leader)) {
    playSfx(pickupSound, 8, false)
    questAddProgress(questId, itemKind)
    questMarkPicked(questId, pickId)
    instance_destroy()
}
