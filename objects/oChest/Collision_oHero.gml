if (chestBlocked()) { exit }

if (chestState == ChestState.Closed) {
    changeChestState(ChestState.Opening)
}
