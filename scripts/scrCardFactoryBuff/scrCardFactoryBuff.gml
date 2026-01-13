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