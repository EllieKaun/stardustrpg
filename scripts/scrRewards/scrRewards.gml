// Редкости наград
function rewardRarities(spec) {
    if (REWARD_DEFAULT_RARITY_ONLY) { return [CardsRarity.Default] }
    return spec.rarities
}

// Полный список наград (id,rarity)
function rewardCandidateRefs(spec) {
    var refs = []
    var rarities = rewardRarities(spec)
    for (var idIndex = 0; idIndex < array_length(spec.ids); idIndex++) {
        var cardIdentifier = spec.ids[idIndex]
        if (cardCanVaryRarity(cardIdentifier) && array_length(rarities) > 0) {
            for (var rarityIndex = 0; rarityIndex < array_length(rarities); rarityIndex++)
                array_push(refs, { id: cardIdentifier, rarity: rarities[rarityIndex] })
        } else {
            array_push(refs, { id: cardIdentifier, rarity: CardsRarity.Default })
        }
    }
    return refs
}

// Вес карты при выборе награды. чем больше копий есть, тем реже выпадает
// 0 копий -> 1, 1 -> 0.5, 2 -> 0.25 и тд
function rewardWeight(ref) {
    return power(REWARD_DUPLICATE_FALLOFF, getOwnedCount(ref.id, ref.rarity))
}

// Взвешенная случайная награда
function rollOneReward(spec) {
    var candidates = rewardCandidateRefs(spec)
    if (array_length(candidates) == 0) { return { id: spec.ids[0], rarity: CardsRarity.Default } }

    var total = 0
    for (var candidateIndex = 0; candidateIndex < array_length(candidates); candidateIndex++) {
        total += rewardWeight(candidates[candidateIndex])
    }

    var roll = random(total)
    for (var candidateIndex = 0; candidateIndex < array_length(candidates); candidateIndex++) {
        var weight = rewardWeight(candidates[candidateIndex])
        if (roll < weight) { return { id: candidates[candidateIndex].id, rarity: candidates[candidateIndex].rarity } }
        roll -= weight
    }
    var last = candidates[array_length(candidates) - 1]
    return { id: last.id, rarity: last.rarity }
}

// Сколько уникальных (id,rarity) карт может быть создано
function rewardCandidateCount(spec) {
    var count = 0
    for (var idIndex = 0; idIndex < array_length(spec.ids); idIndex++) {
        if (cardCanVaryRarity(spec.ids[idIndex])) { 
            count += max(1, array_length(rewardRarities(spec)))
        }
        else { 
            count += 1
        }
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
        var reward = rollOneReward(spec)
        var rewardKey = collectionKey(reward.id, reward.rarity) // id@rarity
        if (!variable_struct_exists(seen, rewardKey)) {
            seen[$ rewardKey] = true
            array_push(choices, reward)
        }
    }
    return choices
}

// Награды после победы
function grantBattleRewards() {
    addWin()
    analyticsWin() // аналитика: победа в бою

    var goldMult = (variable_global_exists("battleIsNight") && global.battleIsNight) ? NIGHT_GOLD_MULT : 1
    addGold(round(GOLD_PER_ENEMY * array_length(enemies) * goldMult))

    var spec = global.battleEncounter.reward;
    var choices = rollRewardChoices(spec, 3)
    rewardChoices = []

    for (var choiceIndex = 0; choiceIndex < array_length(choices); choiceIndex++) {
        var built = cardFromRef(choices[choiceIndex])
        built.cardRef = choices[choiceIndex] // {id, rarity} 
        array_push(rewardChoices, built)
    }
    rewardCursor = 0
    rewardSelected = false
    changeBattleState(BattleStates.Victory)
}