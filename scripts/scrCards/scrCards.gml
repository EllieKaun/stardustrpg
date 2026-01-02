
function playCard(card, caster, targets) {
    for(var i = 0; i < array_length(card.effects); i++) {
        var effect = card.effects[i]
        switch (effect.type) {
        	case EffectTypes.Damage: 
                executeDamageEffect(effect, caster, targets)
            break    
        }   
    }
    selectedCharacter.energy -= 1 
    battleState = BattleStates.AfterPlayChecks
}

function afterPlayChecks() {
    if selectedCharacter.energy > 0 {
        battleState = BattleStates.PlayProcess
    } else {
        selectNextCharacter()
        battleState = BattleStates.PlayProcess
    }
}

function executeDamageEffect(
    effect,
    caster,
    targets
) {
    var damageType = effect.damageType
    var valueModificator = 1
    switch (damageType) {
    	case DamageTypes.Physical: 
            valueModificator = 1.5
        break
        case DamageTypes.Magical: 
            valueModificator = 1.5
        break
    }
    var resistence = 1
    switch (damageType) {
    	case DamageTypes.Physical: 
            resistence = 0.7
        break
        case DamageTypes.Magical: 
            resistence = 0.7
        break
    }
    targets.hp = targets.hp - effect.value * valueModificator * resistence
}

function createPhysicalDamageCardDefault() {
    return new Card(
        "Default attack",
        sprCardAttaclBase,
        sprCommonBorder,
        TargetTypes.SingleTarget,
        [
            {
                type: EffectTypes.Damage,
                damageType: DamageTypes.Physical,
                value: random_range(1, 3),
                actionType: ActionType.Instant
            }
        ]
    )
}