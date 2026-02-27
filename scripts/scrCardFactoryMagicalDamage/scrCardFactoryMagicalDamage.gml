// Атака звездной энергией одного врага
function createMagicalDamageSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "MagicalDamageSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant
            }
        ],
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака звездной энергией группы врагов
function createMagicalDamageMultipleTargetCard() {
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
                damageType: DamageTypes.Magical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant
            }
        ],
        mgcCard,
        lightningGroup,
        commonBorder,
        hpCostToken
    )
}

// Атака молнией одного врага - (Имеет шанс шокировать врага. Враг не можетдействовать х ходов)
function createMagicalDamageStunChanseSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "MagicalDamageStunChanseSingleTarget",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
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
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака молнией группы врагов - (Имеет шанс шокировать врагов. Враги не могут действовать х ходов)
function createMagicalDamageStunChanseMultipleTargetsCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "MagicalDamageStunChanseSingleTarget",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
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
        mgcCard,
        lightningGroup,
        commonBorder,
        hpCostToken
    )
}

// Атака огнем одного врага - (Имеет шанс поджечь врага. Враг получает магический урон х ходов)
function createMagicalDamageBurnChanseSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "Default attack",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
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
        mgcCard,
        fireballSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака огнем группы врагов - (Имеет шанс поджечь врагов. Враги получают магический урон х ходов)
function createMagicalDamageBurnChanseMultipleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "Default attack",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
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
        mgcCard,
        fireballGroup,
        commonBorder,
        hpCostToken
    )
}
// Атака льдом одного врага - (Имеет шанс заморозить врага. Замороженный враг получает повышенный физ урон х количество ходов)
function createMagicalDamageFreezingChanceSingleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "MagicalDamageFreezingChanceSingleTarget",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Debuff,
                buffType: ModifiersToBuff.PhysicalProtection,
                chance: 1.0,
                timing: Timing.Overtime,
                duration: 1,
                statusName: StatusNames.Freeze
            }
        ],
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака льдом группы врагов - (Имеет шанс заморозить врагов. Замороженные враги получают повышенный физ урон х количество ходов)
function createMagicalDamageFreezingChanceMultipleTargetCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "MagicalDamageFreezingChanceMultipleTarget",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: getDamageFuncOnRariryAndTarget(rarity, targetType),
                timing: Timing.Instant
            },
            {
                type: EffectTypes.Debuff,
                buffType: ModifiersToBuff.PhysicalProtection,
                chance: 1.0,
                timing: Timing.Overtime,
                duration: 1,
                statusName: StatusNames.Freeze
            }
        ],
        mgcCard,
        lightningGroup,
        commonBorder,
        hpCostToken
    )
}

// Копирует следующую использованную карту и добавляет в руку героя - уникальная
function createCopyNextPlayedCardCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "CopyNextPlayedCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        0,
        [
            {
                type: EffectTypes.CopyCard,
                timing: Timing.OnActions
            }
        ],
        mgcCard,
        cardCopy,
        commonBorder,
        hpCostToken
    )
}

// Дает дополнительный ход герою - уникальная
function createAddEnergyCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "AddEnergyCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        0,
        [
            {
                type: EffectTypes.AddEnergy,
                value: 1,
                timing: Timing.OnActions
            }
        ],
        mgcCard,
        cardCopy,
        commonBorder,
        hpCostToken
    )
}

// Перемешивает колоду без траты хода  - уникальная 
function createShuffleDeckCard() {
    var rarity = CardsRarity.Default  
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "ShuffleDeckCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        0,
        [
            {
                type: EffectTypes.ShuffleDeck,
                timing: Timing.OnActions
            }
        ],
        mgcCard,
        shuffle,
        commonBorder,
        hpCostToken
    )
}

// Убирает слабость одного героя на х ходов - (Слабые места*)
function createCardIgnoreWeaknessSingleTarget() {
    return new Card(
        "Ignore Weakness",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.IgnoreWeakness,
                timing: Timing.Overtime,
                duration: 2
            }
        ],
        buffCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}