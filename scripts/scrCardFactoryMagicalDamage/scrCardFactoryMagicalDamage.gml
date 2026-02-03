// Атака звездной энергией одного врага
function createMagicalDamageSingleTargetCard() {
    return new Card(
        "MagicalDamageSingleTargetCard",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
        CostType.Health,
        3,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: random_range(1, 3),
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
    return new Card(
        "PhysicalDamageMultipleTargetCard",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: random_range(1, 3),
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
    return new Card(
        "MagicalDamageStunChanseSingleTarget",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
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
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака молнией группы врагов - (Имеет шанс шокировать врагов. Враги не могут действовать х ходов)
function createMagicalDamageStunChanseMultipleTargetsCard() {
    return new Card(
        "MagicalDamageStunChanseSingleTarget",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Cast,
        1,
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
        mgcCard,
        lightningGroup,
        commonBorder,
        hpCostToken
    )
}

// Атака огнем одного врага - (Имеет шанс поджечь врага. Враг получает магический урон х ходов)
function createMagicalDamageBurnChanseSingleTargetCard() {
    return new Card(
        "Default attack",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
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
        mgcCard,
        fireballSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака огнем группы врагов - (Имеет шанс поджечь врагов. Враги получают магический урон х ходов)
function createMagicalDamageBurnChanseMultipleTargetCard() {
    return new Card(
        "Default attack",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
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
        mgcCard,
        fireballGroup,
        commonBorder,
        hpCostToken
    )
}
// Атака льдом одного врага - (Имеет шанс заморозить врага. Замороженный враг получает повышенный физ урон х количество ходов)
function createMagicalDamageFreezingChanceSingleTargetCard() {
    return new Card(
        "MagicalDamageFreezingChanceSingleTarget",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: random_range(1, 3),
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
    return new Card(
        "MagicalDamageFreezingChanceMultipleTarget",
        CardsRarity.Default,
        TargetTypes.AllEnemies,
        StarriorStates.Attack,
        1,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Magical,
                value: random_range(1, 3),
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
    return new Card(
        "CopyNextPlayedCard",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
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
    return new Card(
        "AddEnergyCard",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
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
    return new Card(
        "ShuffleDeckCard",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
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