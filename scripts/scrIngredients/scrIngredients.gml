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
        return false 
    }
}


function refreshDynamicCards(character) { /* заполнится в части 8 */ }
