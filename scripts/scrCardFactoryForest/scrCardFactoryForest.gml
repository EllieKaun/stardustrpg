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

// Зелье провокации
function createForestProvokeCard(rarity = CardsRarity.Default) {
    var dur = cardBalance().provokeDuration[rarity]
    var card = new Card(
        "Provoke Potion", rarity, TargetTypes.Self, StarriorStates.Cast, 1,
        [ ProvokeEffect(dur) ],
        healCard, sprForestProvokeArt, commonBorder, mpCostToken, "", sprForestProvokeAlbum
    )
    card.cardSet = CardSet.Forest
    return card
}

//// Пустая колба

// Строковое имя формы (для ключей локализации)
function flaskFormName(form) {
    switch (form) {
        case FlaskForm.Flower: return "flower"
        case FlaskForm.Mushroom: return "mushroom"
        case FlaskForm.Leaf: return "leaf"
        case FlaskForm.FlowerMushroom: return "flowerMushroom"
        case FlaskForm.FlowerLeaf: return "flowerLeaf"
        case FlaskForm.MushroomLeaf: return "mushroomLeaf"
    }
    return "empty"
}

// Определить форму по запасу ингредиентов
function flaskFormFor(ingredients) {
    var flowers = 0, mushrooms = 0, leaves = 0
    for (var i = 0; i < array_length(ingredients); i++) {
        switch (ingredients[i]) {
            case Ingredient.Flower:
                flowers++
            break
            case Ingredient.Mushroom: 
                mushrooms++
            break
            case Ingredient.Leaf: 
                leaves++;   
            break
        }
    }
    if (flowers == 0 && mushrooms == 0 && leaves == 0) { return FlaskForm.Empty }
    if (flowers > 0 && mushrooms > 0) { return FlaskForm.FlowerMushroom }
    if (flowers > 0 && leaves > 0) { return FlaskForm.FlowerLeaf }
    if (mushrooms > 0 && leaves > 0) { return FlaskForm.MushroomLeaf }
    if (flowers > 0) { return FlaskForm.Flower }
    if (mushrooms > 0) { return FlaskForm.Mushroom }
    return FlaskForm.Leaf
}

// Переформировать цель и эффекты формы. amount — сколько ингредиентов
function flaskBuild(form, amount, rarity) {
    var b = cardBalance()
    switch (form) {
        case FlaskForm.Empty:
            return { target: TargetTypes.SingleEnemyTarget,
                     effects: [ DamageEffect(DamageTypes.Physical, 
                                b.flaskEmptyMul[rarity]) ] }

        case FlaskForm.Flower:
            return { target: TargetTypes.SingleAllyTarget,
                     effects: [ BonusHpEffect(b.flaskShield[rarity] * amount) ] }

        case FlaskForm.Mushroom:
            return { target: TargetTypes.SingleEnemyTarget,
                     effects: [ DamageEffect(DamageTypes.True, 
                                b.flaskPure[rarity] * amount) ] }

        case FlaskForm.Leaf:
            return { target: TargetTypes.SingleEnemyTarget,
                     effects: [ ExtendNegativeEffect(b.flaskExtend[rarity] * amount) ] }

        case FlaskForm.FlowerMushroom:
            var dmg = DamageEffect(DamageTypes.Physical, b.flaskLifestealMul[rarity])
            dmg.lifesteal = b.flaskLifestealShare[rarity]
            return { target: TargetTypes.SingleEnemyTarget, effects: [ dmg ] }

        case FlaskForm.FlowerLeaf:
            return { target: TargetTypes.SingleAllyTarget,
                     effects: [ HealEffect(b.flaskHeal[rarity]),
                                RemoveNegativeEffect() ] }

        case FlaskForm.MushroomLeaf:
            var atk = DamageEffect(DamageTypes.Physical, b.flaskPoisonMul[rarity])
            return { target: TargetTypes.SingleEnemyTarget,
                     effects: [ atk, 
                                Poison(b.flaskPoisonValue[rarity], 
                                b.flaskPoisonDur[rarity], b.flaskPoisonChance[rarity]) ] }
    }
}

// Перестроить колбу под текущие ингредиенты
function flaskRefresh(card, owner) {
    var form = flaskFormFor(owner.ingredients)
    var built = flaskBuild(form, max(1, array_length(owner.ingredients)), card.rarity)
    card.target = built.target
    card.effects = built.effects
    card.flaskForm = form
}

function createForestFlaskCard(rarity = CardsRarity.Default) {
    var card = new Card(
        "Empty Flask", rarity, TargetTypes.SingleEnemyTarget, StarriorStates.Cast, 1,
        [ DamageEffect(DamageTypes.Physical, cardBalance().flaskEmptyMul[rarity]) ],
        healCard, sprForestFlaskArt, commonBorder, mpCostToken, "", sprForestFlaskAlbum
    )
    card.cardSet = CardSet.Forest
    card.isFlask = true
    card.flaskForm = FlaskForm.Empty
    card.costValueCached = 2
    return card
}
function createForestRandomPotionCard(rarity = CardsRarity.Default) {
    var card = new Card(
        "Random Potion", rarity, TargetTypes.Self, StarriorStates.Cast, 1,
        [ AddRandomCardsEffect(FOREST_RANDOM_POTION_CARDS, CardSet.Base, CardCategory.Heal, rarity) ],
        healCard, sprForestRandomPotionArt, commonBorder, mpCostToken,
        "adds 3 random healing cards to your hand",
        noone
    )
    card.cardSet = CardSet.Forest
    return card
}
