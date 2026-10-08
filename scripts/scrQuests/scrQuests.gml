//// Квестовый движок (data-driven)

// Хранилище прогресса: playerData.quests[$ string(questId)] = { state, counters, picked }
function questStore() {
    if (!variable_struct_exists(global.playerData, "quests")) { global.playerData.quests = {} }
    return global.playerData.quests
}

function questRecord(questId) {
    var store = questStore()
    var key = string(questId)
    if (!variable_struct_exists(store, key)) {
        store[$ key] = { state: QuestState.Inactive, counters: {}, picked: [] }
    }
    return store[$ key]
}

function questState(questId) {
    return questRecord(questId).state
}

function questSetState(questId, state) {
    questRecord(questId).state = state
    playerDataSave()
}

function questCounter(questId, key) {
    var counters = questRecord(questId).counters
    var counterKey = string(key)
    return variable_struct_exists(counters, counterKey) ? counters[$ counterKey] : 0
}

function questSetCounter(questId, key, value) {
    questRecord(questId).counters[$ string(key)] = value
}

function questIsPicked(questId, pickId) {
    if (pickId == "") { return false }
    return array_contains(questRecord(questId).picked, pickId)
}

function questMarkPicked(questId, pickId) {
    if (pickId == "") { return }
    var picked = questRecord(questId).picked
    if (!array_contains(picked, pickId)) {
        array_push(picked, pickId)
        playerDataSave()
    }
}

// Реестр определений квестов
function questEnsureRegistry() {
    if (variable_global_exists("questRegistry")) { return }
    global.questRegistry = {}
    global.questOrderList = []
    questRegisterAll()
}

function questRegister(def) {
    global.questRegistry[$ string(def.id)] = def
    array_push(global.questOrderList, def.id)
}

function questDef(questId) {
    questEnsureRegistry()
    return global.questRegistry[$ string(questId)]
}

// Определения квестов
function questRegisterAll() {
    questRegister({
        id: QuestId.Fox,
        objectives: [
            { type: QuestObjectiveType.Collect, key: QuestFoxItem.PineCone, count: FOX_PINE_CONES_NEEDED, sprite: "PineConeIcon" },
            { type: QuestObjectiveType.Collect, key: QuestFoxItem.Petunia,  count: FOX_PETUNIAS_NEEDED,  sprite: "PetuniaIcon" },
            { type: QuestObjectiveType.Collect, key: QuestFoxItem.Cauldron, count: FOX_CAULDRONS_NEEDED,  sprite: "CauldronIcon" }
        ],
        readyHint: "ui.returnToFox",
        onAccept: function() {
            questGrantCardReward(global.CardId.stealCard, CardsRarity.Default, Characters.Lana)
        },
        onComplete: function() {
            global.foxJoined = true
            questGrantCardReward(global.CardId.instantManaGainSingleTarget, CardsRarity.Unusual, undefined)
        }
    })

    questRegister({
        id: QuestId.Safar,
        objectives: [
            { type: QuestObjectiveType.ObtainItem, key: QuestSafarItem.Spear, count: 1, sprite: "" }
        ],
        readyHint: "",
        onAccept: function() {
            analyticsStartSafarQuest()
            questGrantCardReward(global.CardId.stealCard, CardsRarity.Default, Characters.Lana)
        },
        onComplete: function() {
            global.safarJoined = true
            analyticsCompleteSafarQuest()
        }
    })
}

// Награда картой: открыть, по желанию положить в деку героя, показать награду
function questGrantCardReward(cardId, rarity, character) {
    unlockCard(cardId, rarity, 1)
    if (character != undefined) {
        var slot = firstFreeDeckSlot(character)
        if (slot >= 0) { setDeckSlot(character, slot, cardId, rarity) }
    }
    playerDataSave()
    var rewardCard = cardFromRef({ id: cardId, rarity: rarity })
    showCardReward(rewardCard, loc("ui.newCard") + " " + cardDisplayName(rewardCard))
}

function questObjectiveSprite(objective) {
    if (!variable_struct_exists(objective, "sprite") || objective.sprite == "") { return noone }
    var spr = asset_get_index(objective.sprite)
    return sprite_exists(spr) ? spr : noone
}

function questObjectiveDone(questId, objective) {
    return questCounter(questId, objective.key) >= objective.count
}

function questAllObjectivesDone(questId) {
    var objs = questDef(questId).objectives
    for (var i = 0; i < array_length(objs); i++) {
        if (!questObjectiveDone(questId, objs[i])) { return false }
    }
    return true
}

// Переходы состояний
function questAccept(questId) {
    questSetState(questId, QuestState.Active)
    var def = questDef(questId)
    if (variable_struct_exists(def, "onAccept") && def.onAccept != undefined) { def.onAccept() }
}

function questAddProgress(questId, key, amount = 1) {
    if (questState(questId) != QuestState.Active) { return }
    questSetCounter(questId, key, questCounter(questId, key) + amount)
    questRegisterPickupFx(questId, key)
    if (questAllObjectivesDone(questId)) { questSetState(questId, QuestState.Ready) }
    playerDataSave()
}

function questComplete(questId) {
    questSetState(questId, QuestState.Completed)
    var def = questDef(questId)
    if (variable_struct_exists(def, "onComplete") && def.onComplete != undefined) { def.onComplete() }
    playerDataSave()
}

// Отклик на подбор (масштаб иконки), эфемерно, не сохраняется
function questRegisterPickupFx(questId, key) {
    if (!variable_global_exists("questPickupFxTime")) { global.questPickupFxTime = {} }
    var questKey = string(questId)
    if (!variable_struct_exists(global.questPickupFxTime, questKey)) { global.questPickupFxTime[$ questKey] = {} }
    global.questPickupFxTime[$ questKey][$ string(key)] = current_time
}

function questPickupFxScale(questId, key) {
    if (!variable_global_exists("questPickupFxTime")) { return 1 }
    var questKey = string(questId)
    if (!variable_struct_exists(global.questPickupFxTime, questKey)) { return 1 }
    var times = global.questPickupFxTime[$ questKey]
    var itemKey = string(key)
    if (!variable_struct_exists(times, itemKey)) { return 1 }
    var popDuration = 0.3
    var elapsed = (current_time - times[$ itemKey]) / 1000
    if (elapsed < 0 || elapsed >= popDuration) { return 1 }
    return lerp(1.4, 1, elapsed / popDuration)
}

// Маркер над выдающим квест NPC: до начала и когда готов сдать
function questShowsGiverMarker(questId) {
    if (global.uiModal) { return false }
    var st = questState(questId)
    return st == QuestState.Inactive || st == QuestState.Ready
}

// Для HUD: все отслеживаемые Collect-цели активных/готовых квестов
function questActiveTrackables() {
    questEnsureRegistry()
    var result = []
    for (var i = 0; i < array_length(global.questOrderList); i++) {
        var questId = global.questOrderList[i]
        var st = questState(questId)
        if (st != QuestState.Active && st != QuestState.Ready) { continue }
        var objs = questDef(questId).objectives
        for (var j = 0; j < array_length(objs); j++) {
            var obj = objs[j]
            if (obj.type != QuestObjectiveType.Collect) { continue }
            array_push(result, {
                questId: questId,
                count: questCounter(questId, obj.key),
                needed: obj.count,
                done: questObjectiveDone(questId, obj),
                sprite: questObjectiveSprite(obj),
                scale: questPickupFxScale(questId, obj.key)
            })
        }
    }
    return result
}

// Подсказка "сдай квест" для первого готового квеста, у которого она задана
function questFirstReadyHint() {
    questEnsureRegistry()
    for (var i = 0; i < array_length(global.questOrderList); i++) {
        var questId = global.questOrderList[i]
        if (questState(questId) == QuestState.Ready) {
            var def = questDef(questId)
            if (variable_struct_exists(def, "readyHint") && def.readyHint != "") { return def.readyHint }
        }
    }
    return ""
}

//// Спрайты и бонусы квеста Сафара

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

function cauldronSprite() {
    var sprite = asset_get_index("sprCauldronSmall")
    return sprite_exists(sprite) ? sprite : noone
}

//// Сколько предметов нужно для квеста Лисички
#macro FOX_PINE_CONES_NEEDED 3
#macro FOX_PETUNIAS_NEEDED 1
#macro FOX_CAULDRONS_NEEDED 1

//// Адаптеры к старому API (внешний код не трогаем)

function questSpearState() { return questState(QuestId.Safar) }
function questSetSpearState(state) { questSetState(QuestId.Safar, state) }
function questAcceptSpear() { questAccept(QuestId.Safar) }
function questCompleteSpear() { questComplete(QuestId.Safar) }
function questGrantSpear() {
    if (questState(QuestId.Safar) == QuestState.Active) {
        questAddProgress(QuestId.Safar, QuestSafarItem.Spear)
    }
    if (variable_global_exists("spearCarrierExists")) { global.spearCarrierExists = false }
    if (variable_global_exists("battleHasSpear")) { global.battleHasSpear = false }
}

function questFoxState() { return questState(QuestId.Fox) }
function questSetFoxState(state) { questSetState(QuestId.Fox, state) }
function questFoxAccept() { questAccept(QuestId.Fox) }
function questFoxComplete() { questComplete(QuestId.Fox) }
function questFoxAddItem(item) { questAddProgress(QuestId.Fox, item) }
function questFoxAllCollected() { return questAllObjectivesDone(QuestId.Fox) }
function questFoxItemCount(item) { return questCounter(QuestId.Fox, item) }
function questFoxItemPickupScale(item) { return questPickupFxScale(QuestId.Fox, item) }
function foxShowsQuestMarker() { return questShowsGiverMarker(QuestId.Fox) }
function questFoxIsPicked(pickId) { return questIsPicked(QuestId.Fox, pickId) }
function questFoxMarkPicked(pickId) { questMarkPicked(QuestId.Fox, pickId) }

function questFoxObjective(item) {
    var objs = questDef(QuestId.Fox).objectives
    for (var i = 0; i < array_length(objs); i++) {
        if (objs[i].key == item) { return objs[i] }
    }
    return undefined
}

function questFoxItemNeeded(item) {
    var obj = questFoxObjective(item)
    return (obj != undefined) ? obj.count : 0
}

function questFoxItemSprite(item) {
    var obj = questFoxObjective(item)
    return (obj != undefined) ? questObjectiveSprite(obj) : noone
}

function questFoxItemDone(item) {
    return questFoxItemCount(item) >= questFoxItemNeeded(item)
}
