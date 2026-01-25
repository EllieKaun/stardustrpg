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
                    effectApplyStatus(effect, caster, targets)
                break 
                case Timing.Overtime:
                    effectApplyStatus(effect, caster, targets)
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
                case EffectTypes.Heal:
                    executeEndOFTurnHeal(character, effect, i)
                break
                case EffectTypes.ManaGain:
                    executeEndOFTurnManaGain(character, effect, i)
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

function executeEndOFTurnHeal(character, effect, index) {
    character.hp += effect.value
    effect.duration -= 1 
    if effect.duration <= 0 {
        array_delete(character.effects, index, 1)
    }
}

function executeEndOFTurnManaGain(character, effect, index) {
    character.mana += effect.value
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
    
    if (is_array(targets)) {
        for(var i = 0; i < array_length(targets); i++) {
            if !variable_instance_exists(effect, "chance") || prob <= effect.chance {
                array_push(targets[i].effects, effect)
            }
        }
    } else {
        if !variable_instance_exists(effect, "chance") || prob <= effect.chance {
            array_push(targets.effects, effect)
        }
    }
}

function executeEffect(
    effect,
    caster, 
    targets
) {
    switch (effect.type) {
        case EffectTypes.Damage: 
            if is_array(targets) {
                for(var i = 0; i < array_length(targets); i++) {
                    executeDamageEffect(effect, other, targets[i])
                }
            } else {
                executeDamageEffect(effect, other, targets)
            }
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
        case EffectTypes.ManaGain: 
            executeManaGain(effect, other, targets)
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

function executeDamageEffect(
    effect,
    caster,
    targets
) {
    var damageType = effect.damageType
    var damagePercentModifier = 0
    var damage = effect.value 
    var physicalDamageBuff = checkIfHasBuff(caster, EffectTypes.Buff, ModifiersToBuff.PhysicalDamage)
    var magicalDamageBuff = checkIfHasBuff(caster, EffectTypes.Buff, ModifiersToBuff.MagicalDamage)
    var physicalDamageDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, ModifiersToBuff.PhysicalDamage)
    var magicalDamageDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, ModifiersToBuff.MagicalDamage)
    var physicalProtectionBuff = checkIfHasBuff(caster, EffectTypes.Buff, ModifiersToBuff.PhysicalProtection)
    var magicalProtectionBuff = checkIfHasBuff(caster, EffectTypes.Buff, ModifiersToBuff.MagicalProtection)
    var physicalProtectionDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, ModifiersToBuff.PhysicalProtection)
    var magicalProtectionDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, ModifiersToBuff.MagicalProtection)
    var doesCasterHaveWeakening = checkIfHasEffectType(caster, EffectTypes.Weakening)
    var doesTargetHaveWeakening = checkIfHasEffectType(targets, EffectTypes.Weakening)
    switch (damageType) {
    	case DamageTypes.Physical: 
            damage *= caster.strength 
            damage -= targets.guts
            if physicalDamageBuff != undefined {
                damagePercentModifier += physicalDamageBuff
            }
            if physicalDamageDebuff != undefined {
                damagePercentModifier -= physicalDamageBuff
            }
            if physicalProtectionBuff != undefined {
                damagePercentModifier -= physicalProtectionBuff
            }
            if physicalProtectionDebuff != undefined {
                damagePercentModifier += physicalProtectionDebuff
            }
        break
        case DamageTypes.Magical: 
            damage *= caster.intelligence
            damage -= targets.aura
            if magicalDamageBuff != undefined {
                damagePercentModifier += magicalDamageBuff
            }
            if magicalDamageDebuff != undefined {
                damagePercentModifier -= magicalDamageBuff
            }
            if magicalProtectionBuff != undefined {
                damagePercentModifier -= magicalProtectionBuff
            }
            if magicalProtectionDebuff != undefined {
                damagePercentModifier += magicalProtectionDebuff
            }
        break
    }
    
    if doesCasterHaveWeakening {
        damagePercentModifier -= 0.1
    }
    
    if doesTargetHaveWeakening {
        damagePercentModifier += 0.1
    }
    
    damage += damage * damagePercentModifier
    show_debug_message("damage " + string(damage) )
    targets.hp -= damage
    if variable_instance_exists(effect, "chance") 
       && variable_instance_exists(effect, "statusName") {
        var prob = random(1) 
        if effect.statusName == StatusNames.Vampirism 
           && prob <= effect.chance { 
            caster.hp += damage * 0.5 
        }
    }
    show_debug_message("executeDamageEffect")
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

function executeBuff(
    caster,
    buffType
) {
    var effects = caster.effects
    for(var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        if(effect.type == EffectTypes.Buff) {
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

function executeManaGain(
    effect,
    caster,
    targets
) { 
    if (is_array(targets)) {
        for(var i = 0; i < array_length(targets); i++) {
            targets[i].mana += effect.value
        }
    } else {
        targets.mana = targets.mana + effect.value
    }
}