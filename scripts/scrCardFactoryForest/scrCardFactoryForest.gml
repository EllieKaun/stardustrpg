function createForestSupplyBagCard(rarity = CardsRarity.Default) {
    var count = cardBalance().forestBagIngredients[rarity]
    var card = new Card(
        "Supply Bag",
        rarity,
        TargetTypes.Self,
        StarriorStates.Cast,
        1,
        [ GainIngredientEffect(count) ],
        healCard,
        sprForestBagArt,
        commonBorder,
        mpCostToken,
        "", // Локализовать
        sprForestBagAlbum
    )
    card.cardSet = CardSet.Forest
    card.spendsAllEnergy = true 
    card.costValueCached = 0 
    return card
}

function createForestGatherCard(rarity = CardsRarity.Default) {
    var count = cardBalance().forestGatherIngredients[rarity]
    var card = new Card(
        "Gather Supplies", 
        rarity, 
        TargetTypes.Self, 
        StarriorStates.Cast, 1,
        [ DiscardRandomCardEffect(), GainIngredientEffect(count) ],
        healCard, 
        sprForestGatherArt, 
        commonBorder, 
        mpCostToken, 
        "", 
        sprForestGatherAlbum
    )
    card.cardSet = CardSet.Forest
    return card
}