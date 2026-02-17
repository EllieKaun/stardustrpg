// Восстановление hp одному герою
function createInstantHealSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Heal,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Heal,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Heal,
                value: random_range(1, 3),
                timing: Timing.EndOfTurn,
                duration: 1
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.ManaGain,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.ManaGain,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.ManaGain,
                value: random_range(1, 3),
                timing: Timing.EndOfTurn,
                duration: 1
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Shock,
                timing: Timing.Instant
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Burn,
                timing: Timing.Instant
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Freeze,
                timing: Timing.Instant
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Bleeding,
                timing: Timing.Instant
            }
        ],
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
        "Default heal",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Stun,
                timing: Timing.Instant
            }
        ],
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
        [
            {
                type: EffectTypes.Resurrection,
                timing: Timing.Instant
            }
        ],
        healCard,
        bleedRemove,
        commonBorder,
        mpCostToken
    )
}