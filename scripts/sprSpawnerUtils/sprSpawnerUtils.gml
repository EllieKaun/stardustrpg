enum Zone { Inner, Middle, Outer }
enum Section { TopRight, TopLeft, BottomLeft, BottomRight }

// Определение зоны
function zoneAt(px, py) {
    var c = global.zoneConfig
    var cheb = max(abs(px - c.cx), abs(py - c.cy))
    if (cheb <= c.innerHalf) return Zone.Inner
    if (cheb <= c.middleHalf) return Zone.Middle
    return Zone.Outer
}

// Определение секции
function sectionAt(px, py) {
    var c  = global.zoneConfig
    var dx = px - c.cx
    var dy = py - c.cy
    if (dy < 0) return (dx >= 0) ? Section.TopRight : Section.TopLeft
    else return (dx >= 0) ? Section.BottomRight : Section.BottomLeft
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
    var comps = sectionCompositions(section);
    var comp  = comps[irandom(array_length(comps) - 1)]
    var result = []
    for (var i = 0; i < array_length(comp); i++) {
        array_push(result, comp[i]())
    }
    return result
}

// создание пула наград для зоны для секции при победе
function rewardPoolForSection(section) {
    var C = global.CardId
    var rarities = [CardsRarity.Default, CardsRarity.Unusual]
    var ids
    switch (section) {
        case Section.TopLeft: 
            ids = [
                C.physicalDamageSingleTarget,            // атака одного врага
                C.physicalDamageMultipleTarget,          // атака группы  
                C.physicalDamageWeakenChanceSingleTarget,// шанс слабости     
                C.magicalDamageBurnChanceSingleTarget,   // атака огнём     
                C.buffPhysicalDamageSingleTarget         // усиление физ урона
            ]
        break
        case Section.TopRight:  
            ids = [
                C.physicalDamageBleedChanceSingleTarget, // шанс кровотечения
                C.buffPhysicalProtectionSingleTarget,    // усиление физ защиты
                C.debuffPhysicalDamageSingleTarget,      // снижение физ атаки
                C.instantManaGainSingleTarget,           // восстановление mp 
                C.magicalDamageStunChanceSingleTarget    // атака молнией  
            ]
        break
        case Section.BottomRight:
            ids = [
                C.magicalDamageFreezeChanceSingleTarget, // атака льдом    
                C.weaknessMagicalDamageSingleTarget,     // слабость к маг урону 
                C.buffMagicalProtectionSingleTarget,     // усиление маг защиты
                C.debuffMagicalDamageSingleTarget,       // снижение маг атаки
                C.instantHealMultiTarget                 // восстановление 
            ]
        break
        case Section.BottomLeft: 
            ids = [
                C.magicalDamageSingleTarget,             // звёздная энергия  
                C.magicalDamageStunChanceMultiTarget,    // молния группе   
                C.magicalDamageBurnChanceMultiTarget,    // огонь группе 
                C.magicalDamageFreezeChanceMultiTarget,  // лёд группе    
                C.overtimeHealSingleTarget,              // постепенное hp
                C.overtimeManaGainSingleTarget           // постепенное mp 
            ]
        break
        default:
            ids = [C.physicalDamageSingleTarget]
    }
    return { ids: ids, rarities: rarities }
}

// Единый пул наград «лес» (демо): объединение пулов всех секций.
// Редкости — обычная/необычная. Враги остаются по секциям, а награда — общая.
function forestRewardPool() {
    var ids = []
    var sections = [Section.TopLeft, Section.TopRight, Section.BottomRight, Section.BottomLeft]
    for (var i = 0; i < array_length(sections); i++) {
        var pool = rewardPoolForSection(sections[i])
        for (var j = 0; j < array_length(pool.ids); j++) array_push(ids, pool.ids[j])
    }
    return { ids: ids, rarities: [CardsRarity.Default, CardsRarity.Unusual] }
}

// итоговое создание битвы из фабрик
function makeEncounter(enemyCreators, reward) {
    return { enemyCreators: enemyCreators, reward: reward }
}

// Единый пул композиций врагов «лес» 
function forestCompositions() {
    var _all = []
    var sections = [Section.TopLeft, Section.TopRight, Section.BottomRight, Section.BottomLeft]
    for (var i = 0; i < array_length(sections); i++) {
        var comps = sectionCompositions(sections[i])
        for (var j = 0; j < array_length(comps); j++) array_push(_all, comps[j])
    }
    return _all
}

// создание битвы для рандомного врага 
function randomSectionEncounter(section) {
    var comps = forestCompositions()                       // демо: враги из всех секций
    var comp  = comps[irandom(array_length(comps) - 1)];   // [createNut, createLeaf, ...]
    return makeEncounter(comp, forestRewardPool())         // демо: единый лесной пул наград
}

// создание битвы для босса Марионетки
function puppetMasterEncounter() {
    var C = global.CardId;
    return makeEncounter(
        [createPuppetMaster],  
        { ids: [C.summonAttackPuppet, C.buffMagicalDamageSingleTarget, C.magicalDamageStunChanceSingleTarget],
          rarities: [CardsRarity.Rare, CardsRarity.Epic] }
    )
}

// Зацикленный звук ходьбы по траве выделенного персонажа.
function updateWalkSound(active) {
    if (!variable_global_exists("walkSound") || global.walkSound < 0) return
    if (active) {
        if (!audio_is_playing(global.walkSound)) audio_play_sound(global.walkSound, 1, true)
    } else {
        if (audio_is_playing(global.walkSound)) audio_stop_sound(global.walkSound)
    }
}
