// Усиление физ урона героя
function createCardBuffPhysicalDamageSingleTarget() {
    return new Card(
        "Buff physical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.PhysicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 4,
                sprite: buffEffect
            }
        ],
        buffCard,
        strBuff,
        commonBorder,
        hpCostToken
    )
}

// Усиление маг урона героя
function createCardBuffMagicalDamageSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        3,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.MagicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1,
                sprite: buffEffect
            }
        ],
        buffCard,
        magicBuff,
        commonBorder,
        hpCostToken
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
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.PhysicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1,
                sprite: buffEffect
            },
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.MagicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        buffCard,
        strAndMagicBuff,
        commonBorder,
        hpCostToken
    )
}

// Усиление физ защиты героя
function createCardBuffPhysicalProtectionSingleTarget() {
    return new Card(
        "Buff physical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.PhysicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1,
                sprite: buffEffect
            }
        ],
        buffCard,
        defBuff,
        commonBorder,
        hpCostToken
    )
}

// Усиления маг защиты героя
function createCardBuffMagicalProtectionSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.MagicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1,
                sprite: buffEffect
            }
        ],
        atcCard,
        defBuff,
        commonBorder,
        hpCostToken
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
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.PhysicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1,
                sprite: buffEffect
            }, 
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.MagicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1
            }
            
        ],
        buffCard,
        defAndMagicDefBuff,
        commonBorder,
        hpCostToken
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
        [
            {
                type: EffectTypes.Debuff,
                buffType: ModifiersToBuff.PhysicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1,
                sprite: debuffEffect
            }
        ],
        buffCard,
        strBuff,
        commonBorder,
        hpCostToken
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
        [
            {
                type: EffectTypes.Debuff,
                buffType: ModifiersToBuff.MagicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1,
                sprite: buffEffect
            }
        ],
        buffCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Снижение физ защиты врага 
function createCardDebuffPhysicalProtectionSingleTarget() {
    return new Card(
        "Buff physical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Debuff,
                buffType: ModifiersToBuff.PhysicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1,
                sprite: debuffEffect
            }
        ],
        buffCard,
        defBuff,
        commonBorder,
        hpCostToken
    )
}

// Снижение маг защиты врага 
function createCardDebuffMagicalProtectionSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        CardsRarity.Default,
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Debuff,
                buffType: ModifiersToBuff.MagicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1,
                sprite: debuffEffect
            }
        ],
        buffCard,
        defBuff,
        commonBorder,
        hpCostToken
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
        [
            {
                type: EffectTypes.CreateTemporaryWeakness,
                weakness: ModifiersToBuff.MagicalDamage,
                timing: Timing.Overtime,
                duration: 1,
                sprite: debuffEffect
            }
        ],
        buffCard,
        defBuff,
        commonBorder,
        hpCostToken
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
        [
            {
                type: EffectTypes.CreateTemporaryWeakness,
                weakness: ModifiersToBuff.PhysicalDamage,
                timing: Timing.Overtime,
                duration: 1,
                sprite: debuffEffect
            }
        ],
        buffCard,
        defBuff,
        commonBorder,
        hpCostToken
    )
}