function engineerFromBase(baseId, rarity, name, target, gainsPart = true) {
    var card = cardBuild(baseId, rarity)
    card.name = name
    card.cardSet = CardSet.Engineer
    card.target = target
    card.costValueCached = ceil(card.costValueCached * ENGINEER_COST_MULT)
    if (gainsPart) { array_push(card.effects, GainPartsEffect(1)) }
    return card
}

function createEngineerCogCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.drawCard, rarity, "Cog", TargetTypes.Self)
}

function createEngineerWrenchCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.physicalDamageSingleTarget, rarity, "Wrench", TargetTypes.RandomEnemy)
}

function createEngineerHammerCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.physicalDamageStunChanceSingleTarget, rarity, "Hammer", TargetTypes.RandomEnemy)
}

function createEngineerSawCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.physicalDamageBleedChanceSingleTarget, rarity, "Saw", TargetTypes.RandomEnemy)
}

function createEngineerStarScrewdriverCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.magicalDamageSingleTarget, rarity, "Star Screwdriver", TargetTypes.RandomEnemy)
}

function createEngineerStarKeyCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.magicalDamageStunChanceSingleTarget, rarity, "Star Key", TargetTypes.RandomEnemy)
}

function createEngineerStarPliersCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.magicalDamageBurnChanceSingleTarget, rarity, "Star Pliers", TargetTypes.RandomEnemy)
}

function createEngineerRepairKitCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.instantHealSingleTarget, rarity, "Repair Kit", TargetTypes.RandomAlly)
}

function createEngineerStarBatteryCard(rarity = CardsRarity.Default) {
    return engineerFromBase(global.CardId.instantManaGainSingleTarget, rarity, "Star Battery", TargetTypes.RandomAlly)
}

function createEngineerArmorCard(rarity = CardsRarity.Default) {
    var card = new Card(
        "Armor", 
        rarity, 
        TargetTypes.SingleAllyTarget, 
        StarriorStates.Cast, 
        1,
        [ ArmorEffect(cardBalance().engineerArmorDuration[rarity], cardBalance().engineerArmorCharges[rarity]) ],
        buffCard, 
        strWeakness, 
        commonBorder, 
        mpCostToken,
        "", 
        noone
    )
    card.cardSet = CardSet.Engineer
    card.partsCost = 1
    card.costValueCached = ceil(card.costValueCached * ENGINEER_COST_MULT)
    return card
}


function createEngineerCatapultCard(rarity = CardsRarity.Default) {
    var card = new Card(
        "Catapult", 
        rarity, 
        TargetTypes.Self,
        StarriorStates.Cast, 
        1,
        [ RandomHitsEffect(3, cardBalance().engineerCatapultHit[rarity]) ],
        mgcCard, 
        cardCopy,
        commonBorder, 
        mpCostToken,
        "", 
        noone
    )
    card.cardSet = CardSet.Engineer
    card.partsCost = 3
    card.costValueCached = ceil(card.costValueCached * ENGINEER_COST_MULT)
    return card
}

function createEngineerTorpedoCard(rarity = CardsRarity.Default) {
    var card = new Card(
        "Torpedo", 
        rarity, 
        TargetTypes.Self, 
        StarriorStates.Cast, 
        1,
        [ RandomHitsEffect(5, cardBalance().engineerTorpedoHit[rarity]) ],
        mgcCard, 
        cardCopy, 
        commonBorder, 
        mpCostToken, 
        "", 
        noone
    )
    card.cardSet = CardSet.Engineer
    card.partsCost = 5
    card.costValueCached = ceil(card.costValueCached * ENGINEER_COST_MULT)
    return card
}