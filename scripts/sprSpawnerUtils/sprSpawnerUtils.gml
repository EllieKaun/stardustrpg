enum Zone { Inner, Middle, Outer }
enum Section { TopRight, TopLeft, BottomLeft, BottomRight }

// Определение зоны
function zoneAt(posX, posY) {
    var config = global.zoneConfig
    var chebyshevDist = max(abs(posX - config.cx), abs(posY - config.cy))
    if (chebyshevDist <= config.innerHalf) { return Zone.Inner }
    if (chebyshevDist <= config.middleHalf) { return Zone.Middle }
    return Zone.Outer
}

// Определение секции
function sectionAt(posX, posY) {
    var config  = global.zoneConfig
    var offsetX = posX - config.cx
    var offsetY = posY - config.cy
    if (offsetY < 0) { return (offsetX >= 0) ? Section.TopRight : Section.TopLeft }
    else { return (offsetX >= 0) ? Section.BottomRight : Section.BottomLeft }
}

// Типы мини врагов для секции
function enemyTypesForRegion(zone, section) {
    return zoneContent().regionEnemyTypes
}

// Генерация врагов по секции для внешней зоны (для битвы)
function sectionCompositions(section) {
    var s = zoneContent().sections[section]
    return (s != undefined) ? s.compositions : [[createCrackerNut]]
}

// создание композиции врагов для битвы для секции для внешней зоны
function createEncounterForSection(section) {
    var compositions = sectionCompositions(section);
    var composition  = compositions[irandom(array_length(compositions) - 1)]
    var result = []
    for (var creatorIndex = 0; creatorIndex < array_length(composition); creatorIndex++) {
        array_push(result, composition[creatorIndex]())
    }
    return result
}

// создание пула наград для зоны для секции при победе
function rewardPoolForSection(section) {
    var content = zoneContent()
    var s = content.sections[section]
    var ids = (s != undefined) ? s.rewardIds : [global.CardId.physicalDamageSingleTarget]
    return { ids: ids, rarities: content.rewardRarities }
}

// Единый пул наград демо
function rewardIdAllowed(id) {
    if (!cardExists(id)) { return false }
    var card = cardFromRef({ id: id, rarity: CardsRarity.Default })
    if (card == undefined) { return false }
    return card.target != TargetTypes.AllEnemies
}

function forestRewardPool() {
    var content = zoneContent()
    var ids = []
    var order = [Section.TopLeft, Section.TopRight, Section.BottomRight, Section.BottomLeft]
    for (var sectionIndex = 0; sectionIndex < array_length(order); sectionIndex++) {
        var s = content.sections[order[sectionIndex]]
        if (s == undefined) { continue }
        for (var idIndex = 0; idIndex < array_length(s.rewardIds); idIndex++) {
            if (rewardIdAllowed(s.rewardIds[idIndex])) { array_push(ids, s.rewardIds[idIndex]) }
        }
    }
    return { ids: ids, rarities: content.rewardRarities }
}

// итоговое создание битвы из фабрик
// introSprite — спрайт катсцены появления босса
function makeEncounter(enemyCreators, reward, introSprite = undefined) {
    return { enemyCreators: enemyCreators, reward: reward, introSprite: introSprite }
}

// Единый пул композиций врагов в лесу
function forestCompositions() {
    var content = zoneContent()
    var allCompositions = []
    for (var sectionIndex = 0; sectionIndex < array_length(content.sections); sectionIndex++) {
        var s = content.sections[sectionIndex]
        if (s == undefined) { continue }
        for (var compositionIndex = 0; compositionIndex < array_length(s.compositions); compositionIndex++) {
            array_push(allCompositions, s.compositions[compositionIndex])
        }
    }
    return allCompositions
}

function winScaledComposition() {
    var difficulty = battleDifficulty()
    var range = enemyCountForLevel(difficulty, difficultyLevel())
    var enemyCount = range.mn + irandom(range.mx - range.mn)
    var composition = []
    var leafUsed = false
    for (var enemyIndex = 0; enemyIndex < enemyCount; enemyIndex++) {
        if (!leafUsed && irandom(difficulty.limitedChance) == 0) {
            array_push(composition, difficulty.limitedEnemy)
            leafUsed = true
        } else {
            array_push(composition, difficulty.enemyPool[irandom(array_length(difficulty.enemyPool) - 1)])
        }
    }
    return composition
}

// создание битвы для рандомного врага
function randomSectionEncounter(section) {
    return makeEncounter(winScaledComposition(), forestRewardPool())
}

function tutorialEncounter() {
    return makeEncounter([createLeaf], forestRewardPool())
}

// создание битвы для босса Марионетки
function puppetMasterEncounter() {
    var cardIds = global.CardId;
    var encounter = makeEncounter(
        [createPuppetMaster],
        { ids: [cardIds.summonAttackPuppet, cardIds.buffMagicalDamageSingleTarget, cardIds.magicalDamageStunChanceSingleTarget],
          rarities: [CardsRarity.Rare, CardsRarity.Epic] },
        PuppetMasterCutScene
    )
    encounter.raw = true
    return encounter
}

// Зацикленный звук ходьбы по траве выделенного персонажа.
function updateWalkSound(active) {
    if (!variable_global_exists("walkSound") || global.walkSound < 0) { return }
    if (active) {
        if (!audio_is_playing(global.walkSound)) { playSfx(global.walkSound, 1, true) }
    } else {
        if (audio_is_playing(global.walkSound)) { audio_stop_sound(global.walkSound) }
    }
}
