function createPhysicalDamageSingleTargetCard() {
    return new Card(
        "Default attack",
        sprCardAttaclBase,
        sprCommonBorder,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ]
    )
}

function createPhysicalDamageMultipleTargetCard() {
    return new Card(
        "Default attack",
        sprCardAttaclBase,
        sprCommonBorder,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ]
    )
}

function createPhysicalDamageStunChanseSingleTargetCard() {
    return new Card(
        "Default attack",
        sprCardAttaclBase,
        sprCommonBorder,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Stun,
                chance: 1.0,
                timing: Timing.Overtime,
                duration: 1
            }
        ]
    )
}

function createPhysicalDamageBurnChanseSingleTargetCard() {
    return new Card(
        "Default attack",
        sprCardAttaclBase,
        sprCommonBorder,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Damage,
                chance: 1.0,
                timing: Timing.EndOfTurn,
                value: 2,
                duration: 1
            }
        ]
    )
}