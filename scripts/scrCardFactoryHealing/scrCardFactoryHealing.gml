// Восстановление hp одному герою
function createInstantHealSingleTargetCard() {
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        3,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        3,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        3,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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
    return new Card(
        "Default heal",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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
    return new Card(
        "ResurrectionCard",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        CostType.Mana,
        4,
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