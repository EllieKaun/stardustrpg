function createPhysicalDamageSingleTargetCard() {
    return new Card(
        "Default attack",
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

function createPhysicalDamageMultipleTargetCard() {
    return new Card(
        "Default attack",
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

function createPhysicalDamageStunChanseSingleTargetCard() {
    return new Card(
        "Default attack",
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
                duration: 1,
                statusName: StatusNames.Stun
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

function createPhysicalDamageBleedingChanseSingleTargetCard() {
    return new Card(
        "Default attack",
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
                duration: 1,
                statusName: StatusNames.Bleeding
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}