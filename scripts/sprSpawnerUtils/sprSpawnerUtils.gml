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
    return [oCrakerNutSmall, oMushroomSmall, oFlowerSmall, oLeafSmall]
    switch (zone) {
        case Zone.Outer:
            switch (section) {
                case Section.TopRight: return [oCrakerNutSmall]
                case Section.TopLeft: return [oCrakerNutSmall]
                case Section.BottomLeft: return [oCrakerNutSmall, oMushroomSmall]
                case Section.BottomRight: return [oMushroomSmall]
            }
        break;
        case Zone.Middle:
            switch (section) {
                case Section.TopRight: return [oMushroomSmall]
                case Section.TopLeft: return [oCrakerNutSmall, oMushroomSmall]
                case Section.BottomLeft: return [oMushroomSmall]
                case Section.BottomRight: return [oCrakerNutSmall]
            }
        break;
        case Zone.Inner: 
            return [oMushroomSmall]
    }
    return [oCrakerNutSmall]
}

// Генерация врагов по секции для внешней зоны (для битвы)
function sectionCompositions(section) {
    section = [Section.BottomLeft, Section.BottomRight, Section.TopLeft, Section.TopRight][irandom(3)]
    switch (section) { 
        case Section.TopLeft: 
            return [                                
            [createCrackerNut, createCrackerNut],
            [createCrackerNut, createLeaf],
            [createCrackerNut, createLeaf, createCrackerNut],
            [createCrackerNut, createCrackerNut, createCrackerNut]
            ] 
        case Section.TopRight: 
            return [                                 
            [createMushroom, createMushroom],
            [createMushroom, createFlower],
            [createMushroom, createLeaf, createFlower],
            [createMushroom, createMushroom, createMushroom]
            ]
        case Section.BottomRight: 
            return [                         
            [createFlower, createFlower],
            [createMushroom, createFlower],
            [createMushroom, createLeaf, createFlower],
            [createFlower, createFlower, createFlower]
            ]
        case Section.BottomLeft: 
            return [                            
            [createCrackerNut, createLeaf, createFlower],
            [createCrackerNut, createLeaf, createMushroom],
            [createMushroom, createCrackerNut, createFlower],
            [createLeaf, createLeaf, createFlower]
            ]
        default: 
            return [[createCrackerNut]]
    }
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
    var cardIds = global.CardId
    var rarities = [CardsRarity.Default, CardsRarity.Unusual]
    var ids
    switch (section) {
        case Section.TopLeft: 
            ids = [
                cardIds.physicalDamageSingleTarget, // атака одного врага
                cardIds.physicalDamageMultipleTarget, // атака группы  
                cardIds.physicalDamageWeakenChanceSingleTarget,// шанс слабости     
                cardIds.magicalDamageBurnChanceSingleTarget, // атака огнём     
                cardIds.buffPhysicalDamageSingleTarget // усиление физ урона
            ]
        break
        case Section.TopRight:  
            ids = [
                cardIds.physicalDamageBleedChanceSingleTarget, // шанс кровотечения
                cardIds.buffPhysicalProtectionSingleTarget, // усиление физ защиты
                cardIds.debuffPhysicalDamageSingleTarget, // снижение физ атаки
                cardIds.instantManaGainSingleTarget, // восстановление mp 
                cardIds.magicalDamageStunChanceSingleTarget    // атака молнией  
            ]
        break
        case Section.BottomRight:
            ids = [
                cardIds.magicalDamageFreezeChanceSingleTarget, // атака льдом    
                cardIds.weaknessMagicalDamageSingleTarget,     // слабость к маг урону 
                cardIds.buffMagicalProtectionSingleTarget,     // усиление маг защиты
                cardIds.debuffMagicalDamageSingleTarget,       // снижение маг атаки
                cardIds.instantHealMultiTarget                 // восстановление 
            ]
        break
        case Section.BottomLeft: 
            ids = [
                cardIds.magicalDamageSingleTarget, // звёздная энергия  
                cardIds.magicalDamageStunChanceMultiTarget, // молния группе   
                cardIds.magicalDamageBurnChanceMultiTarget, // огонь группе 
                cardIds.magicalDamageFreezeChanceMultiTarget, // лёд группе    
                cardIds.overtimeHealSingleTarget, // постепенное hp
                cardIds.overtimeManaGainSingleTarget // постепенное mp 
            ]
        break
        default:
            ids = [cardIds.physicalDamageSingleTarget]
    }
    return { ids: ids, rarities: rarities }
}

// Единый пул наград демо
function rewardIdAllowed(id) {
    if (!cardExists(id)) { return false }
    var card = cardFromRef({ id: id, rarity: CardsRarity.Default })
    if (card == undefined) { return false }
    return card.target != TargetTypes.AllEnemies
}

function forestRewardPool() {
    var ids = []
    var sections = [Section.TopLeft, Section.TopRight, Section.BottomRight, Section.BottomLeft]
    for (var sectionIndex = 0; sectionIndex < array_length(sections); sectionIndex++) {
        var pool = rewardPoolForSection(sections[sectionIndex])
        for (var idIndex = 0; idIndex < array_length(pool.ids); idIndex++) {
            if (rewardIdAllowed(pool.ids[idIndex])) { array_push(ids, pool.ids[idIndex]) }
        }
    }
    return { ids: ids, rarities: [CardsRarity.Default, CardsRarity.Unusual] }
}

// итоговое создание битвы из фабрик
// introSprite — спрайт катсцены появления босса
function makeEncounter(enemyCreators, reward, introSprite = undefined) {
    return { enemyCreators: enemyCreators, reward: reward, introSprite: introSprite }
}

// Единый пул композиций врагов в лесу
function forestCompositions() {
    var allCompositions = []
    var sections = [Section.TopLeft, Section.TopRight, Section.BottomRight, Section.BottomLeft]
    for (var sectionIndex = 0; sectionIndex < array_length(sections); sectionIndex++) {
        var compositions = sectionCompositions(sections[sectionIndex])
        for (var compositionIndex = 0; compositionIndex < array_length(compositions); compositionIndex++) array_push(allCompositions, compositions[compositionIndex])
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
