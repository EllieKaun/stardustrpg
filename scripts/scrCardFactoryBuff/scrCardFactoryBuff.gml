function createCardBuffPhysicalDamageSingleTarget() {
    return new Card(
        "Buff physical damage single target",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
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

function createCardBuffMagicalDamageSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
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

function createCardBuffAnyDamageSingleTarget() {
    return new Card(
        "Buff magical damage single target",
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        [
            {
                type: EffectTypes.Buff,
                buffType: ModifiersToBuff.AnyDamage,
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