// Атака одного врага 
function createPhysicalDamageSingleTargetCard() {
    return new Card(
        "PhysicalDamageSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
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

// Атака группы врагов
function createPhysicalDamageMultipleTargetCard() {
    return new Card(
        "PhysicalDamageMultipleTargetCard",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
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

// Атака с шансом оглушения одного врага - (враг не может действовать х ходов)
function createPhysicalDamageStunChanseSingleTargetCard() {
    return new Card(
        "PhysicalDamageStunChanseSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
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

// Атака с шансом оглушения группы врагов - (враги не могут действовать х ходов)
function createPhysicalDamageStunChanseMultipleTargetCard() {
    return new Card(
        "PhysicalDamageStunChanseMultipleTargetCard",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
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

// Атака с шансом кровотечения одного врага - (враг получает физический урон х ходов)
function createPhysicalDamageBleedingChanseSingleTargetCard() {
    return new Card(
        "PhysicalDamageBleedingChanseSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
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

// Атака с шансом кровотечения группы врагов - (враги получают физический урон х ходов)
function createPhysicalDamageBleedingChanseMultipleTargetCard() {
    return new Card(
        "PhysicalDamageBleedingChanseSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
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

// Атака с шансом взрыва одного врага - (враг получает большой урон сразу)
function createPhysicalDamageBombChanseSingleTargetCard() {
    return new Card(
        "PhysicalDamageBleedingChanseSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                chance: 1.0,
                timing: Timing.Instant,
                value: 2,
                statusName: StatusNames.Bomb
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом взрыва группы врагов - (враги получают большой урон сразу)
function createPhysicalDamageBombChanseMultipleTargetCard() {
    return new Card(
        "PhysicalDamageBleedingChanseSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                chance: 1.0,
                timing: Timing.Instant,
                value: 2,
                statusName: StatusNames.Bomb
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом слабости одного врага
function createPhysicalDamageWeakeningChanseSingleTargetCard() {
    return new Card(
        "PhysicalDamageWeakeningChanseSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Weakening,
                chance: 1.0,
                timing: Timing.Overtime,
                value: 2,
                duration: 1,
                statusName: StatusNames.Weakening
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом слабости группы врагов
function createPhysicalDamageWeakeningChanseMultipleTargetCard() {
    return new Card(
        "PhysicalDamageWeakeningChanseSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Weakening,
                chance: 1.0,
                timing: Timing.EndOfTurn,
                duration: 1,
                statusName: StatusNames.Weakening
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом вампиризма одного врага - (нанесенный физ урон преобразуется в здоровье)
function createPhysicalDamageVampirismChanseSingleTargetCard() {
    return new Card(
        "PhysicalDamageVampirismChanseSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(10, 15),
                timing: Timing.Instant,
                chance: 1.0,
                statusName: StatusNames.Vampirism
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом вампиризма группы врагов - (нанесенный физ урон преобразуется в здоровье)
function createPhysicalDamageVampirismChanceMultipleTargetCard() {
    return new Card(
        "PhysicalDamageVampirismChanseMultipleTargetCard",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(10, 15),
                timing: Timing.Instant,
                chance: 1.0,
                statusName: StatusNames.Vampirism
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}
