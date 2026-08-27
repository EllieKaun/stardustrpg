// Усиление физ урона героя
function createCardBuffPhysicalDamageSingleTarget() {
    return new Card(
        "Buff physical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ BuffEffect(ModifiersToBuff.PhysicalDamage, getBuffValueOnRarity(CardsRarity.Default), 4) ],
        buffCard,
        strBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts physical damage (4 turns)"
    )
}

// Усиление маг урона героя
function createCardBuffMagicalDamageSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ BuffEffect(ModifiersToBuff.MagicalDamage, getBuffValueOnRarity(CardsRarity.Default), 1) ],
        buffCard,
        magicBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts magic damage (1 turn)"
    )
}

// Усиление любого урона всем героям
function createCardBuffAnyDamageMultipleTarget() {
    return new Card(
        "Buff any damage multiple target",
        CardsRarity.Default,
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        1,
        [
            BuffEffect(ModifiersToBuff.PhysicalDamage, getBuffValueOnRarity(CardsRarity.Default), 1),
            BuffEffect(ModifiersToBuff.MagicalDamage, getBuffValueOnRarity(CardsRarity.Default), 1)
        ],
        buffCard,
        strAndMagicBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts damage (1 turn)"
    )
}

// Усиление физ защиты героя
function createCardBuffPhysicalProtectionSingleTarget() {
    return new Card(
        "Buff physical protection single target",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ BuffEffect(ModifiersToBuff.PhysicalProtection, getBuffValueOnRarity(CardsRarity.Default), 1) ],
        buffCard,
        defBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts physical defense (1 turn)"
    )
}

// Усиления маг защиты героя
function createCardBuffMagicalProtectionSingleTarget() {
    return new Card(
        "Buff magical protection single target",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ BuffEffect(ModifiersToBuff.MagicalProtection, getBuffValueOnRarity(CardsRarity.Default), 1) ],
        atcCard,
        magicDef,
        commonBorder,
        hpCostToken,
        "slightly boosts magical defense (1 turn)"
    )
}

// Усиление любой защиты всем героям
function createCardBuffAnyProtectionMultipleTarget() {
    return new Card(
        "Buff any protection multiple target",
        CardsRarity.Default,
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        1,
        [
            BuffEffect(ModifiersToBuff.PhysicalProtection, getBuffValueOnRarity(CardsRarity.Default), 1),
            BuffEffect(ModifiersToBuff.MagicalProtection, getBuffValueOnRarity(CardsRarity.Default), 1)
        ],
        buffCard,
        defAndMagicDefBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts defense (1 turn)"
    )
}

// Снижение физ атаки врага
function createCardDebuffPhysicalDamageSingleTarget() {
    return new Card(
        "Debuff physical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ DebuffEffect(ModifiersToBuff.PhysicalDamage, getBuffValueOnRarity(CardsRarity.Default), 1) ],
        buffCard,
        strengthDebuff,
        commonBorder,
        hpCostToken,
        "slightly reduces physical damage (1 turn)"
    )
}

// Снижение маг атаки врага
function createCardDebuffMagicalDamageSingleTarget() {
    return new Card(
        "Debuff magical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ DebuffEffect(ModifiersToBuff.MagicalDamage, getBuffValueOnRarity(CardsRarity.Default), 1) ],
        buffCard,
        magicDamageDebuff,
        commonBorder,
        hpCostToken,
        "slightly reduces magic damage (1 turn)"
    )
}

// Снижение физ защиты врага
function createCardDebuffPhysicalProtectionSingleTarget() {
    return new Card(
        "Debuff physical protection single target",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ DebuffEffect(ModifiersToBuff.PhysicalProtection, getBuffValueOnRarity(CardsRarity.Default), 1) ],
        buffCard,
        defDebuff,
        commonBorder,
        hpCostToken,
        "slightly reduces physical defense (1 turn)"
    )
}

// Снижение маг защиты врага
function createCardDebuffMagicalProtectionSingleTarget() {
    return new Card(
        "Debuff magical protection single target",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ DebuffEffect(ModifiersToBuff.MagicalProtection, getBuffValueOnRarity(CardsRarity.Default), 1) ],
        buffCard,
        magicDefDebuff,
        commonBorder,
        hpCostToken,
        "slightly reduces magical defense (1 turn)"
    )
}

// Создание слабости у врага к маг урону - (Слабые места*)
function createCardCreateTemporaryWeaknessMagicalDamageSingleTarget() {
    return new Card(
        "Create Temporary Weakness Magical Damage Card",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ TemporaryWeaknessEffect(ModifiersToBuff.MagicalDamage, 1) ],
        buffCard,
        magicWeakness,
        commonBorder,
        hpCostToken,
        "vulnerability to magic damage (1 turn)"
    )
}

// Создание слабости у врага к физ урону - (Слабые места*)
function createCardCreateTemporaryWeaknessPhysicalDamageSingleTarget() {
    return new Card(
        "Create Temporary Weakness Physical Damage Card",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ TemporaryWeaknessEffect(ModifiersToBuff.PhysicalDamage, 1) ],
        buffCard,
        strWeakness,
        commonBorder,
        hpCostToken,
        "vulnerability to physical damage (1 turn)"
    )
}
