
function cardRegistryInit() {
    global.cardRegistry = {};

    var registerCard = function(_id, _canVary, _build) {
        global.cardRegistry[$ _id] = {
            id: _id,
            canVaryRarity: _canVary,
            build: _build
        };
    };

    // Физические
    registerCard("physicalDamageSingleTarget", true, function(_r) { return createPhysicalDamageSingleTargetCard() })
    registerCard("physicalDamageMultipleTarget", true, function(_r) { return createPhysicalDamageMultipleTargetCard() })
    registerCard("physicalDamageStunChanceSingleTarget", true, function(_r) { return createPhysicalDamageStunChanseSingleTargetCard() })
    registerCard("physicalDamageStunChanceMultiTarget", true, function(_r) { return createPhysicalDamageStunChanseMultipleTargetCard() })
    registerCard("physicalDamageBleedChanceSingleTarget", true, function(_r) { return createPhysicalDamageBleedingChanseSingleTargetCard() })
    registerCard("physicalDamageBleedChanceMultiTarget", true, function(_r) { return createPhysicalDamageBleedingChanseMultipleTargetCard() })
    registerCard("physicalDamageBombChanceSingleTarget", true, function(_r) { return createPhysicalDamageBombChanseSingleTargetCard() })
    registerCard("physicalDamageBombChanceMultiTarget", true, function(_r) { return createPhysicalDamageBombChanseMultipleTargetCard() })
    registerCard("physicalDamageWeakenChanceSingleTarget", true, function(_r) { return createPhysicalDamageWeakeningChanseSingleTargetCard() })
    registerCard("physicalDamageWeakenChanceMultiTarget", true, function(_r) { return createPhysicalDamageWeakeningChanseMultipleTargetCard() })
    registerCard("physicalDamageVampChanceSingleTarget", true, function(_r) { return createPhysicalDamageVampirismChanseSingleTargetCard() })
    registerCard("physicalDamageVampChanceMultiTarget", true, function(_r) { return createPhysicalDamageVampirismChanceMultipleTargetCard() })

    // Магические
    registerCard("magicalDamageSingleTarget", true, function(_r) { return createMagicalDamageSingleTargetCard() })
    registerCard("magicalDamageMultipleTarget", true, function(_r) { return createMagicalDamageMultipleTargetCard() })
    registerCard("magicalDamageStunChanceSingleTarget", true, function(_r) { return createMagicalDamageStunChanseSingleTargetCard() })
    registerCard("magicalDamageStunChanceMultiTarget", true, function(_r) { return createMagicalDamageStunChanseMultipleTargetsCard() })
    registerCard("magicalDamageBurnChanceSingleTarget", true, function(_r) { return createMagicalDamageBurnChanseSingleTargetCard() })
    registerCard("magicalDamageBurnChanceMultiTarget", true, function(_r) { return createMagicalDamageBurnChanseMultipleTargetCard() })
    registerCard("magicalDamageFreezeChanceSingleTarget", true, function(_r) { return createMagicalDamageFreezingChanceSingleTargetCard() })
    registerCard("magicalDamageFreezeChanceMultiTarget", true, function(_r) { return createMagicalDamageFreezingChanceMultipleTargetCard() })
 
    // Баффы
    registerCard("buffPhysicalDamageSingleTarget", true, function(_r) { return createCardBuffPhysicalDamageSingleTarget() })
    registerCard("buffMagicalDamageSingleTarget", true, function(_r) { return createCardBuffMagicalDamageSingleTarget() })
    registerCard("buffAnyDamageMultiTarget", true, function(_r) { return createCardBuffAnyDamageMultipleTarget() })
    registerCard("buffPhysicalProtectionSingleTarget", true, function(_r) { return createCardBuffPhysicalProtectionSingleTarget() })
    registerCard("buffMagicalProtectionSingleTarget", true, function(_r) { return createCardBuffMagicalProtectionSingleTarget() })
    registerCard("buffAnyProtectionMultiTarget", true, function(_r) { return createCardBuffAnyProtectionMultipleTarget() })
    registerCard("debuffPhysicalDamageSingleTarget", true, function(_r) { return createCardDebuffPhysicalDamageSingleTarget() })
    registerCard("debuffMagicalDamageSingleTarget", true, function(_r) { return createCardDebuffMagicalDamageSingleTarget() })
    registerCard("debuffPhysicalProtectionSingleTarget", true, function(_r) { return createCardDebuffPhysicalProtectionSingleTarget() })
    registerCard("debuffMagicalProtectionSingleTarget", true, function(_r) { return createCardDebuffMagicalProtectionSingleTarget() })
    registerCard("weaknessMagicalDamageSingleTarget", true, function(_r) { return createCardCreateTemporaryWeaknessMagicalDamageSingleTarget() })
    registerCard("weaknessPhysicalDamageSingleTarget", true, function(_r) { return createCardCreateTemporaryWeaknessPhysicalDamageSingleTarget() })
    registerCard("ignoreWeaknessSingleTarget", true, function(_r) { return createCardIgnoreWeaknessSingleTarget() })

    // Здоровье
    registerCard("instantHealSingleTarget", true, function(_r) { return createInstantHealSingleTargetCard() })
    registerCard("instantHealMultiTarget", true, function(_r) { return createInstantMultipleTargetsHealCard() })
    registerCard("overtimeHealSingleTarget", true, function(_r) { return createOvertimeHealSingleTargetCard() })
    registerCard("instantManaGainSingleTarget", true, function(_r) { return createInstantManaGainSingleTargetCard() })
    registerCard("instantManaGainMultiTarget", true, function(_r) { return createInstantMultipleTargetsManaGainCard() })
    registerCard("overtimeManaGainSingleTarget", true, function(_r) { return createOvertimeManaGainSingleTargetCard() })

    // Уникальные (без редкости)
    registerCard("copyNextPlayedCard", false, function(_r) { return createCopyNextPlayedCardCard() })
    registerCard("addEnergy", false, function(_r) { return createAddEnergyCard() })
    registerCard("shuffleDeck", false, function(_r) { return createShuffleDeckCard() })
    registerCard("removeShock", false, function(_r) { return createRemoveStatusShockSingleTargetCard() })
    registerCard("removeBurn", false, function(_r) { return createRemoveStatusBurnSingleTargetCard() })
    registerCard("removeFreeze", false, function(_r) { return createRemoveStatusFreezeSingleTargetCard() })
    registerCard("removeBleeding", false, function(_r) { return createRemoveStatusBleedingSingleTargetCard() })
    registerCard("removeStun", false, function(_r) { return createRemoveStatusStunSingleTargetCard() })
    registerCard("resurrection", false, function(_r) { return createResurrectionCard() })
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