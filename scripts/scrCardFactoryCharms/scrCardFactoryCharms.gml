function createHandAuraStrengthCard(rarity = CardsRarity.Default) {
    var card = new Card(
        "Hand Aura Strength",
        rarity,
        TargetTypes.Self,   
        StarriorStates.Cast, 
        1,
        [ BuffEffect(ModifiersToBuff.PhysicalDamage, getBuffValueOnRarity(rarity) * 2, 2) ],
        buffCard, strBuff, commonBorder, mpCostToken,
        "while in hand: strength buff; play: strength buff"
    )
    card.handAuras = [ HandAuraStatBonus(ModifiersToBuff.PhysicalDamage, 2) ]
    return card
}