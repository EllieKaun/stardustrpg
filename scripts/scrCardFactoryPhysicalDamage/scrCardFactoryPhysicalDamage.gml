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
        [ DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType)) ],
        atcCard,
        atcSingleTarget,
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
        [ DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType)) ],
        atcCard,
        atcGroup,
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
            DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType)),
            StunEffect(1, 1.0)
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
            DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType)),
            StunEffect(1, 1.0)
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
            DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType), slice),
            Bleeding(2, 1, 1.0)
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
        "PhysicalDamageBleedingChanseMultipleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType), slice),
            Bleeding(2, 1, 1.0)
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
        "PhysicalDamageBombChanseSingleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType), bombEffect),
            BombEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType), 1.0)
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
        "PhysicalDamageBombChanseMultipleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType), bombEffect),
            BombEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType), 1.0)
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
            DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType)),
            WeakeningEffect(1, 1.0, Timing.Overtime)
        ],
        atcCard,
        exhSingleTarget,
        commonBorder,
        hpCostToken
    )
}

// Атака с шансом слабости группы врагов
function createPhysicalDamageWeakeningChanseMultipleTargetCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.AllEnemies
    return new Card(
        "PhysicalDamageWeakeningChanseMultipleTargetCard",
        rarity,
        targetType,
        StarriorStates.Attack,
        1,
        [
            DamageEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType)),
            WeakeningEffect(1, 1.0, Timing.EndOfTurn)
        ],
        atcCard,
        exhGroup,
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
        [ VampirismEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType), 1.0) ],
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
        [ VampirismEffect(DamageTypes.Physical, getDamageMultiplierOnRarityAndTarget(rarity, targetType), 1.0) ],
        atcCard,
        vampGroup,
        commonBorder,
        hpCostToken
    )
}
