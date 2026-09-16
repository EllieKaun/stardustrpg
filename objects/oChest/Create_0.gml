chestKind = ChestKind.Gold
chestIndex = -1
opened = false
interactDist = CHEST_INTERACT_DIST
depth = -y

chestState = ChestState.Closed
openTimer = 0

doChestAction = function() {
    if (chestState == ChestState.Done) return
    chestState = ChestState.Done
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
