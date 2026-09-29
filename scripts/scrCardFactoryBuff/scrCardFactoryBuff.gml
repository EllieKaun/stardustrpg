// Усиление физ урона героя
function createCardBuffPhysicalDamageSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Buff physical damage single target",
        rarity,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ BuffEffect(ModifiersToBuff.PhysicalDamage, getBuffValueOnRarity(rarity), 4) ],
        buffCard,
        strBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts physical damage (4 turns)",
        sprHighResBuffPhysicalDamage
    )
}

// Усиление маг урона героя
function createCardBuffMagicalDamageSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Buff magical damage single target",
        rarity,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ BuffEffect(ModifiersToBuff.MagicalDamage, getBuffValueOnRarity(rarity), 1) ],
        buffCard,
        magicBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts magic damage (1 turn)",
        sprHighResBuffMagicalDamage
    )
}

// Усиление любого урона всем героям
function createCardBuffAnyDamageMultipleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Buff any damage multiple target",
        rarity,
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        1,
        [
            BuffEffect(ModifiersToBuff.PhysicalDamage, getBuffValueOnRarity(rarity), 1),
            BuffEffect(ModifiersToBuff.MagicalDamage, getBuffValueOnRarity(rarity), 1)
        ],
        buffCard,
        strAndMagicBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts damage (1 turn)",
        sprHighResBuffAnyDamage
    )
}

// Усиление физ защиты героя
function createCardBuffPhysicalProtectionSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Buff physical protection single target",
        rarity,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ BuffEffect(ModifiersToBuff.PhysicalProtection, getBuffValueOnRarity(rarity), 1) ],
        buffCard,
        defBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts physical defense (1 turn)",
        sprHighResBuffPhysicalProtection
    )
}

// Усиления маг защиты героя
function createCardBuffMagicalProtectionSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Buff magical protection single target",
        rarity,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ BuffEffect(ModifiersToBuff.MagicalProtection, getBuffValueOnRarity(rarity), 1) ],
        atcCard,
        magicDef,
        commonBorder,
        hpCostToken,
        "slightly boosts magical defense (1 turn)",
        sprHighResBuffMagicalProtection
    )
}

// Усиление любой защиты всем героям
function createCardBuffAnyProtectionMultipleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Buff any protection multiple target",
        rarity,
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        1,
        [
            BuffEffect(ModifiersToBuff.PhysicalProtection, getBuffValueOnRarity(rarity), 1),
            BuffEffect(ModifiersToBuff.MagicalProtection, getBuffValueOnRarity(rarity), 1)
        ],
        buffCard,
        defAndMagicDefBuff,
        commonBorder,
        hpCostToken,
        "slightly boosts defense (1 turn)",
        sprHighResBuffAnyProtection
    )
}

// Снижение физ атаки врага
function createCardDebuffPhysicalDamageSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Debuff physical damage single target",
        rarity,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ DebuffEffect(ModifiersToBuff.PhysicalDamage, getBuffValueOnRarity(rarity), 1) ],
        buffCard,
        strengthDebuff,
        commonBorder,
        hpCostToken,
        "slightly reduces physical damage (1 turn)",
        sprHighResDebuffPhysicalDamage
    )
}

// Снижение маг атаки врага
function createCardDebuffMagicalDamageSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Debuff magical damage single target",
        rarity,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ DebuffEffect(ModifiersToBuff.MagicalDamage, getBuffValueOnRarity(rarity), 1) ],
        buffCard,
        magicDamageDebuff,
        commonBorder,
        hpCostToken,
        "slightly reduces magic damage (1 turn)",
        sprHighResDebuffMagicalDamage
    )
}

// Снижение физ защиты врага
function createCardDebuffPhysicalProtectionSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Debuff physical protection single target",
        rarity,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ DebuffEffect(ModifiersToBuff.PhysicalProtection, getBuffValueOnRarity(rarity), 1) ],
        buffCard,
        defDebuff,
        commonBorder,
        hpCostToken,
        "slightly reduces physical defense (1 turn)",
        sprHighResDebuffPhysicalProtection
    )
}

// Снижение маг защиты врага
function createCardDebuffMagicalProtectionSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Debuff magical protection single target",
        rarity,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ DebuffEffect(ModifiersToBuff.MagicalProtection, getBuffValueOnRarity(rarity), 1) ],
        buffCard,
        magicDefDebuff,
        commonBorder,
        hpCostToken,
        "slightly reduces magical defense (1 turn)",
        sprHighResDebuffMagicalProtection
    )
}

// Создание слабости у врага к маг урону - (Слабые места*)
function createCardCreateTemporaryWeaknessMagicalDamageSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Create Temporary Weakness Magical Damage Card",
        rarity,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ TemporaryWeaknessEffect(ModifiersToBuff.MagicalDamage, 1) ],
        buffCard,
        magicWeakness,
        commonBorder,
        hpCostToken,
        "vulnerability to magic damage (1 turn)",
        sprHighResDamageExhaustChanseSIngleTarget
    )
}

// Создание слабости у врага к физ урону - (Слабые места*)
function createCardCreateTemporaryWeaknessPhysicalDamageSingleTarget(rarity = CardsRarity.Default) {
    return new Card(
        "Create Temporary Weakness Physical Damage Card",
        rarity,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [ TemporaryWeaknessEffect(ModifiersToBuff.PhysicalDamage, 1) ],
        buffCard,
        strWeakness,
        commonBorder,
        hpCostToken,
        "vulnerability to physical damage (1 turn)",
        sprHighResDamageExhaustChanseSIngleTarget
    )
}
