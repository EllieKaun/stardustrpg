// Атака одного врага 
function createPhysicalDamageSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "PhysicalDamageSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
            }
        ],
        atcCard,
        bleedSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака группы врагов
function createPhysicalDamageMultipleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "PhysicalDamageMultipleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
            }
        ],
        atcCard,
        bleedSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом оглушения одного врага - (враг не может действовать х ходов)
function createPhysicalDamageStunChanseSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "PhysicalDamageStunChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
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
        stunSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом оглушения группы врагов - (враги не могут действовать х ходов)
function createPhysicalDamageStunChanseMultipleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "PhysicalDamageStunChanseMultipleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
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
        stunGroup,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом кровотечения одного врага - (враг получает физический урон х ходов)
function createPhysicalDamageBleedingChanseSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "PhysicalDamageBleedingChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
            },
            {
                type: EffectTypes.Damage,
                chance: 1.0,
                timing: Timing.EndOfTurn,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                duration: 1,
                statusName: StatusNames.Bleeding
            }
        ],
        atcCard,
        bleedSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом кровотечения группы врагов - (враги получают физический урон х ходов)
function createPhysicalDamageBleedingChanseMultipleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "PhysicalDamageBleedingChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
            },
            {
                type: EffectTypes.Damage,
                chance: 1.0,
                timing: Timing.EndOfTurn,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                duration: 1,
                statusName: StatusNames.Bleeding
            }
        ],
        atcCard,
        bleedGroup,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом взрыва одного врага - (враг получает большой урон сразу)
function createPhysicalDamageBombChanseSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "PhysicalDamageBleedingChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
            },
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                chance: 1.0,
                timing: Timing.Instant,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                statusName: StatusNames.Bomb
            }
        ],
        atcCard,
        bombSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом взрыва группы врагов - (враги получают большой урон сразу)
function createPhysicalDamageBombChanseMultipleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "PhysicalDamageBleedingChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
            },
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                chance: 1.0,
                timing: Timing.Instant,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                statusName: StatusNames.Bomb
            }
        ],
        atcCard,
        bombGroup,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом слабости одного врага
function createPhysicalDamageWeakeningChanseSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "PhysicalDamageWeakeningChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
            },
            {
                type: EffectTypes.Weakening,
                chance: 1.0,
                timing: Timing.Overtime,
                duration: 1,
                statusName: StatusNames.Weakening
            }
        ],
        atcCard,
        bombSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом слабости группы врагов
function createPhysicalDamageWeakeningChanseMultipleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "PhysicalDamageWeakeningChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                sprite: attackEffect
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
        bombGroup,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом вампиризма одного врага - (нанесенный физ урон преобразуется в здоровье)
function createPhysicalDamageVampirismChanseSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "PhysicalDamageVampirismChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                chance: 1.0,
                statusName: StatusNames.Vampirism,
                sprite: attackEffect
            }
        ],
        atcCard,
        vampSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом вампиризма группы врагов - (нанесенный физ урон преобразуется в здоровье)
function createPhysicalDamageVampirismChanceMultipleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "PhysicalDamageVampirismChanseMultipleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant,
                chance: 1.0,
                statusName: StatusNames.Vampirism,
                sprite: attackEffect
            }
        ],
        atcCard,
        vampGroup,
        commonBorder,
        hpCostToken
    )
}
