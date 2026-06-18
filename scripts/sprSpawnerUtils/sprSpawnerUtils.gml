enum Zone { Inner, Middle, Outer }
enum Section { TopRight, TopLeft, BottomLeft, BottomRight }

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
    if (dy < 0) return (dx >= 0) ? Section.TopRight : Section.TopLeft
    else return (dx >= 0) ? Section.BottomRight : Section.BottomLeft
}

function enemyTypesForRegion(zone, section) {
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
    var C = global.CardId;
    var rarities = [CardsRarity.Default, CardsRarity.Unusual];
    var ids;
    switch (section) {
        case 1:
            ids = [
                C.physicalDamageSingleTarget,            // атака одного врага
                C.physicalDamageMultipleTarget,          // атака группы  
                C.physicalDamageWeakenChanceSingleTarget,// шанс слабости     
                C.magicalDamageBurnChanceSingleTarget,   // атака огнём     
                C.buffPhysicalDamageSingleTarget         // усиление физ урона
            ];
        break;
        case 2:
            ids = [
                C.physicalDamageBleedChanceSingleTarget, // шанс кровотечения
                C.buffPhysicalProtectionSingleTarget,    // усиление физ защиты
                C.debuffPhysicalDamageSingleTarget,      // снижение физ атаки
                C.instantManaGainSingleTarget,           // восстановление mp 
                C.magicalDamageStunChanceSingleTarget    // атака молнией  
            ];
        break;
        case 3:
            ids = [
                C.magicalDamageFreezeChanceSingleTarget, // атака льдом    
                C.weaknessMagicalDamageSingleTarget,     // слабость к маг урону 
                C.buffMagicalProtectionSingleTarget,     // усиление маг защиты
                C.debuffMagicalDamageSingleTarget,       // снижение маг атаки
                C.instantHealMultiTarget                 // восстановление 
            ];
        break;
        case 4:
            ids = [
                C.magicalDamageSingleTarget,             // звёздная энергия  
                C.magicalDamageStunChanceMultiTarget,    // молния группе   
                C.magicalDamageBurnChanceMultiTarget,    // огонь группе 
                C.magicalDamageFreezeChanceMultiTarget,  // лёд группе    
                C.overtimeHealSingleTarget,              // постепенное hp
                C.overtimeManaGainSingleTarget           // постепенное mp 
            ];
        break;
        default:
            ids = [C.physicalDamageSingleTarget];
    }
    return { ids: ids, rarities: rarities };
}

function greenForestSection(px, py) {
    var c  = global.zoneConfig;
    var dx = px - c.cx;
    var dy = py - c.cy;               // y down → dy < 0 is "верх"
    if (dy < 0) return (dx < 0) ? 1 : 2;   // верх: лево=1, право=2
    else return (dx > 0) ? 3 : 4;   // низ:  право=3, лево=4
}

function makeEncounter(enemyCreators, reward) {
    return { enemyCreators: enemyCreators, reward: reward };  // creators: array of script refs
}

// random section fight — roll a composition, attach that section's reward pool
function randomSectionEncounter(section) {
    var comps = sectionCompositions(section);
    var comp  = comps[irandom(array_length(comps) - 1)];   // [createNut, createLeaf, ...]
    return makeEncounter(comp, rewardPoolForSection(section));
}

// fixed boss fight — explicit roster + explicit reward
function puppetMasterEncounter() {
    var C = global.CardId;
    return makeEncounter(
        [createPuppetMaster],                              // boss alone; it summons its own puppets
        { ids: [C.summonAttackPuppet, C.buffMagicalDamageSingleTarget, C.magicalDamageStunChanceSingleTarget],
          rarities: [CardsRarity.Rare, CardsRarity.Epic] }
    );
}