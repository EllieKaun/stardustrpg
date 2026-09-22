chestKind = ChestKind.Gold
chestIndex = -1
interactDist = CHEST_INTERACT_DIST
depth = -y
openTimer = 0
chestState = ChestState.Closed
image_speed = 1

chestBlocked = function() {
    if (global.gamePaused || global.uiModal) return true
    if (variable_global_exists("cutsceneActive") && global.cutsceneActive) return true
    if (variable_global_exists("introWalk") && global.introWalk) return true
    return false
}

doChestAction = function() {
    switch (chestKind) {
        case ChestKind.Gold:
            var goldAmount = chestGoldAmount()
            addGold(goldAmount)
            say([ dialogLine("Chest", noone, "You found " + string(goldAmount) + " gold!") ])
            instance_destroy()
        break

        case ChestKind.Card:
            var rewardRef = rollOneReward(forestRewardPool())
            unlockCard(rewardRef.id, rewardRef.rarity, 1)
            var card = cardFromRef(rewardRef)
            var cardName = (card != undefined && variable_struct_exists(card, "name")) ? card.name : "a card"
            say([ dialogLine("Chest", noone, "You found a card: " + cardName + "!") ])
            instance_destroy()
        break

        case ChestKind.Enemy:
            // Сначала показываем, что это ловушка, бой начинается после диалога
            say([ dialogLine("Chest", noone, "It's a trap!") ], method(id, function() { startChestBattle() }))
        break
    }
}

startChestBattle = function() {
    var leader = oGameController.selected_character
    global.fightEnemy = noone
    global.returningFromBattle = true
    global.battleSection = Section.TopLeft
    global.battleEncounter = makeEncounter(winScaledComposition(), forestRewardPool())
    global.battleNoFlee = true
    global.returnRoom = room
    global.returnX = leader.x
    global.returnY = leader.y
    leader.can_move = false
    with (oTransition) {
        target_room = BattleRoom
        state = "fade_out"
    }
}

changeChestState = function(newState) {
    if (chestState == newState) { return } 
    chestState = newState

    switch (chestState) {
        case ChestState.Opening:
            playChestOpenSound()
            sprite_index = sprChestOpen
            if (chestIndex >= 0 && chestIndex < array_length(global.chests)) {
                global.chests[chestIndex].opened = true
            }
        break

        case ChestState.Done:
            image_speed = 0
            doChestAction()
        break
    }
}
