// команды в игре
function aiTeams(actor) {
    var myTeam = actor.isEnemy ? enemies : heroes
    var enemyTeam = actor.isEnemy ? enemies : heroes
    return {
        allies: filterNotKO(myTeam),
        foes: filterNotKO(enemyTeam)
    }
}

// Перечисление всех ходов
function enumerateMoves(actor, allies, foes) {
    var moves = []
    var hand = actor.getCardsInHand()
    for (var index = 0; index < array_length(hand); index++) {
        var card = hand[index]
        if (!is_struct(card)) { continue }
        if (variable_struct_exists(card, "cardSet") 
            && card.cardSet == CardSet.Forest) { continue }
        if (variable_struct_exists(card, "handCharms") 
            && array_length(card.handCharms) > 0) { continue }
        if (!variable_struct_exists(card, "effects")) { continue }
        if (!checkIfCanPlayCard(actor, card)) { continue }
            
        switch (card.target) {
            case TargetTypes.SingleEnemyTarget:
                for (var target = 0; target < array_length(foes); target++) {
                    array_push(moves, { card: card, target: foes[target]})
                }
                break
        	case TargetTypes.SingleAllyTarget:
                for (var target = 0; target < array_length(allies); target++) {
                    array_push(moves, { card: card, target: allies[target]})
                }
                break
            case TargetTypes.AllEnemies:
                if (array_length(foes) > 0) {
                    array_push(moves, { card: card, target: foes })
                }
                break
            case TargetTypes.AllAllies:
                if (array_length(allies) > 0) {
                    array_push(moves, { card: card, target: allies })
                }
                break
            case TargetTypes.Self:
                array_push(moves, { card: card, target: actor })
                break
        }
    }
    return moves
}

// Оценка итогового урона по цели
function estimateDamage(effect, caster, target) {
    if (!variable_struct_exists(effect, "damageType")) { return 0 }
        
    var cardMultiplier = is_method(effect.value) ? effect.value() : effect.value
    
    // Чистый урон
    if (effect.damageType == DamageTypes.True) { 
        return max(round(cardMultiplier), 0)
    }
    
    // Маг или Физ урон
    var casterStat = 0
    var attackModifier = ModifiersToBuff.AnyDamage
    if (effect.damageType == DamageTypes.Physical) {
        casterStat = caster.strength
        attackModifier = ModifiersToBuff.PhysicalDamage
    } else {
        casterStat = caster.intelligence
        attackModifier = ModifiersToBuff.MagicalDamage
    }
    
    var atkBuff = checkIfHasBuff(caster, EffectTypes.Buff, attackModifier)
    var atkDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, attackModifier)
    if (atkBuff != undefined && is_real(atkBuff.value)) {
        casterStat += atkBuff.value
    }
    if (atkDebuff != undefined && is_real(atkDebuff.value)) { 
        casterStat -= atkDebuff.value 
    }
    casterStat += handAuraBonus(caster, attackModifier)
    if (!is_real(casterStat)) {
        casterStat = 0
    }
    casterStat = max(casterStat, 0)
    
    var damage = cardMultiplier * casterStat
    if (caster.activeIngredient == Ingredient.Mushroom) { 
        damage *= INGREDIENT_DAMAGE_MULT 
    }
    damage *= handScalingMultiplier(effect, caster)
    if (checkIfHasEffectType(caster, EffectTypes.Weakening)) { 
        damage *= 0.9 
    }
    
    return mitigateDamage(target, effect, damage)
}