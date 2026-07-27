
function cardIdsInit() {
    global.CardId = {
        // Физические
        physicalDamageSingleTarget: "physicalDamageSingleTarget",
        physicalDamageMultipleTarget: "physicalDamageMultipleTarget",
        physicalDamageStunChanceSingleTarget: "physicalDamageStunChanceSingleTarget",
        physicalDamageStunChanceMultiTarget: "physicalDamageStunChanceMultiTarget",
        physicalDamageBleedChanceSingleTarget:"physicalDamageBleedChanceSingleTarget",
        physicalDamageBleedChanceMultiTarget: "physicalDamageBleedChanceMultiTarget",
        physicalDamageBombChanceSingleTarget: "physicalDamageBombChanceSingleTarget",
        physicalDamageBombChanceMultiTarget: "physicalDamageBombChanceMultiTarget",
        physicalDamageWeakenChanceSingleTarget:"physicalDamageWeakenChanceSingleTarget",
        physicalDamageWeakenChanceMultiTarget:"physicalDamageWeakenChanceMultiTarget",
        physicalDamageVampChanceSingleTarget: "physicalDamageVampChanceSingleTarget",
        physicalDamageVampChanceMultiTarget: "physicalDamageVampChanceMultiTarget",

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
        summonBuffPuppet: "summonBuffPuppet",
        bossClone: "bossClone"
    }
}

function cardRegistryInit() {
    global.cardRegistry = {};
    var C = global.CardId;

    var registerCard = function(_id, _canVary, _category, _build) {
        global.cardRegistry[$ _id] = { id: _id, canVaryRarity: _canVary, category: _category, build: _build };
    };

    // Физические → Атакующие
    registerCard(C.physicalDamageSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageSingleTargetCard() })
    registerCard(C.physicalDamageMultipleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageMultipleTargetCard() })
    registerCard(C.physicalDamageStunChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageStunChanseSingleTargetCard() })
    registerCard(C.physicalDamageStunChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageStunChanseMultipleTargetCard() })
    registerCard(C.physicalDamageBleedChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageBleedingChanseSingleTargetCard() })
    registerCard(C.physicalDamageBleedChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageBleedingChanseMultipleTargetCard() })
    registerCard(C.physicalDamageBombChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageBombChanseSingleTargetCard() })
    registerCard(C.physicalDamageBombChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageBombChanseMultipleTargetCard() })
    registerCard(C.physicalDamageWeakenChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageWeakeningChanseSingleTargetCard() })
    registerCard(C.physicalDamageWeakenChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageWeakeningChanseMultipleTargetCard() })
    registerCard(C.physicalDamageVampChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageVampirismChanseSingleTargetCard() })
    registerCard(C.physicalDamageVampChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageVampirismChanceMultipleTargetCard() })
    registerCard(C.summonAttackPuppet, false, CardCategory.Attack, function(_r){ return createSummonAttackPuppetCard() })

    // Магические
    registerCard(C.magicalDamageSingleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageSingleTargetCard() })
    registerCard(C.magicalDamageMultipleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageMultipleTargetCard() })
    registerCard(C.magicalDamageStunChanceSingleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageStunChanseSingleTargetCard() })
    registerCard(C.magicalDamageStunChanceMultiTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageStunChanseMultipleTargetsCard() })
    registerCard(C.magicalDamageBurnChanceSingleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageBurnChanseSingleTargetCard() })
    registerCard(C.magicalDamageBurnChanceMultiTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageBurnChanseMultipleTargetCard() })
    registerCard(C.magicalDamageFreezeChanceSingleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageFreezingChanceSingleTargetCard() })
    registerCard(C.magicalDamageFreezeChanceMultiTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageFreezingChanceMultipleTargetCard() })
    registerCard(C.summonMagicPuppet, false, CardCategory.Magic, function(_r){ return createSummonMagicPuppetCard() })
    registerCard(C.bossClone, false, CardCategory.Magic, function(_r){ return createBossCloneCard() })

    // Усиливающие (баффы/дебаффы/слабости у врага)
    registerCard(C.buffPhysicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardBuffPhysicalDamageSingleTarget() })
    registerCard(C.buffMagicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardBuffMagicalDamageSingleTarget() })
    registerCard(C.buffAnyDamageMultiTarget, true, CardCategory.Buff, function(_r) { return createCardBuffAnyDamageMultipleTarget() })
    registerCard(C.buffPhysicalProtectionSingleTarget, true, CardCategory.Buff, function(_r) { return createCardBuffPhysicalProtectionSingleTarget() })
    registerCard(C.buffMagicalProtectionSingleTarget, true, CardCategory.Buff, function(_r) { return createCardBuffMagicalProtectionSingleTarget() })
    registerCard(C.buffAnyProtectionMultiTarget, true, CardCategory.Buff, function(_r) { return createCardBuffAnyProtectionMultipleTarget() })
    registerCard(C.debuffPhysicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardDebuffPhysicalDamageSingleTarget() })
    registerCard(C.debuffMagicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardDebuffMagicalDamageSingleTarget() })
    registerCard(C.debuffPhysicalProtectionSingleTarget, true, CardCategory.Buff, function(_r) { return createCardDebuffPhysicalProtectionSingleTarget() })
    registerCard(C.debuffMagicalProtectionSingleTarget, true, CardCategory.Buff, function(_r) { return createCardDebuffMagicalProtectionSingleTarget() })
    registerCard(C.weaknessMagicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardCreateTemporaryWeaknessMagicalDamageSingleTarget() })
    registerCard(C.weaknessPhysicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardCreateTemporaryWeaknessPhysicalDamageSingleTarget() })
    registerCard(C.summonBuffPuppet, false, CardCategory.Buff, function(_r){ return createSummonBuffPuppetCard() })

    // Лечебные (хил/мана/снятие статусов/воскрешение)
    registerCard(C.instantHealSingleTarget, true, CardCategory.Heal, function(_r) { return createInstantHealSingleTargetCard() })
    registerCard(C.instantHealMultiTarget, true, CardCategory.Heal, function(_r) { return createInstantMultipleTargetsHealCard() })
    registerCard(C.overtimeHealSingleTarget, true, CardCategory.Heal, function(_r) { return createOvertimeHealSingleTargetCard() })
    registerCard(C.instantManaGainSingleTarget, true, CardCategory.Heal, function(_r) { return createInstantManaGainSingleTargetCard() })
    registerCard(C.instantManaGainMultiTarget, true, CardCategory.Heal, function(_r) { return createInstantMultipleTargetsManaGainCard() })
    registerCard(C.overtimeManaGainSingleTarget, true, CardCategory.Heal, function(_r) { return createOvertimeManaGainSingleTargetCard() })
    registerCard(C.removeShock, false, CardCategory.Heal, function(_r) { return createRemoveStatusShockSingleTargetCard() })
    registerCard(C.removeBurn, false, CardCategory.Heal, function(_r) { return createRemoveStatusBurnSingleTargetCard() })
    registerCard(C.removeFreeze, false, CardCategory.Heal, function(_r) { return createRemoveStatusFreezeSingleTargetCard() })
    registerCard(C.removeBleeding, false, CardCategory.Heal, function(_r) { return createRemoveStatusBleedingSingleTargetCard() })
    registerCard(C.removeStun, false, CardCategory.Heal, function(_r) { return createRemoveStatusStunSingleTargetCard() })
    registerCard(C.resurrection, false, CardCategory.Heal, function(_r) { return createResurrectionCard() })
    registerCard(C.summonHealPuppet, false, CardCategory.Heal, function(_r){ return createSummonHealPuppetCard() })

    // Особые (утилитарные, без редкости)
    registerCard(C.copyNextPlayedCard, false, CardCategory.Special, function(_r) { return createCopyNextPlayedCardCard() })
    registerCard(C.addEnergy, false, CardCategory.Special, function(_r) { return createAddEnergyCard() })
    registerCard(C.shuffleDeck, false, CardCategory.Special, function(_r) { return createShuffleDeckCard() })
    registerCard(C.ignoreWeaknessSingleTarget, true, CardCategory.Special, function(_r) { return createCardIgnoreWeaknessSingleTarget() })
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