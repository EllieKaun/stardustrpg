// Восстановление hp одному герою
function createInstantHealSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Instant Heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ HealEffect(irandom_range(1, 3)) ],
        healCard,
        hpHealSolo,
        commonBorder,
        mpCostToken
    )
}

//  Восстановление hp группе героев
function createInstantMultipleTargetsHealCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.AllAllies
    return new Card(
        "Instant Heal Group",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ HealEffect(irandom_range(1, 3)) ],
        healCard,
        hpHealGroup,
        commonBorder,
        mpCostToken
    )
}

// Постепенное восстановление hp одному герою
function createOvertimeHealSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Heal Over Time",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ HealOverTimeEffect(irandom_range(1, 3), 1) ],
        healCard,
        hpHealOT,
        commonBorder,
        mpCostToken
    )
}



// Восстановление mp одному герою
function createInstantManaGainSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Mana Gain",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ ManaGainEffect(irandom_range(1, 3)) ],
        healCard,
        mpHealSolo,
        commonBorder,
        mpCostToken
    )
}

// Восстановление mp группе героев
function createInstantMultipleTargetsManaGainCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.AllAllies
    return new Card(
        "Mana Gain Group",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ ManaGainEffect(irandom_range(1, 3)) ],
        healCard,
        mpHealGroup,
        commonBorder,
        mpCostToken
    )
}

// Постепенное восстановление mp одному герою
function createOvertimeManaGainSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Mana Over Time",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ ManaGainOverTimeEffect(irandom_range(1, 3), 1) ],
        healCard,
        mpHealOT,
        commonBorder,
        mpCostToken
    )
}

// Снятие статуса шока одному герою - уникальная
function createRemoveStatusShockSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Remove Shock",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ RemoveStatusEffect(StatusNames.Shock, removeShockEffect) ],
        healCard,
        shockRemove,
        commonBorder,
        mpCostToken
    )
}

// Снятие статуса поджога одному герою - уникальная
function createRemoveStatusBurnSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Remove Burn",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ RemoveStatusEffect(StatusNames.Burn, removeBurnEffect) ],
        healCard,
        burnRemove,
        commonBorder,
        mpCostToken
    )
}

// Снятие статуса заморозки одному герою - уникальная
function createRemoveStatusFreezeSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Remove Freeze",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ RemoveStatusEffect(StatusNames.Freeze, removeFreezeEffect) ],
        healCard,
        freezeRemove,
        commonBorder,
        mpCostToken
    )
}

// Снятие статуса кровотечения одному герою - уникальная
function createRemoveStatusBleedingSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Remove Bleeding",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ RemoveStatusEffect(StatusNames.Bleeding, removeBleedingEffect) ],
        healCard,
        bleedRemove,
        commonBorder,
        mpCostToken
    )
}

// Снятие статуса оглушения одному герою - уникальная
function createRemoveStatusStunSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Remove Stun",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ RemoveStatusEffect(StatusNames.Stun, removeStunEffect) ],
        healCard,
        stunRemove,
        commonBorder,
        mpCostToken
    )
}

// Воскрешение павшего союзника - уникальная
function createResurrectionCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "ResurrectionCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ ResurrectionEffect(hphealEffect) ],
        healCard,
        bleedRemove,
        commonBorder,
        mpCostToken
    )
}
