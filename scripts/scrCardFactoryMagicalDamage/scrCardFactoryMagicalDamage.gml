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
        [ DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType), StarEnergy, StarMagic) ],
        mgcCard,
        starsSingleTarget,
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
        [ DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType), StarEnergy, StarMagic) ],
        mgcCard,
        starsGroup,
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
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType), lightningStrike, LightningMagic),
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
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType), lightningStrike, LightningMagic),
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
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType), flameStrike, FireMagic),
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
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType), flameStrike, FireMagic),
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
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType), iceStrike, IceMagic),
            FreezeEffect(1, 1.0)
        ],
        mgcCard,
        iceSingleTarget,
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
            DamageEffect(DamageTypes.Magical, getDamageFuncOnRariryAndTarget(rarity, targetType), iceStrike, IceMagic),
            FreezeEffect(1, 1.0)
        ],
        mgcCard,
        iceGroup,
        commonBorder,
        mpCostToken
    )
}


