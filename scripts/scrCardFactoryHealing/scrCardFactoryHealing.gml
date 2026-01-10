function createInstantHealSingleTargetCard() {
    return new Card(
        "Default heal",
        sprCardAttaclBase,
        sprCommonBorder,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.Heal,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ]
    )
}

function createInstantMultipleTargetsHealCard() {
    return new Card(
        "Default heal",
        sprCardAttaclBase,
        sprCommonBorder,
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.Heal,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ]
    )
}