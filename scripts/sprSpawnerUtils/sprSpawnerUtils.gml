enum Zone { Inner, Middle, Outer }
enum Section { NE, NW, SW, SE }

function zoneAt(px, py) {
    var c = global.zoneConfig
    var cheb = max(abs(px - c.cx), abs(py - c.cy))
    if (cheb <= c.innerHalf)  return Zone.Inner
    if (cheb <= c.middleHalf) return Zone.Middle
    return Zone.Outer
}

function sectionAt(px, py) {
    var c  = global.zoneConfig
    var dx = px - c.cx
    var dy = py - c.cy
    if (dy < 0) return (dx >= 0) ? Section.NE : Section.NW
    else return (dx >= 0) ? Section.SE : Section.SW
}

function enemyTypesForRegion(zone, section) {
    switch (zone) {
        case Zone.Outer:
            switch (section) {
                case Section.NE: return [oCrakerNutSmall]
                case Section.NW: return [oCrakerNutSmall]
                case Section.SW: return [oCrakerNutSmall, oMushroomSmall]
                case Section.SE: return [oMushroomSmall]
            }
        break;
        case Zone.Middle:
            switch (section) {
                case Section.NE: return [oMushroomSmall]
                case Section.NW: return [oCrakerNutSmall, oMushroomSmall]
                case Section.SW: return [oMushroomSmall]
                case Section.SE: return [oCrakerNutSmall]
            }
        break;
        case Zone.Inner: 
            return [oMushroomSmall]
    }
    return [oCrakerNutSmall]
}

function sectionCompositions(section) {
    switch (section) {
        case 1: 
            return [                                  // верх лево
            [createCrackerNut, createCrackerNut],
            [createCrackerNut, createLeaf],
            [createCrackerNut, createLeaf, createCrackerNut],
            [createCrackerNut, createCrackerNut, createCrackerNut]
            ]
        case 2: 
            return [                                  // верх право
            [createMushroom, createMushroom],
            [createMushroom, createFlower],
            [createMushroom, createLeaf, createFlower],
            [createMushroom, createMushroom, createMushroom]
            ]
        case 3: 
            return [                                  // низ право
            [createFlower, createFlower],
            [createMushroom, createFlower],
            [createMushroom, createLeaf, createFlower],
            [createFlower, createFlower, createFlower]
            ]
        case 4: 
            return [                                  // низ лево
            [createCrackerNut, createLeaf, createFlower],
            [createCrackerNut, createLeaf, createMushroom],
            [createMushroom, createCrackerNut, createFlower],
            [createLeaf, createLeaf, createFlower]
            ]
        default: 
            return [[createCrackerNut]]
    }
}

function createEncounterForSection(section) {
    var comps = sectionCompositions(section);
    var comp  = comps[irandom(array_length(comps) - 1)]
    var result = []
    for (var i = 0; i < array_length(comp); i++) {
        array_push(result, comp[i]())
    }
    return result
}

function rewardPoolForSection(section) {
    var rarities = [CardsRarity.Default, CardsRarity.Unusual]
    var ids;
    switch (section) {
        case 1: 
            ids = [
            "physicalDamageSingleTarget",            // атака одного врага  
            "physicalDamageAllEnemies",              // атака группы
            "physicalDamageWeaknessChanceSingleTarget", // шанс слабости
            "fireDamageSingleTarget",                // атака огнём
            "buffPhysicalDamageSingleTarget"         // усиление физ урона
            ]
            break
        case 2: 
            ids = [
            "physicalDamageBleedChanceSingleTarget", // шанс кровотечения
            "buffPhysicalProtectionSingleTarget",    // усиление физ защиты
            "debuffPhysicalDamageSingleTarget",      // снижение физ атаки
            "instantManaSingleTarget",               // восстановление mp
            "lightningDamageSingleTarget"            // атака молнией
            ]
            break
        case 3: 
            ids = [
            "iceDamageSingleTarget",                 // атака льдом
            "createMagicWeaknessSingleTarget",       // слабость к маг урону
            "buffMagicalProtectionSingleTarget",     // усиление маг защиты
            "debuffMagicalDamageSingleTarget",       // снижение маг атаки
            "healAllAllies"                          // восстановление hp группе
            ]
            break
        case 4: 
            ids = [
            "starDamageSingleTarget",                // звёздная энергия
            "lightningDamageAllEnemies",             // молния группе
            "fireDamageAllEnemies",                  // огонь группе
            "iceDamageAllEnemies",                   // лёд группе
            "overTimeHealSingleTarget",              // постепенное hp
            "overTimeManaSingleTarget"               // постепенное mp
            ]
            break
        default: 
            ids = ["physicalDamageSingleTarget"]
    }
    return { ids: ids, rarities: rarities }
}

function greenForestSection(px, py) {
    var c  = global.zoneConfig;
    var dx = px - c.cx;
    var dy = py - c.cy;               // y down → dy < 0 is "верх"
    if (dy < 0) return (dx < 0) ? 1 : 2;   // верх: лево=1, право=2
    else        return (dx > 0) ? 3 : 4;   // низ:  право=3, лево=4
}
