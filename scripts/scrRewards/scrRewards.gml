// Делаем случайную награду: случайный id и случайная редкость (Default если уникальная карта)
function rollOneReward(spec) {
    var identifier = spec.ids[irandom(array_length(spec.ids) - 1)]
    var rarity = CardsRarity.Default
    if (cardCanVaryRarity(identifier) && array_length(spec.rarities) > 0) {
        rarity = spec.rarities[irandom(array_length(spec.rarities) - 1)]
    }
    return { id: identifier, rarity: rarity }
}

// Сколько уникальных (id,rarity) карт может быть создано
function rewardCandidateCount(spec) {
    var count = 0
    for (var i = 0; i < array_length(spec.ids); i++) {
        if (cardCanVaryRarity(spec.ids[i])) 
            count += array_length(spec.rarities)
        else 
            count += 1
    }
    return count
}

// Три уникальные случайные карты
function rollRewardChoices(spec, count = 3) {
    var choices = []
    var seen = {}

    var target = min(count, rewardCandidateCount(spec))
    var safety = 0

    while (array_length(choices) < target && safety < 1000) {
        safety++
        var c = rollOneReward(spec)
        var key = collectionKey(c.id, c.rarity) // id@rarity
        if (!variable_struct_exists(seen, key)) {
            seen[$ key] = true
            array_push(choices, c)
        }
    }
    return choices;
}

// Награды после победы
function grantBattleRewards() {
    var spec = rewardPoolForSection(global.battleSection);
    var choices = rollRewardChoices(spec, 3)
    rewardChoices = []

    for (var i = 0; i < array_length(choices); i++) {
        var built = cardFromRef(choices[i])
        built.cardRef = choices[i] // {id, rarity} 
        array_push(rewardChoices, built)
    }
    rewardCursor = 0
    rewardSelected = false
    battleState = BattleStates.Victory  
}