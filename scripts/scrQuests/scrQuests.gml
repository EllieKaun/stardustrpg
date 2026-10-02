//// Квест сафара

function spearSprite() {
    var sprite = asset_get_index("spear")
    return sprite_exists(sprite) ? sprite : noone
}

function spearBattleSprite() {
    var sprite = asset_get_index("bigSpear")
    return sprite_exists(sprite) ? sprite : noone
}

function spearBattleBonus() {
    return SPEAR_BATTLE_BONUS
}

function questSpearState() {
    if (!variable_struct_exists(global.playerData, "questSafarSpear")) { global.playerData.questSafarSpear = QuestSpearState.Inactive }
    return global.playerData.questSafarSpear
}

function questSetSpearState(state) {
    global.playerData.questSafarSpear = state
    playerDataSave()
}

function questAcceptSpear() {
    questSetSpearState(QuestSpearState.Active)
    analyticsStartSafarQuest() // аналитика: начат квест Safar
    unlockCard(global.CardId.stealCard, CardsRarity.Default, 1)
    var slot = firstFreeDeckSlot(Characters.Lana)
    if (slot >= 0) { setDeckSlot(Characters.Lana, slot, global.CardId.stealCard, CardsRarity.Default) }
    playerDataSave()
    var rewardCard = cardFromRef({ id: global.CardId.stealCard, rarity: CardsRarity.Default })
    showCardReward(rewardCard, loc("ui.newCard") + " " + cardDisplayName(rewardCard))
}

function questGrantSpear() {
    if (questSpearState() == QuestSpearState.Active) {
        questSetSpearState(QuestSpearState.SpearObtained)
    }
    if (variable_global_exists("spearCarrierExists")) { global.spearCarrierExists = false }
    if (variable_global_exists("battleHasSpear")) { global.battleHasSpear = false }
}

function questCompleteSpear() {
    questSetSpearState(QuestSpearState.Completed)
    global.safarJoined = true
    analyticsCompleteSafarQuest() // аналитика
    playerDataSave()
}


//// Квест Лисий 

function questFoxState() {
    if (!variable_struct_exists(global.playerData, "questFox")) { global.playerData.questFox = QuestSpearState.Inactive }
    return global.playerData.questFox
}

function questSetFoxState(state) {
    global.playerData.questFox = state
    playerDataSave()
}

function questFoxItemCount(item) {
    switch (item) {
        case QuestFoxItem.Cauldron:
            
        break
        case QuestFoxItem.Petunia:
            
        break
        case QuestFoxItem.PineCone:
            
        break
    	
    }
}