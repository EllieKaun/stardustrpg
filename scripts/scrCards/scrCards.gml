
function playCard(card, caster, targets) {
    for(var i = 0; i < array_length(card.effects); i++) {
        var effect = card.effects[i]
        switch (effect.timing) {
            case Timing.Instant: 
                executeEffect(effect, caster, targets)
            break    
            case Timing.EndOfTurn:
                effectApplyStatus(effect, caster, targets);
            break
        }
    }
    selectedCharacter.energy -= 1 
    battleState = BattleStates.AfterPlayChecks
}

function afterPlayChecks() {
    if selectedCharacter.energy > 0 {
        battleState = BattleStates.CharacterPlay
    } else {
        selectNextCharacter()
        battleState = BattleStates.CharacterPlay
    }
}

function effectApplyStatus(
    effect,
    caster,
    targets
) {
    
}

function executeEffect(
    effect,
    caster, 
    targets
) {
    caster.pendingEffect = effect;
    caster.pendingTargets = targets;
    switch (effect.type) {
        case EffectTypes.Damage: 
            caster.changeActionState(StarriorStates.Attack, function() {
                executeDamageEffect(other.pendingEffect, other, other.pendingTargets)
            })
        break   
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
                timing: Timing.Instant
            }
        ]
    )
}