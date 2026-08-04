// Атака звездной энергией одного врага
function createMagicalDamageSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "MagicalDamageSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType)) ],
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        mpCostToken
    )
}

// Атака звездной энергией группы врагов
function createMagicalDamageMultipleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "MagicalDamageMultipleTargetCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [ DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType)) ],
        mgcCard,
        lightningGroup,
        commonBorder,
        mpCostToken
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
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType)),
            ShockEffect(1, 1.0)
        ],
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        mpCostToken
    )
}

// Атака молнией группы врагов - (Имеет шанс шокировать врагов. Враги не могут действовать х ходов)
function createMagicalDamageStunChanseMultipleTargetsCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "MagicalDamageStunChanseMultipleTarget",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType)),
            ShockEffect(1, 1.0)
        ],
        mgcCard,
        lightningGroup,
        commonBorder,
        mpCostToken
    )
}

// Атака огнем одного врага - (Имеет шанс поджечь врага. Враг получает магический урон х ходов)
function createMagicalDamageBurnChanseSingleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleEnemyTarget
    return new Card(
        "MagicalDamageBurnChanceSingleTarget",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType)),
            Burn(2, 1, 1.0)
        ],
        mgcCard,
        fireballSingleTarget,
        commonBorder,
        mpCostToken
    )
}

// Атака огнем группы врагов - (Имеет шанс поджечь врагов. Враги получают магический урон х ходов)
function createMagicalDamageBurnChanseMultipleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "MagicalDamageBurnChanceMultipleTarget",
        rarity,
        targetType,
        StarriorStates.Cast,
        1,
        [
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType)),
            Burn(2, 1, 1.0)
        ],
        mgcCard,
        fireballGroup,
        commonBorder,
        mpCostToken
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
        StarriorStates.Cast,
        1,
        [
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType)),
            FreezeEffect(1, 1.0)
        ],
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        mpCostToken
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
        StarriorStates.Cast,
        1,
        [
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType)),
            FreezeEffect(1, 1.0)
        ],
        mgcCard,
        lightningGroup,
        commonBorder,
        mpCostToken
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
        [ CopyCardEffect() ],
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
        [ AddEnergyEffect(1) ],
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
        [ ShuffleDeckEffect() ],
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
        [ IgnoreWeaknessEffect(2) ],
        buffCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}
