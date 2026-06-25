
function cardIdsInit() {
    global.CardId = {
        // Физические
        physicalDamageSingleTarget:           "physicalDamageSingleTarget",
        physicalDamageMultipleTarget:         "physicalDamageMultipleTarget",
        physicalDamageStunChanceSingleTarget: "physicalDamageStunChanceSingleTarget",
        physicalDamageStunChanceMultiTarget:  "physicalDamageStunChanceMultiTarget",
        physicalDamageBleedChanceSingleTarget:"physicalDamageBleedChanceSingleTarget",
        physicalDamageBleedChanceMultiTarget: "physicalDamageBleedChanceMultiTarget",
        physicalDamageBombChanceSingleTarget: "physicalDamageBombChanceSingleTarget",
        physicalDamageBombChanceMultiTarget:  "physicalDamageBombChanceMultiTarget",
        physicalDamageWeakenChanceSingleTarget:"physicalDamageWeakenChanceSingleTarget",
        physicalDamageWeakenChanceMultiTarget:"physicalDamageWeakenChanceMultiTarget",
        physicalDamageVampChanceSingleTarget: "physicalDamageVampChanceSingleTarget",
        physicalDamageVampChanceMultiTarget:  "physicalDamageVampChanceMultiTarget",

        // Магические
        magicalDamageSingleTarget: "magicalDamageSingleTarget",
        magicalDamageMultipleTarget: "magicalDamageMultipleTarget",
        magicalDamageStunChanceSingleTarget: "magicalDamageStunChanceSingleTarget",
        magicalDamageStunChanceMultiTarget: "magicalDamageStunChanceMultiTarget",
        magicalDamageBurnChanceSingleTarget: "magicalDamageBurnChanceSingleTarget",
        magicalDamageBurnChanceMultiTarget: "magicalDamageBurnChanceMultiTarget",
        magicalDamageFreezeChanceSingleTarget:"magicalDamageFreezeChanceSingleTarget",
        magicalDamageFreezeChanceMultiTarget: "magicalDamageFreezeChanceMultiTarget",

        // Бафф
        buffPhysicalDamageSingleTarget: "buffPhysicalDamageSingleTarget",
        buffMagicalDamageSingleTarget: "buffMagicalDamageSingleTarget",
        buffAnyDamageMultiTarget: "buffAnyDamageMultiTarget",
        buffPhysicalProtectionSingleTarget: "buffPhysicalProtectionSingleTarget",
        buffMagicalProtectionSingleTarget: "buffMagicalProtectionSingleTarget",
        buffAnyProtectionMultiTarget: "buffAnyProtectionMultiTarget",
        debuffPhysicalDamageSingleTarget: "debuffPhysicalDamageSingleTarget",
        debuffMagicalDamageSingleTarget: "debuffMagicalDamageSingleTarget",
        debuffPhysicalProtectionSingleTarget: "debuffPhysicalProtectionSingleTarget",
        debuffMagicalProtectionSingleTarget: "debuffMagicalProtectionSingleTarget",
        weaknessMagicalDamageSingleTarget: "weaknessMagicalDamageSingleTarget",
        weaknessPhysicalDamageSingleTarget: "weaknessPhysicalDamageSingleTarget",
        ignoreWeaknessSingleTarget: "ignoreWeaknessSingleTarget",

        // Хил
        instantHealSingleTarget: "instantHealSingleTarget",
        instantHealMultiTarget: "instantHealMultiTarget",
        overtimeHealSingleTarget: "overtimeHealSingleTarget",
        instantManaGainSingleTarget: "instantManaGainSingleTarget",
        instantManaGainMultiTarget: "instantManaGainMultiTarget",
        overtimeManaGainSingleTarget: "overtimeManaGainSingleTarget",

        // Уникальные 
        copyNextPlayedCard: "copyNextPlayedCard",
        addEnergy: "addEnergy",
        shuffleDeck: "shuffleDeck",
        removeShock: "removeShock",
        removeBurn: "removeBurn",
        removeFreeze: "removeFreeze",
        removeBleeding: "removeBleeding",
        removeStun: "removeStun",
        resurrection: "resurrection",
        
        // Куклы
        summonAttackPuppet: "summonAttackPuppet",
        summonMagicPuppet: "summonMagicPuppet",
        summonHealPuppet: "summonHealPuppet",
        summonBuffPuppet: "summonBuffPuppet"
    }
}

function cardRegistryInit() {
    global.cardRegistry = {};
    var C = global.CardId;

    var registerCard = function(_id, _canVary, _build) {
        global.cardRegistry[$ _id] = { id: _id, canVaryRarity: _canVary, build: _build };
    };

    // Физические
    registerCard(C.physicalDamageSingleTarget, true, function(_r) { return createPhysicalDamageSingleTargetCard() })
    registerCard(C.physicalDamageMultipleTarget, true, function(_r) { return createPhysicalDamageMultipleTargetCard() })
    registerCard(C.physicalDamageStunChanceSingleTarget, true, function(_r) { return createPhysicalDamageStunChanseSingleTargetCard() })
    registerCard(C.physicalDamageStunChanceMultiTarget, true, function(_r) { return createPhysicalDamageStunChanseMultipleTargetCard() })
    registerCard(C.physicalDamageBleedChanceSingleTarget, true, function(_r) { return createPhysicalDamageBleedingChanseSingleTargetCard() })
    registerCard(C.physicalDamageBleedChanceMultiTarget, true, function(_r) { return createPhysicalDamageBleedingChanseMultipleTargetCard() })
    registerCard(C.physicalDamageBombChanceSingleTarget, true, function(_r) { return createPhysicalDamageBombChanseSingleTargetCard() })
    registerCard(C.physicalDamageBombChanceMultiTarget, true, function(_r) { return createPhysicalDamageBombChanseMultipleTargetCard() })
    registerCard(C.physicalDamageWeakenChanceSingleTarget, true, function(_r) { return createPhysicalDamageWeakeningChanseSingleTargetCard() })
    registerCard(C.physicalDamageWeakenChanceMultiTarget, true, function(_r) { return createPhysicalDamageWeakeningChanseMultipleTargetCard() })
    registerCard(C.physicalDamageVampChanceSingleTarget, true, function(_r) { return createPhysicalDamageVampirismChanseSingleTargetCard() })
    registerCard(C.physicalDamageVampChanceMultiTarget, true, function(_r) { return createPhysicalDamageVampirismChanceMultipleTargetCard() })

    // Магические
    registerCard(C.magicalDamageSingleTarget, true, function(_r) { return createMagicalDamageSingleTargetCard() })
    registerCard(C.magicalDamageMultipleTarget, true, function(_r) { return createMagicalDamageMultipleTargetCard() })
    registerCard(C.magicalDamageStunChanceSingleTarget, true, function(_r) { return createMagicalDamageStunChanseSingleTargetCard() })
    registerCard(C.magicalDamageStunChanceMultiTarget, true, function(_r) { return createMagicalDamageStunChanseMultipleTargetsCard() })
    registerCard(C.magicalDamageBurnChanceSingleTarget, true, function(_r) { return createMagicalDamageBurnChanseSingleTargetCard() })
    registerCard(C.magicalDamageBurnChanceMultiTarget, true, function(_r) { return createMagicalDamageBurnChanseMultipleTargetCard() })
    registerCard(C.magicalDamageFreezeChanceSingleTarget, true, function(_r) { return createMagicalDamageFreezingChanceSingleTargetCard() })
    registerCard(C.magicalDamageFreezeChanceMultiTarget, true, function(_r) { return createMagicalDamageFreezingChanceMultipleTargetCard() })

    // Бафф
    registerCard(C.buffPhysicalDamageSingleTarget, true, function(_r) { return createCardBuffPhysicalDamageSingleTarget() })
    registerCard(C.buffMagicalDamageSingleTarget, true, function(_r) { return createCardBuffMagicalDamageSingleTarget() })
    registerCard(C.buffAnyDamageMultiTarget, true, function(_r) { return createCardBuffAnyDamageMultipleTarget() })
    registerCard(C.buffPhysicalProtectionSingleTarget, true, function(_r) { return createCardBuffPhysicalProtectionSingleTarget() })
    registerCard(C.buffMagicalProtectionSingleTarget, true, function(_r) { return createCardBuffMagicalProtectionSingleTarget() })
    registerCard(C.buffAnyProtectionMultiTarget, true, function(_r) { return createCardBuffAnyProtectionMultipleTarget() })
    registerCard(C.debuffPhysicalDamageSingleTarget, true, function(_r) { return createCardDebuffPhysicalDamageSingleTarget() })
    registerCard(C.debuffMagicalDamageSingleTarget, true, function(_r) { return createCardDebuffMagicalDamageSingleTarget() })
    registerCard(C.debuffPhysicalProtectionSingleTarget, true, function(_r) { return createCardDebuffPhysicalProtectionSingleTarget() })
    registerCard(C.debuffMagicalProtectionSingleTarget, true, function(_r) { return createCardDebuffMagicalProtectionSingleTarget() })
    registerCard(C.weaknessMagicalDamageSingleTarget, true, function(_r) { return createCardCreateTemporaryWeaknessMagicalDamageSingleTarget() })
    registerCard(C.weaknessPhysicalDamageSingleTarget, true, function(_r) { return createCardCreateTemporaryWeaknessPhysicalDamageSingleTarget() })
    registerCard(C.ignoreWeaknessSingleTarget, true, function(_r) { return createCardIgnoreWeaknessSingleTarget() })

    // Хил
    registerCard(C.instantHealSingleTarget, true, function(_r) { return createInstantHealSingleTargetCard() })
    registerCard(C.instantHealMultiTarget, true, function(_r) { return createInstantMultipleTargetsHealCard() })
    registerCard(C.overtimeHealSingleTarget, true, function(_r) { return createOvertimeHealSingleTargetCard() })
    registerCard(C.instantManaGainSingleTarget, true, function(_r) { return createInstantManaGainSingleTargetCard() })
    registerCard(C.instantManaGainMultiTarget, true, function(_r) { return createInstantMultipleTargetsManaGainCard() })
    registerCard(C.overtimeManaGainSingleTarget, true, function(_r) { return createOvertimeManaGainSingleTargetCard() })

    // Уникальные (без редкости)
    registerCard(C.copyNextPlayedCard, false, function(_r) { return createCopyNextPlayedCardCard() })
    registerCard(C.addEnergy, false, function(_r) { return createAddEnergyCard() })
    registerCard(C.shuffleDeck, false, function(_r) { return createShuffleDeckCard() })
    registerCard(C.removeShock, false, function(_r) { return createRemoveStatusShockSingleTargetCard() })
    registerCard(C.removeBurn, false, function(_r) { return createRemoveStatusBurnSingleTargetCard() })
    registerCard(C.removeFreeze, false, function(_r) { return createRemoveStatusFreezeSingleTargetCard() })
    registerCard(C.removeBleeding, false, function(_r) { return createRemoveStatusBleedingSingleTargetCard() })
    registerCard(C.removeStun, false, function(_r) { return createRemoveStatusStunSingleTargetCard() })
    registerCard(C.resurrection, false, function(_r) { return createResurrectionCard() })
    registerCard(C.summonAttackPuppet, false, function(_r){ return createSummonAttackPuppetCard() })
    registerCard(C.summonMagicPuppet, false, function(_r){ return createSummonMagicPuppetCard() })
    registerCard(C.summonHealPuppet, false, function(_r){ return createSummonHealPuppetCard() })
    registerCard(C.summonBuffPuppet, false, function(_r){ return createSummonBuffPuppetCard() })
}

// Проверка существования карты по ид (чекает регистратор)
function cardExists(cardIdentifier) {
    return variable_struct_exists(global.cardRegistry, cardIdentifier)
}

// Возвращает структуру Card или undefined
// Строит карту по ид и редкости и дополнительно сохраняет cardId 
function cardBuild(cardIdentifier, rarity = CardsRarity.Default) {
    if (!cardExists(cardIdentifier)) {
        show_debug_message("cardBuild: unknown id '" + string(cardIdentifier) + "'")
        return undefined
    }
    var cardDefinition = global.cardRegistry[$ cardIdentifier]
    var canVary = cardDefinition.canVaryRarity ? rarity : CardsRarity.Default
    var card = cardDefinition.build(canVary)
    card.cardId = cardIdentifier      
    return card;                 
}

// Построение структуры типа идКарты + редкостьКарты
function cardToRef(card) {
    return { id: card.cardId, rarity: card.rarity }
}

// Возвращает структуру Card или undefined
// Строит карту по ссылке и дополнительно сохраняет cardId 
function cardFromRef(cardDefinition) {
    return cardBuild(cardDefinition.id, cardDefinition.rarity)
}

// Проверка может ли карта иметь разные редкости или уникальная
function cardCanVaryRarity(cardIdentifier) {
    return cardExists(cardIdentifier) ? global.cardRegistry[$ cardIdentifier].canVaryRarity : false
}