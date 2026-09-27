
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
        stealCard: "stealCard",
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
    var cardIds = global.CardId;

    var registerCard = function(id, canVary, category, buildFunc) {
        global.cardRegistry[$ id] = { id: id, canVaryRarity: canVary, category: category, build: buildFunc };
    };

    // Физические
    registerCard(cardIds.physicalDamageSingleTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageSingleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageMultipleTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageMultipleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageStunChanceSingleTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageStunChanseSingleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageStunChanceMultiTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageStunChanseMultipleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageBleedChanceSingleTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageBleedingChanseSingleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageBleedChanceMultiTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageBleedingChanseMultipleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageBombChanceSingleTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageBombChanseSingleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageBombChanceMultiTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageBombChanseMultipleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageWeakenChanceSingleTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageWeakeningChanseSingleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageWeakenChanceMultiTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageWeakeningChanseMultipleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageVampChanceSingleTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageVampirismChanseSingleTargetCard(rarity) })
    registerCard(cardIds.physicalDamageVampChanceMultiTarget, true, CardCategory.Attack, function(rarity) { return createPhysicalDamageVampirismChanceMultipleTargetCard(rarity) })
    registerCard(cardIds.summonAttackPuppet, false, CardCategory.Attack, function(rarity){ return createSummonAttackPuppetCard() })

    // Магические
    registerCard(cardIds.magicalDamageSingleTarget, true, CardCategory.Magic, function(rarity) { return createMagicalDamageSingleTargetCard(rarity) })
    registerCard(cardIds.magicalDamageMultipleTarget, true, CardCategory.Magic, function(rarity) { return createMagicalDamageMultipleTargetCard(rarity) })
    registerCard(cardIds.magicalDamageStunChanceSingleTarget, true, CardCategory.Magic, function(rarity) { return createMagicalDamageStunChanseSingleTargetCard(rarity) })
    registerCard(cardIds.magicalDamageStunChanceMultiTarget, true, CardCategory.Magic, function(rarity) { return createMagicalDamageStunChanseMultipleTargetsCard(rarity) })
    registerCard(cardIds.magicalDamageBurnChanceSingleTarget, true, CardCategory.Magic, function(rarity) { return createMagicalDamageBurnChanseSingleTargetCard(rarity) })
    registerCard(cardIds.magicalDamageBurnChanceMultiTarget, true, CardCategory.Magic, function(rarity) { return createMagicalDamageBurnChanseMultipleTargetCard(rarity) })
    registerCard(cardIds.magicalDamageFreezeChanceSingleTarget, true, CardCategory.Magic, function(rarity) { return createMagicalDamageFreezingChanceSingleTargetCard(rarity) })
    registerCard(cardIds.magicalDamageFreezeChanceMultiTarget, true, CardCategory.Magic, function(rarity) { return createMagicalDamageFreezingChanceMultipleTargetCard(rarity) })
    registerCard(cardIds.summonMagicPuppet, false, CardCategory.Magic, function(rarity){ return createSummonMagicPuppetCard() })
    registerCard(cardIds.bossClone, false, CardCategory.Magic, function(rarity){ return createBossCloneCard() })

    // Усиливающие (баффы/дебаффы/слабости у врага)
    registerCard(cardIds.buffPhysicalDamageSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardBuffPhysicalDamageSingleTarget(rarity) })
    registerCard(cardIds.buffMagicalDamageSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardBuffMagicalDamageSingleTarget(rarity) })
    registerCard(cardIds.buffAnyDamageMultiTarget, true, CardCategory.Buff, function(rarity) { return createCardBuffAnyDamageMultipleTarget(rarity) })
    registerCard(cardIds.buffPhysicalProtectionSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardBuffPhysicalProtectionSingleTarget(rarity) })
    registerCard(cardIds.buffMagicalProtectionSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardBuffMagicalProtectionSingleTarget(rarity) })
    registerCard(cardIds.buffAnyProtectionMultiTarget, true, CardCategory.Buff, function(rarity) { return createCardBuffAnyProtectionMultipleTarget(rarity) })
    registerCard(cardIds.debuffPhysicalDamageSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardDebuffPhysicalDamageSingleTarget(rarity) })
    registerCard(cardIds.debuffMagicalDamageSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardDebuffMagicalDamageSingleTarget(rarity) })
    registerCard(cardIds.debuffPhysicalProtectionSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardDebuffPhysicalProtectionSingleTarget(rarity) })
    registerCard(cardIds.debuffMagicalProtectionSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardDebuffMagicalProtectionSingleTarget(rarity) })
    registerCard(cardIds.weaknessMagicalDamageSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardCreateTemporaryWeaknessMagicalDamageSingleTarget(rarity) })
    registerCard(cardIds.weaknessPhysicalDamageSingleTarget, true, CardCategory.Buff, function(rarity) { return createCardCreateTemporaryWeaknessPhysicalDamageSingleTarget(rarity) })
    registerCard(cardIds.summonBuffPuppet, false, CardCategory.Buff, function(rarity){ return createSummonBuffPuppetCard() })

    // Лечебные (хил/мана/снятие статусов/воскрешение)
    registerCard(cardIds.instantHealSingleTarget, true, CardCategory.Heal, function(rarity) { return createInstantHealSingleTargetCard(rarity) })
    registerCard(cardIds.instantHealMultiTarget, true, CardCategory.Heal, function(rarity) { return createInstantMultipleTargetsHealCard(rarity) })
    registerCard(cardIds.overtimeHealSingleTarget, true, CardCategory.Heal, function(rarity) { return createOvertimeHealSingleTargetCard(rarity) })
    registerCard(cardIds.instantManaGainSingleTarget, true, CardCategory.Heal, function(rarity) { return createInstantManaGainSingleTargetCard(rarity) })
    registerCard(cardIds.instantManaGainMultiTarget, true, CardCategory.Heal, function(rarity) { return createInstantMultipleTargetsManaGainCard(rarity) })
    registerCard(cardIds.overtimeManaGainSingleTarget, true, CardCategory.Heal, function(rarity) { return createOvertimeManaGainSingleTargetCard(rarity) })
    registerCard(cardIds.removeShock, false, CardCategory.Heal, function(rarity) { return createRemoveStatusShockSingleTargetCard(rarity) })
    registerCard(cardIds.removeBurn, false, CardCategory.Heal, function(rarity) { return createRemoveStatusBurnSingleTargetCard(rarity) })
    registerCard(cardIds.removeFreeze, false, CardCategory.Heal, function(rarity) { return createRemoveStatusFreezeSingleTargetCard(rarity) })
    registerCard(cardIds.removeBleeding, false, CardCategory.Heal, function(rarity) { return createRemoveStatusBleedingSingleTargetCard(rarity) })
    registerCard(cardIds.removeStun, false, CardCategory.Heal, function(rarity) { return createRemoveStatusStunSingleTargetCard(rarity) })
    registerCard(cardIds.resurrection, false, CardCategory.Heal, function(rarity) { return createResurrectionCard(rarity) })
    registerCard(cardIds.summonHealPuppet, false, CardCategory.Heal, function(rarity){ return createSummonHealPuppetCard() })

    // Особые
    registerCard(cardIds.copyNextPlayedCard, false, CardCategory.Special, function(rarity) { return createCopyNextPlayedCardCard(rarity) })
    registerCard(cardIds.addEnergy, false, CardCategory.Special, function(rarity) { return createAddEnergyCard(rarity) })
    registerCard(cardIds.shuffleDeck, false, CardCategory.Special, function(rarity) { return createShuffleDeckCard(rarity) })
    registerCard(cardIds.ignoreWeaknessSingleTarget, true, CardCategory.Special, function(rarity) { return createCardIgnoreWeaknessSingleTarget(rarity) })
    registerCard(cardIds.stealCard, false, CardCategory.Special, function(rarity) { return createStealCard(rarity) })
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