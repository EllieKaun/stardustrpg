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
        [ HealEffect(getInstantHealValueOnRarity(rarity)) ],
        healCard,
        hpHealSolo,
        commonBorder,
        mpCostToken,
        "restores a small amount of health (single)"
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
        [ HealEffect(getInstantHealValueOnRarity(rarity)) ],
        healCard,
        hpHealGroup,
        commonBorder,
        mpCostToken,
        "restores a small amount of health (group)"
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
        [ HealOverTimeEffect(getOvertimeHealValueOnRarity(rarity), getOvertimeHealDurationOnRarity(rarity)) ],
        healCard,
        hpHealOT,
        commonBorder,
        mpCostToken,
        "restores a small amount of health over 2 turns"
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
        [ ManaGainEffect(getInstantManaValueOnRarity(rarity)) ],
        healCard,
        mpHealSolo,
        commonBorder,
        mpCostToken,
        "restores a small amount of mana (single)"
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
        [ ManaGainEffect(getInstantManaValueOnRarity(rarity)) ],
        healCard,
        mpHealGroup,
        commonBorder,
        mpCostToken,
        "restores a small amount of mana (group)"
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
        [ ManaGainOverTimeEffect(getOvertimeManaValueOnRarity(rarity), getOvertimeManaDurationOnRarity(rarity)) ],
        healCard,
        mpHealOT,
        commonBorder,
        mpCostToken,
        "restores a small amount of mana over 2 turns"
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
        mpCostToken,
        "remove the Shock status"
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
        mpCostToken,
        "remove the Burn status"
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
        mpCostToken,
        "remove the Freeze status"
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
        mpCostToken,
        "remove the Bleeding status"
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
        mpCostToken,
        "remove the Stun status"
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
        resurection,
        commonBorder,
        mpCostToken,
        "resurrection"
    )
}
