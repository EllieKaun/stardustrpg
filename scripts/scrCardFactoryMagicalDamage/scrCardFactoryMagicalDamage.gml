function createMagicalDamageStunChanseSingleTargetCard() {
    return new Card(
        "MagicalDamageStunChanseSingleTarget",
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
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

function createMagicalDamageStunChanseMultipleTargetsCard() {
    return new Card(
        "MagicalDamageStunChanseSingleTarget",
        TargetTypes.AllEnemies,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
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

function createMagicalDamageBurnChanseSingleTargetCard() {
    return new Card(
        "Default attack",
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: random_range(1, 3),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                chance: 1.0,
                timing: Timing.EndOfTurn,
                value: 2,
                duration: 1,
                statusName: StatusNames.Burn
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

function createMagicalDamageBurnChanseMultipleTargetCard() {
    return new Card(
        "Default attack",
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: random_range(1, 3),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                chance: 1.0,
                timing: Timing.EndOfTurn,
                value: 2,
                duration: 1,
                statusName: StatusNames.Burn
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}