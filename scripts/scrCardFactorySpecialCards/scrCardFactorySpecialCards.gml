// Создать марионетку базовый метод
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

// Марионетка физ атак
function createSummonAttackPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Attack, "Attack Puppet") 
}

// Марионетка маг атак
function createSummonMagicPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Magic, "Magic Puppet") 
}

// Марионетка хила
function createSummonHealPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Heal, "Heal Puppet") 
}

// Марионетка баффа
function createSummonBuffPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Buff, "Buff Puppet") 
}