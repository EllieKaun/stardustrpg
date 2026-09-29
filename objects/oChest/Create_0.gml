chestKind = ChestKind.Gold
chestIndex = -1
interactDist = CHEST_INTERACT_DIST
depth = -y
openTimer = 0
chestState = ChestState.Closed
image_speed = 1

chestBlocked = function() {
    if (global.gamePaused || global.uiModal) { return true }
    if (variable_global_exists("cutsceneActive") && global.cutsceneActive) { return true }
    if (variable_global_exists("introWalk") && global.introWalk) { return true }
    return false
}

doChestAction = function() {
    analyticsChestOpen(chestKind) 
    switch (chestKind) {
        case ChestKind.Gold:
            var goldAmount = chestGoldAmount()
            addGold(goldAmount)
            analyticsChestGold(goldAmount)
            say([ dialogLine("Chest", noone, loc("chest.goldPre") + string(goldAmount) + loc("chest.goldPost")) ])
            instance_destroy()
        break

        case ChestKind.Card:
            var rewardRef = rollOneReward(forestRewardPool())
            unlockCard(rewardRef.id, rewardRef.rarity, 1)
            analyticsReward(rewardRef.id, rewardRef.rarity, "chest")
            var card = cardFromRef(rewardRef)
            var cardName = (card != undefined) ? cardDisplayName(card) : loc("chest.aCard")
            say([ dialogLine("Chest", noone, loc("chest.cardPre") + cardName + loc("chest.cardPost")) ])
            instance_destroy()
        break

        case ChestKind.Enemy:
            say([ dialogLine("Chest", noone, loc("chest.trap")) ], method(id, function() { startChestBattle() }))
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
