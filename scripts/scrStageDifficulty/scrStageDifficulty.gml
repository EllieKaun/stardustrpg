enum ForestStage { Start, SlotsBought, FiraQuestDone, BossBeaten }

#macro STAGE_FOREST_BASE 0.35
#macro STAGE_FOREST_PER_SLOT 0.18
#macro STAGE_FOREST_QUEST 0.25
#macro STAGE_FOREST_BOSS 0.30
#macro STAGE_FOREST_GROWTH_PER_WIN 0.02
#macro STAGE_FOREST_MIN_FRAC 0.25
#macro STAGE_FOREST_MAX_LEVEL 50

function zoneProgression(zoneId) {
    switch (zoneId) {
        case ZoneId.Forest:
        default:
            return {
                ceiling: {
                    strength: 10,
                    intelligence: 10,
                    hp: 6,
                    maxHp: 6
                },
                base: STAGE_FOREST_BASE,
                perSlot: STAGE_FOREST_PER_SLOT,
                quest: STAGE_FOREST_QUEST,
                boss: STAGE_FOREST_BOSS,
                growthPerWin: STAGE_FOREST_GROWTH_PER_WIN,
                maxLevel: STAGE_FOREST_MAX_LEVEL
            }
    }
}

function deckSlotsPurchased() {
    return max(0, deckOf(Characters.Lana).unlocked - deckDefaultUnlocked(Characters.Lana))
}

function stageCapFrac(prog) {
    var fract = prog.base
    fract += deckSlotsPurchased() * prog.perSlot
    if (questState(QuestId.Fox) == QuestState.Completed) { fract += prog.quest }
    if (isBossDefeated()) { fract += prog.boss }
    return min(fract, 1)
}

function stageFrac() {
    var prog = zoneProgression(currentZoneId())
    var ramp = zoneWins(currentZoneId()) * prog.growthPerWin // рост от 0 до 1.00
    return clamp(ramp, 0, 1)
}

function stageEnemyMult() {
    var ceiling = zoneProgression(currentZoneId()).ceiling
    var fract = stageFrac()
    var mult = {}
    var stats = variable_struct_get_names(ceiling)
    for (var i = 0; i < array_length(stats); i++) {
        var stat = stats[i]
        mult[$ stat] = lerp(1, ceiling[$ stat], fract)
    }
    return mult
}

function zoneWins(zoneId) {
    if (!variable_struct_exists(global.playerData, "zoneWins")) { global.playerData.zoneWins = [] }
    return (zoneId < array_length(global.playerData.zoneWins)) ? global.playerData.zoneWins[zoneId] : 0
}

function addZoneWin(zoneId) {
    if (!variable_struct_exists(global.playerData, "zoneWins")) { global.playerData.zoneWins = [] }
    while (array_length(global.playerData.zoneWins) <= zoneId) { array_push(global.playerData.zoneWins, 0) }
    global.playerData.zoneWins[zoneId] += 1
}

function currentForestStage() {
    if (isBossDefeated()) { return ForestStage.BossBeaten }
    if (questState(QuestId.Fox) == QuestState.Completed) { return ForestStage.FiraQuestDone }
    if (deckSlotsPurchased() > 0) { return ForestStage.SlotsBought }
    return ForestStage.Start
}