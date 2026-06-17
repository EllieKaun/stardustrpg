function createSummonPuppetCard(category, name) {
    return new Card(
        name, CardsRarity.Default,
        TargetTypes.Self, 
        StarriorStates.Cast,
        1,
        [ { type: EffectTypes.CreatePuppet, timing: Timing.OnActions, puppetCategory: category } ],
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        hpCostToken
    )
}
function createSummonAttackPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Attack, "Attack Puppet") 
}
function createSummonMagicPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Magic, "Magic Puppet") 
}
function createSummonHealPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Heal, "Heal Puppet") 
}
function createSummonBuffPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Buff, "Buff Puppet") 
}