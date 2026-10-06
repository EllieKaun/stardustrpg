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


//// Квест Лисички 

// Сколько нужно предметов для квеста Лисички
#macro FOX_PINE_CONES_NEEDED 3
#macro FOX_PETUNIAS_NEEDED 1
#macro FOX_CAULDRONS_NEEDED 1

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
            return global.playerData.questFoxCauldrons
        
        case QuestFoxItem.Petunia:
            return global.playerData.questFoxPetunias
        
        case QuestFoxItem.PineCone:
            return global.playerData.questFoxPineCones
        
    }
}

// Иконка предмета
function questFoxItemSprite(item) {
    var spriteName = ""
    switch (item) {
        case QuestFoxItem.PineCone: 
            spriteName = "PineConeIcon" 
        break
        case QuestFoxItem.Petunia:  
            spriteName = "PetuniaIcon"  
        break
        case QuestFoxItem.Cauldron: 
            spriteName = "CauldronIcon" 
        break
    }
    var spr = asset_get_index(spriteName)
    return sprite_exists(spr) ? spr : noone
}

// Подбор предмета в мире
function questFoxRegisterPickupFx(item) {
    if (!variable_global_exists("foxItemPickupTime")) { 
        global.foxItemPickupTime = [0, 0, 0] 
    }
    global.foxItemPickupTime[item] = current_time
}

// Масштаб иконки для отклика на подбор
function questFoxItemPickupScale(item) {
    if (!variable_global_exists("foxItemPickupTime")) { return 1 }
    var popDuration = 0.3
    var elapsed = (current_time - global.foxItemPickupTime[item]) / 1000
    if (elapsed < 0 || elapsed >= popDuration) { return 1 }
    return lerp(1.4, 1, elapsed / popDuration)
}

function questFoxItemNeeded(item) {
    switch (item) {
        case QuestFoxItem.Cauldron:
            return FOX_CAULDRONS_NEEDED
        
        case QuestFoxItem.Petunia:
            return FOX_PETUNIAS_NEEDED
        
        case QuestFoxItem.PineCone:
            return FOX_PINE_CONES_NEEDED
        
    }
}

function questFoxItemDone(item) {
    return questFoxItemCount(item) >= questFoxItemNeeded(item)
}

function questFoxAddItem(item) {
    switch (item) {
        case QuestFoxItem.Cauldron:
            global.playerData.questFoxCauldrons = global.playerData.questFoxCauldrons + 1
        break
        case QuestFoxItem.Petunia:
            global.playerData.questFoxPetunias = global.playerData.questFoxPetunias + 1
        break
        case QuestFoxItem.PineCone:
             global.playerData.questFoxPineCones = global.playerData.questFoxPineCones + 1
        break
    }
    questFoxRegisterPickupFx(item)
    if (questFoxAllCollected()) {
        questSetFoxState(QuestFoxState.ItemsCollected)
    }
    playerDataSave()
}

function questFoxAllCollected() {
    return questFoxItemDone(QuestFoxItem.Cauldron)
        && questFoxItemDone(QuestFoxItem.Petunia)
        && questFoxItemDone(QuestFoxItem.PineCone)
}

function foxShowsQuestMarker() {
    if (global.uiModal) { return false }
        
    var state = questFoxState()
    return state == QuestFoxState.Inactive 
        || state == QuestFoxState.ItemsCollected
}

function questFoxAccept() {
    questSetFoxState(QuestFoxState.Active)
    unlockCard(global.CardId.stealCard, CardsRarity.Default, 1)
    var slot = firstFreeDeckSlot(Characters.Lana)
    if (slot >= 0) { setDeckSlot(Characters.Lana, slot, global.CardId.stealCard, CardsRarity.Default) }
    playerDataSave()
    var rewardCard = cardFromRef({ id: global.CardId.stealCard, rarity: CardsRarity.Default })
    showCardReward(rewardCard, loc("ui.newCard") + " " + cardDisplayName(rewardCard))
}

function questFoxIsPicked(pickId) {
    if (pickId == "") { return false }
    if (!variable_struct_exists(global.playerData, "questFoxPickedIds")) { global.playerData.questFoxPickedIds = [] }
    return array_contains(global.playerData.questFoxPickedIds, pickId)
}

function questFoxMarkPicked(pickId) {
    if (pickId == "") { return }
    if (!variable_struct_exists(global.playerData, "questFoxPickedIds")) { global.playerData.questFoxPickedIds = [] }
    if (!array_contains(global.playerData.questFoxPickedIds, pickId)) {
        array_push(global.playerData.questFoxPickedIds, pickId)
        playerDataSave()
    }
}

function cauldronSprite() {
    var sprite = asset_get_index("sprCauldronSmall")
    return sprite_exists(sprite) ? sprite : noone
}

function questFoxComplete() {
    questSetFoxState(QuestFoxState.Completed)
    global.foxJoined = true
    unlockCard(global.CardId.instantManaGainSingleTarget, CardsRarity.Unusual, 1)
    playerDataSave()
    var rewardCard = cardFromRef({ id: global.CardId.instantManaGainSingleTarget, rarity: CardsRarity.Unusual })
    showCardReward(rewardCard, loc("ui.newCard") + " " + cardDisplayName(rewardCard))
}