function ingredientAdd(character, ingredient) {
    if (array_length(character.ingredients) >= INGREDIENT_MAX) {
        
    }
    array_push(character.ingredients, ingredient)
    refreshDynamicCards(character)
}

function ingredientAddRandom(character) {
    ingredientAdd(character, choose(
        Ingredient.Flower,
        Ingredient.Leaf,
        Ingredient.Mushroom
    ))
}

function  ingredientPeek(character) {
    var n = array_length(character.ingredients)
    if (n == 0) { return undefined }
        
    return character.ingredients[n - 1]
}

function ingredientTake(character) {
    if (array_length(character.ingredients) == 0) { return undefined }
    var taken = array_pop(character.ingredients)
    refreshDynamicCards(character)
    return taken
}

function ingredientTakeAll(character) {
    var takeAll = character.ingredients
    character.ingredients = []
    refreshDynamicCards(character)
    return takeAll
}

function ingredientFitsCard(ingredient, card) {
    var effects = card.effects
    for (var index = 0; index < array_length(effects); index++) {
        var effect = effects[index]
        if (ingredient == Ingredient.Flower && effect.type == EffectTypes.Heal) {
            return true
        }
        if (ingredient == Ingredient.Mushroom && effect.type == EffectTypes.Damage) {
            return true 
        }
        if (ingredient == Ingredient.Leaf) {
            if (variable_struct_exists(effect, "chance")) { return true }

            if (effect.type == EffectTypes.Debuff
                || effect.type == EffectTypes.Weakening
                || effect.type == EffectTypes.CreateTemporaryWeakness) {
                    return true
            }
        }
    }
    return false
}


// Перестроить все динамические карты персонажа под текущие условия
function refreshDynamicCards(character) {
    var lists = [ character.getCardsInHand(), character.getOriginalDeck(), character.getShuffeledDeck() ]
    for (var l = 0; l < array_length(lists); l++) {
        var cards = lists[l]
        for (var i = 0; i < array_length(cards); i++) {
            if (variable_struct_exists(cards[i], "isFlask") && cards[i].isFlask) {
                flaskRefresh(cards[i], character)
            }
        }
    }
}

// Иконка ингредиента 
function ingredientIcon(ingredient) {
    switch (ingredient) {
        case Ingredient.Flower: return sFlower
        case Ingredient.Mushroom: return sMushroom
        case Ingredient.Leaf: return sLeaf
    }
    return noone
}
