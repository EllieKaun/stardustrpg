
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

    var registerCard = function(_id, _canVary, _category, _build) {
        global.cardRegistry[$ _id] = { id: _id, canVaryRarity: _canVary, category: _category, build: _build };
    };

    // Физические
    registerCard(cardIds.physicalDamageSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageSingleTargetCard() })
    registerCard(cardIds.physicalDamageMultipleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageMultipleTargetCard() })
    registerCard(cardIds.physicalDamageStunChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageStunChanseSingleTargetCard() })
    registerCard(cardIds.physicalDamageStunChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageStunChanseMultipleTargetCard() })
    registerCard(cardIds.physicalDamageBleedChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageBleedingChanseSingleTargetCard() })
    registerCard(cardIds.physicalDamageBleedChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageBleedingChanseMultipleTargetCard() })
    registerCard(cardIds.physicalDamageBombChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageBombChanseSingleTargetCard() })
    registerCard(cardIds.physicalDamageBombChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageBombChanseMultipleTargetCard() })
    registerCard(cardIds.physicalDamageWeakenChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageWeakeningChanseSingleTargetCard() })
    registerCard(cardIds.physicalDamageWeakenChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageWeakeningChanseMultipleTargetCard() })
    registerCard(cardIds.physicalDamageVampChanceSingleTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageVampirismChanseSingleTargetCard() })
    registerCard(cardIds.physicalDamageVampChanceMultiTarget, true, CardCategory.Attack, function(_r) { return createPhysicalDamageVampirismChanceMultipleTargetCard() })
    registerCard(cardIds.summonAttackPuppet, false, CardCategory.Attack, function(_r){ return createSummonAttackPuppetCard() })

    // Магические
    registerCard(cardIds.magicalDamageSingleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageSingleTargetCard() })
    registerCard(cardIds.magicalDamageMultipleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageMultipleTargetCard() })
    registerCard(cardIds.magicalDamageStunChanceSingleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageStunChanseSingleTargetCard() })
    registerCard(cardIds.magicalDamageStunChanceMultiTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageStunChanseMultipleTargetsCard() })
    registerCard(cardIds.magicalDamageBurnChanceSingleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageBurnChanseSingleTargetCard() })
    registerCard(cardIds.magicalDamageBurnChanceMultiTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageBurnChanseMultipleTargetCard() })
    registerCard(cardIds.magicalDamageFreezeChanceSingleTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageFreezingChanceSingleTargetCard() })
    registerCard(cardIds.magicalDamageFreezeChanceMultiTarget, true, CardCategory.Magic, function(_r) { return createMagicalDamageFreezingChanceMultipleTargetCard() })
    registerCard(cardIds.summonMagicPuppet, false, CardCategory.Magic, function(_r){ return createSummonMagicPuppetCard() })
    registerCard(cardIds.bossClone, false, CardCategory.Magic, function(_r){ return createBossCloneCard() })

    // Усиливающие (баффы/дебаффы/слабости у врага)
    registerCard(cardIds.buffPhysicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardBuffPhysicalDamageSingleTarget() })
    registerCard(cardIds.buffMagicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardBuffMagicalDamageSingleTarget() })
    registerCard(cardIds.buffAnyDamageMultiTarget, true, CardCategory.Buff, function(_r) { return createCardBuffAnyDamageMultipleTarget() })
    registerCard(cardIds.buffPhysicalProtectionSingleTarget, true, CardCategory.Buff, function(_r) { return createCardBuffPhysicalProtectionSingleTarget() })
    registerCard(cardIds.buffMagicalProtectionSingleTarget, true, CardCategory.Buff, function(_r) { return createCardBuffMagicalProtectionSingleTarget() })
    registerCard(cardIds.buffAnyProtectionMultiTarget, true, CardCategory.Buff, function(_r) { return createCardBuffAnyProtectionMultipleTarget() })
    registerCard(cardIds.debuffPhysicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardDebuffPhysicalDamageSingleTarget() })
    registerCard(cardIds.debuffMagicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardDebuffMagicalDamageSingleTarget() })
    registerCard(cardIds.debuffPhysicalProtectionSingleTarget, true, CardCategory.Buff, function(_r) { return createCardDebuffPhysicalProtectionSingleTarget() })
    registerCard(cardIds.debuffMagicalProtectionSingleTarget, true, CardCategory.Buff, function(_r) { return createCardDebuffMagicalProtectionSingleTarget() })
    registerCard(cardIds.weaknessMagicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardCreateTemporaryWeaknessMagicalDamageSingleTarget() })
    registerCard(cardIds.weaknessPhysicalDamageSingleTarget, true, CardCategory.Buff, function(_r) { return createCardCreateTemporaryWeaknessPhysicalDamageSingleTarget() })
    registerCard(cardIds.summonBuffPuppet, false, CardCategory.Buff, function(_r){ return createSummonBuffPuppetCard() })

    // Лечебные (хил/мана/снятие статусов/воскрешение)
    registerCard(cardIds.instantHealSingleTarget, true, CardCategory.Heal, function(_r) { return createInstantHealSingleTargetCard() })
    registerCard(cardIds.instantHealMultiTarget, true, CardCategory.Heal, function(_r) { return createInstantMultipleTargetsHealCard() })
    registerCard(cardIds.overtimeHealSingleTarget, true, CardCategory.Heal, function(_r) { return createOvertimeHealSingleTargetCard() })
    registerCard(cardIds.instantManaGainSingleTarget, true, CardCategory.Heal, function(_r) { return createInstantManaGainSingleTargetCard() })
    registerCard(cardIds.instantManaGainMultiTarget, true, CardCategory.Heal, function(_r) { return createInstantMultipleTargetsManaGainCard() })
    registerCard(cardIds.overtimeManaGainSingleTarget, true, CardCategory.Heal, function(_r) { return createOvertimeManaGainSingleTargetCard() })
    registerCard(cardIds.removeShock, false, CardCategory.Heal, function(_r) { return createRemoveStatusShockSingleTargetCard() })
    registerCard(cardIds.removeBurn, false, CardCategory.Heal, function(_r) { return createRemoveStatusBurnSingleTargetCard() })
    registerCard(cardIds.removeFreeze, false, CardCategory.Heal, function(_r) { return createRemoveStatusFreezeSingleTargetCard() })
    registerCard(cardIds.removeBleeding, false, CardCategory.Heal, function(_r) { return createRemoveStatusBleedingSingleTargetCard() })
    registerCard(cardIds.removeStun, false, CardCategory.Heal, function(_r) { return createRemoveStatusStunSingleTargetCard() })
    registerCard(cardIds.resurrection, false, CardCategory.Heal, function(_r) { return createResurrectionCard() })
    registerCard(cardIds.summonHealPuppet, false, CardCategory.Heal, function(_r){ return createSummonHealPuppetCard() })

    // Особые
    registerCard(cardIds.copyNextPlayedCard, false, CardCategory.Special, function(_r) { return createCopyNextPlayedCardCard() })
    registerCard(cardIds.addEnergy, false, CardCategory.Special, function(_r) { return createAddEnergyCard() })
    registerCard(cardIds.shuffleDeck, false, CardCategory.Special, function(_r) { return createShuffleDeckCard() })
    registerCard(cardIds.ignoreWeaknessSingleTarget, true, CardCategory.Special, function(_r) { return createCardIgnoreWeaknessSingleTarget() })
    registerCard(cardIds.stealCard, false, CardCategory.Special, function(_r) { return createStealCard() })
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