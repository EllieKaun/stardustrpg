// команды в игре
function aiTeams(actor) {
    var myTeam = actor.isEnemy ? enemies : heroes
    var enemyTeam = actor.isEnemy ? heroes : enemies
    return {
        allies: filterNotKO(myTeam),
        foes: filterNotKO(enemyTeam)
    }
}

// Ум врага
function aiBrain(actor) {
    if (variable_instance_exists(actor, "brain") && is_struct(actor.brain)) {
        return actor.brain
    }
    return brainPreset(AiBrainType.Default)
}

// Перечисление всех ходов
function enumerateMoves(actor, allies, foes) {
    var moves = []
    var hand = actor.getCardsInHand()
    var provoker = provokingFoe(foes)
    var singleFoes = (provoker != noone) ? [provoker] : foes
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
                for (var target = 0; target < array_length(singleFoes); target++) {
                    array_push(moves, { card: card, target: singleFoes[target]})
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

    if (effect.timing != Timing.Instant) {
        var tick = (effect.damageType == DamageTypes.True)
            ? max(round(cardMultiplier), 0)
            : mitigateDamage(target, effect, cardMultiplier)
        var duration = variable_struct_exists(effect, "duration") ? effect.duration : 1
        return tick * duration * effectChanceForCaster(caster, target, effect)
    }

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

// Цена розыгрыша
function aiPaysCost(actor, card) {
    if (actor.isEnemy) {
        return false
    }
    if (card.costType() == CostType.Mana) {
        return actor.maxMana > 0
    }
    return true
}

// Оценка решений
function scoreMove(move, ctx) {
    var effects = move.card.effects
    var total = 0

    var targets = is_array(move.target) ? move.target : [move.target]
    for (var target = 0; target < array_length(targets); target++) {
        if (!instance_exists(targets[target]) || targets[target].isKO()) {
            continue
        }
        ctx.target = targets[target]
        for (var effect = 0; effect < array_length(effects); effect++) {
            var handler = effectHandler(effects[effect])
            total += effectHasHook(handler, "aiValue")
                ? handler.aiValue(effects[effect], ctx)
                : AI_DEFAULT_EFFECT_VALUE
        }
    }

    if (aiPaysCost(ctx.actor, move.card)) {
        total -= move.card.costValue() * ctx.weights.thrift
    }
    return total
}

// Выбор действия после взвешивания
function selectMove(scored, brain) {
    if (array_length(scored) == 0) return undefined

    // argmax — всегда лучший
    if (brain.policy == AiPolicy.Argmax) {
        var best = scored[0]
        for (var index = 1; index < array_length(scored); index++) {
            if (scored[index].score > best.score) {
                best = scored[index]
            }
        }
        return best.move
    }

    // softmax (Boltzmann): вероятность хода ~ exp(score / temperature)
    // temperature -> 0 == почти argmax (умно)
    // temperature большая == почти случайно (глупо)
    var temp = max(0.0001, brain.temperature)

    // Умеренный разум через вычитание максимума из всех score до exp()
    var maxScore =  scored[0].score
    for (var index = 1; index < array_length(scored); index++) {
        if (scored[index].score > maxScore) {
            maxScore = scored[index].score
        }
    }
    var scale = temp * max(1, abs(maxScore))

    var weights = []
    var sum = 0

    for (var index = 0; index < array_length(scored); index++) {
        var weight = exp((scored[index].score - maxScore) / scale)
        weights[index] = weight
        sum += weight
    }
    var roll = random(sum)
    for (var index = 0; index < array_length(scored); index++) {
        roll -= weights[index]
        if (roll <= 0) {
            return scored[index].move
        }
    }
    return scored[array_length(scored) - 1].move
}

// Весь процесс принятия решения
function chooseMove(actor) {
    var brain = aiBrain(actor)
    var teams = aiTeams(actor)
    var ctx = {
        actor: actor,
        allies: teams.allies,
        foes: teams.foes,
        target: noone,
        weights: brain.weights
    }

    // 1) Хардкоженные поведения
    var hardCode = firstMatchingRule(brain.rules, ctx)
    if (hardCode != undefined) {
        return hardCode
    }

    // 2) все рабочие ходы
    var moves = enumerateMoves(actor, ctx.allies, ctx.foes)
    if (array_length(moves) == 0) {
        return undefined
    }

    // 3) оценить каждый ход
    var scored = []
    for (var i = 0; i < array_length(moves); i++) {
        array_push(scored, { move: moves[i], score: scoreMove(moves[i], ctx) })
    }

    // 4) выбрать по роли
    return selectMove(scored, brain)
}

function firstMatchingRule(rules, ctx) {
    if (rules == undefined) {
        return undefined
    }
    for (var i = 0; i < array_length(rules); i++) {
        if (!rules[i].when(ctx)) {
            continue
        }
        var move = rules[i].move(ctx)
        if (move != undefined) {
            return move
        }
    }
    return undefined
}

function findCardInHand(actor, predicate) {
    var hand = actor.getCardsInHand()
    for (var i = 0; i < array_length(hand); i++) {
        if (predicate(hand[i]) && checkIfCanPlayCard(actor, hand[i])) {
            return hand[i]
        }
    }
    return undefined
}
