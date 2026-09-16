chestKind = ChestKind.Gold
chestIndex = -1
interactDist = CHEST_INTERACT_DIST
depth = -y
openTimer = 0
chestState = ChestState.Closed
image_speed = 1
// Взаимодействие заблокировано (мир заморожен / скриптовый подход героя)
chestBlocked = function() {
    if (global.gamePaused || global.uiModal) return true
    if (variable_global_exists("cutsceneActive") && global.cutsceneActive) return true
    if (variable_global_exists("introWalk") && global.introWalk) return true
    return false
}

// Выдача награды / старт боя по типу сундука
doChestAction = function() {
    switch (chestKind) {
        case ChestKind.Gold:
            var amt = chestGoldAmount()
            addGold(amt)
            say([ dialogLine("Chest", noone, "left", "You found " + string(amt) + " gold!") ])
            instance_destroy()
        break

        case ChestKind.Card:
            var ref = rollOneReward(forestRewardPool())
            unlockCard(ref.id, ref.rarity, 1)
            var card = cardFromRef(ref)
            var cname = (card != undefined && variable_struct_exists(card, "name")) ? card.name : "a card"
            say([ dialogLine("Chest", noone, "left", "You found a card: " + cname + "!") ])
            instance_destroy()
        break

        case ChestKind.Enemy:
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
        break
    }
}

// Стейт-машина сундука: смена состояния + действия на входе
changeChestState = function(newState) {
    if (chestState == newState) { return } 
    chestState = newState

    switch (chestState) {
        case ChestState.Opening:
            openTimer = 0
            if (chestIndex >= 0 && chestIndex < array_length(global.chests)) {
                global.chests[chestIndex].opened = true
            }
        break

        case ChestState.Done:
            doChestAction()
        break
    }
}
