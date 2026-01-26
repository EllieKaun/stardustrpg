// Усиление физ урона героя
function createCardBuffPhysicalDamageSingleTarget() {
    return new Card(
        "Buff physical damage single target",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.PhysicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Усиление маг урона героя
function createCardBuffMagicalDamageSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.MagicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Усиление любого урона всем героям
function createCardBuffAnyDamageMultipleTarget() {
    return new Card(
        "Buff any damage multiple target",
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.PhysicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1
            },
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.MagicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Усиление физ защиты героя
function createCardBuffPhysicalProtectionSingleTarget() {
    return new Card(
        "Buff physical damage single target",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.PhysicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Усиления маг защиты героя
function createCardBuffMagicalProtectionSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.MagicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Усиление любой защиты всем героям
function createCardBuffAnyProtectionMultipleTarget() {
    return new Card(
        "Buff any protection multiple target",
        TargetTypes.AllAllies,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.PhysicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1
            }, 
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.MagicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1
            }
            
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Снижение физ атаки врага
function createCardDebuffPhysicalDamageSingleTarget() {
    return new Card(
        "Debuff physical damage single target",
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Debuff,
                debuffType: ModifiersToBuff.PhysicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Снижение маг атаки врага 
function createCardDebuffMagicalDamageSingleTarget() {
    return new Card(
        "Debuff magical damage single target",
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Debuff,
                debuffType: ModifiersToBuff.MagicalDamage,
                value: 1.5,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Снижение физ защиты врага 
function createCardDebuffPhysicalProtectionSingleTarget() {
    return new Card(
        "Buff physical damage single target",
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Debuff,
                buffType: ModifiersToBuff.PhysicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}

// Снижение маг защиты врага 
function createCardDebuffMagicalProtectionSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        TargetTypes.SingleEnemyTarget,
        StarriorStates.Cast,
        1,
        [
            {
                type: EffectTypes.Debuff,
                buffType: ModifiersToBuff.MagicalProtection,
                value: 0.3,
                timing: Timing.Overtime,
                duration: 1
            }
        ],
        atcCard,
        magicBuff,
        commonBorder,
        hpCostToken
    )
}