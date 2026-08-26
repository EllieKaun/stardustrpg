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
        hpCostToken,
        "deals minor physical damage (single)"
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
        hpCostToken,
        "deals minor physical damage (group)"
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
        hpCostToken,
        "deals minor physical damage, may stun (single)"
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
        hpCostToken,
        "deals minor physical damage, may stun (group)"
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
        hpCostToken,
        "deals minor physical damage, may cause bleeding (single)"
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
        hpCostToken,
        "deals minor physical damage, may cause bleeding (group)"
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
        hpCostToken,
        "deals minor physical damage with a bomb blast (single)"
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
        hpCostToken,
        "deals minor physical damage with a bomb blast (group)"
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
        hpCostToken,
        "deals minor physical damage, may weaken (single)"
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
        hpCostToken,
        "deals minor physical damage, may weaken (group)"
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
        hpCostToken,
        "deals minor physical damage, drains health (single)"
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
        hpCostToken,
        "deals minor physical damage, drains health (group)"
    )
}
