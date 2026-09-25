// Полный список наград (id,rarity)
function rewardCandidateRefs(spec) {
    var out = []
    for (var i = 0; i < array_length(spec.ids); i++) {
        var _id = spec.ids[i]
        if (cardCanVaryRarity(_id) && array_length(spec.rarities) > 0) {
            for (var r = 0; r < array_length(spec.rarities); r++)
                array_push(out, { id: _id, rarity: spec.rarities[r] })
        } else {
            array_push(out, { id: _id, rarity: CardsRarity.Default })
        }
    }
    return out
}

// Вес карты при выборе награды. чем больше копий есть, тем реже выпадает
// 0 копий -> 1, 1 -> 0.5, 2 -> 0.25 и тд
function rewardWeight(ref) {
    return power(REWARD_DUPLICATE_FALLOFF, getOwnedCount(ref.id, ref.rarity))
}

// Взвешенная случайная награда
function rollOneReward(spec) {
    var cands = rewardCandidateRefs(spec)
    if (array_length(cands) == 0) { return { id: spec.ids[0], rarity: CardsRarity.Default } }

    var total = 0
    for (var i = 0; i < array_length(cands); i++) {
        total += rewardWeight(cands[i])
    }

    var roll = random(total)
    for (var i = 0; i < array_length(cands); i++) {
        var w = rewardWeight(cands[i])
        if (roll < w) { return { id: cands[i].id, rarity: cands[i].rarity } }
        roll -= w
    }
    var last = cands[array_length(cands) - 1]
    return { id: last.id, rarity: last.rarity }
}

// Сколько уникальных (id,rarity) карт может быть создано
function rewardCandidateCount(spec) {
    var count = 0
    for (var i = 0; i < array_length(spec.ids); i++) {
        if (cardCanVaryRarity(spec.ids[i])) { 
            count += array_length(spec.rarities)
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
        var c = rollOneReward(spec)
        var key = collectionKey(c.id, c.rarity) // id@rarity
        if (!variable_struct_exists(seen, key)) {
            seen[$ key] = true
            array_push(choices, c)
        }
    }
    return choices
}

// Награды после победы
function grantBattleRewards() {
    addWin()
    analyticsWin() // аналитика: победа в бою

    // Золото за победу 6 за каждого побеждённого врага
    addGold(GOLD_PER_ENEMY * array_length(enemies))

    var spec = global.battleEncounter.reward;
    var choices = rollRewardChoices(spec, 3)
    rewardChoices = []

    for (var i = 0; i < array_length(choices); i++) {
        var built = cardFromRef(choices[i])
        built.cardRef = choices[i] // {id, rarity} 
        array_push(rewardChoices, built)
    }
    rewardCursor = 0
    rewardSelected = false
    changeBattleState(BattleStates.Victory)
}