function Card(name, 
            target, 
            actionType, 
            effects, 
            cardBaseSpr, 
            cardIllustrationSpr, 
            cardBorderSpr, 
            cardTokenSpr) constructor {
    self.name = name
    self.target = target
    self.effects = effects
    self.actionType = actionType
    self.cardBaseSpr = cardBaseSpr
    self.cardIllustrationSpr = cardIllustrationSpr
    self.cardBorderSpr = cardBorderSpr
    self.cardTokenSpr = cardTokenSpr
}

function playCard(card, caster, targets) {
    caster.pendingCard = card
    caster.pendingTargets = targets 
    caster.changeActionState(card.actionType, function() {
        var card = other.pendingCard
        var effects = card.effects
        var targets = other.pendingTargets
        var caster = other
        for(var i = 0; i < array_length(effects); i++) {
            var effect = effects[i]
            switch (effect.timing) {
                case Timing.Instant: 
                    executeEffect(effect, caster, targets)
                break    
                case Timing.EndOfTurn:
                    effectApplyStatus(effect, caster, targets);
                break 
                case Timing.Overtime:
                    effectApplyStatus(effect, caster, targets);
                break
            }
        }
        selectedCharacter.energy -= 1 
        removeCardFromHand(caster, card)
        afterPlayChecks()
    })
}

function executeEndOfTurn(character) {
    var effects = character.effects
    for(var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        if effect.timing == Timing.EndOfTurn {
            switch (effect.type) {
            	case EffectTypes.Damage:
                    executeEndOFTurnDamage(character, effect, i)
                break
            }
        }
    }
}

function executeEndOFTurnDamage(character, effect, index) {
    character.hp -= effect.value
    effect.duration -= 1 
    if effect.duration <= 0 {
        array_delete(character.effects, index, 1)
    }
}

function effectApplyStatus(
    effect,
    caster,
    targets
) {
    var prob = random(1)
    if !variable_instance_exists(effect, "chance") || prob <= effect.chance {
        array_push(targets.effects, effect)
    }
}

function executeEffect(
    effect,
    caster, 
    targets
) {
    switch (effect.type) {
        case EffectTypes.Damage: 
            executeDamageEffect(effect, other, targets)
            selectedTargetNumber = -1
            selectedTarget = noone
            battleState = BattleStates.AfterPlayChecks
        break    
        case EffectTypes.Heal: 
            executeHealing(effect, other, targets)
            selectedTargetNumber = -1
            selectedTarget = noone
            battleState = BattleStates.AfterPlayChecks  
        break  
        case EffectTypes.RemoveEffect: 
            executeRemoveStatus(targets, effect.statusName)
            selectedTargetNumber = -1
            selectedTarget = noone
            battleState = BattleStates.AfterPlayChecks
        break     
    }    
}

function executeStun(
    stunnedCharacter
) {
    var effects = stunnedCharacter.effects 
    for(var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        if effect.type == EffectTypes.Stun {
            effect.duration -= 1
            if(effect.duration <= 0) {
                array_delete(effects, i, 1)
            }
            return
        }
    }
}

function executeDamageEffect(
    effect,
    caster,
    targets
) {
    var damageType = effect.damageType
    var valueModificator = 1
    
    var physicalDamageBuff = executeDamageBuff(caster, ModifiersToBuff.PhysicalDamage)
    switch (damageType) {
    	case DamageTypes.Physical: 
            valueModificator = 1.5 + physicalDamageBuff
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
    if (is_array(targets)) {
        for(var i = 0; i < array_length(targets); i++) {
            targets[i].hp -= effect.value * valueModificator * resistence
        }
    } else {
         targets.hp = targets.hp - effect.value * valueModificator * resistence
    }
   
}

function executeRemoveStatus(target, status) {
    var effects = target.effects
    for(var i = 0; i < array_length(effects); i++) {
        if effects[i].statusName = status {
            array_delete(effects, i, 1)
            return
        }
    }
}


function executeDamageBuff(
    caster,
    damageType
) {
    var effects = caster.effects
    for(var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        if(effect.type == EffectTypes.Buff 
            && (effect.buffType == ModifiersToBuff.PhysicalDamage 
                || effect.buffType == ModifiersToBuff.AnyDamage)) {
            var value = effect.value 
            effect.duration -= 1 
            if(effect.duration <= 0) {
                array_delete(effects, i, 1)
            }
            return value 
        }
    }
    return 0
}

function executeHealing(
    effect,
    caster,
    targets
) { 
     if (is_array(targets)) {
        for(var i = 0; i < array_length(targets); i++) {
            targets[i].hp += effect.value
        }
    } else {
        targets.hp = targets.hp + effect.value
    }
}
