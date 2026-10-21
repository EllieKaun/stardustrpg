if (chestBlocked()) { exit }

var leader = oGameController.selected_character
if (!instance_exists(leader) || other.id != leader.id) { exit }

if (chestState == ChestState.Closed) {
    changeChestState(ChestState.Opening)
}
