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