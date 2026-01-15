function createInstantHealSingleTargetCard() {
    return new Card(
        "Default heal",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
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

function createInstantMultipleTargetsHealCard() {
    return new Card(
        "Default heal",
        TargetTypes.AllAllies,
        StarriorStates.Cast,
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

function createRemoveStatusShockSingleTargetCard() {
    return new Card(
        "Default heal",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Shock,
                timing: Timing.Instant
            }
        ],
        healCard,
        hpHealSolo,
        commonBorder,
        mpCostToken
    )
}

function createRemoveStatusBurnSingleTargetCard() {
    return new Card(
        "Default heal",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Burn,
                timing: Timing.Instant
            }
        ],
        healCard,
        hpHealSolo,
        commonBorder,
        mpCostToken
    )
}

function createRemoveStatusFreezeSingleTargetCard() {
    return new Card(
        "Default heal",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Freeze,
                timing: Timing.Instant
            }
        ],
        healCard,
        hpHealSolo,
        commonBorder,
        mpCostToken
    )
}

function createRemoveStatusBleedingSingleTargetCard() {
    return new Card(
        "Default heal",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Bleeding,
                timing: Timing.Instant
            }
        ],
        healCard,
        hpHealSolo,
        commonBorder,
        mpCostToken
    )
}

function createRemoveStatusStunSingleTargetCard() {
    return new Card(
        "Default heal",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.RemoveEffect,
                statusName: StatusNames.Stun,
                timing: Timing.Instant
            }
        ],
        healCard,
        hpHealSolo,
        commonBorder,
        mpCostToken
    )
}





