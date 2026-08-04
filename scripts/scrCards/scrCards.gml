function Card(name, 
            rarity,
            target, 
            actionType, 
            energy,
            effects, 
            cardBaseSpr, 
            cardIllustrationSpr, 
            cardBorderSpr, 
            cardTokenSpr) constructor {
    self.name = name
    self.rarity = rarity
    self.target = target
    self.effects = effects
    self.actionType = actionType
    self.cardBaseSpr = cardBaseSpr
    self.cardIllustrationSpr = cardIllustrationSpr
    self.cardBorderSpr = cardBorderSpr
    self.cardTokenSpr = cardTokenSpr
    self.energy = energy

    // Стоимость карты детерминирована (зависит только от actionType/effects/rarity,
    // которые после создания не меняются) — считаем один раз при создании, а не
    // каждый кадр в отрисовке.
    self.costTypeCached  = (actionType == StarriorStates.Attack) ? CostType.Health : CostType.Mana
    self.costValueCached = computeCardCost(rarity, effects)
    self.costType  = function() { return self.costTypeCached }
    self.costValue = function() { return self.costValueCached }
}

// Стоимость карты по её первому эффекту и редкости. Детерминирована, поэтому
// считается один раз при создании карты (кэшируется в costValueCached).
function computeCardCost(rarity, effects) {
    var effectsCount = array_length(effects)
    if (effectsCount == 0) return 0

    var effect = effects[0]
    // У эффекта может не быть type (kind-only эффекты вроде BossClone) —
    // тогда уходим в ветку по умолчанию.
    var effectType = variable_struct_exists(effect, "type") ? effect.type : undefined
    if (effectType == EffectTypes.Damage && effect.damageType == DamageTypes.Physical) {
        if (effectsCount > 1) {
            return getCostByRarity(rarity, 4, 5, 6, 7)
        } else {
            return getCostByRarity(rarity, 2, 3, 4, 5)
        }
    } else if (effectType == EffectTypes.Damage && effect.damageType == DamageTypes.Magical) {
        return getCostByRarity(rarity, 3, 4, 5, 6)
    } else if (effectType == EffectTypes.Heal && effect.timing == Timing.Instant) {
        return getCostByRarity(rarity, 3, 4, 5, 6)
    } else if (effectType == EffectTypes.Heal && effect.timing == Timing.EndOfTurn) {
        return getCostByRarity(rarity, 2, 3, 4, 5)
    } else {
        return getCostByRarity(rarity, 3, 4, 5, 6)
    }
}

function getCostByRarity(rarity, dafault, unusual, rare, epic) {
    switch (rarity) {
    	case CardsRarity.Default: 
            return dafault
    	case CardsRarity.Unusual: 
            return unusual      
    	case CardsRarity.Rare: 
            return rare 
    	case CardsRarity.Epic: 
            return epic      
    }
}

function getDamageFuncOnRariryAndTarget(rarity, target) {
    if rarity == CardsRarity.Default {
        if target == TargetTypes.SingleEnemyTarget {
            return function() { return irandom_range(1, 4) } 
        } else {
            return function() { return irandom_range(1, 2) } 
        }
    } else if rarity == CardsRarity.Unusual {
        if target == TargetTypes.SingleEnemyTarget {
            return function() { return irandom_range(1, 6) } 
        } else {
            return function() { return irandom_range(1, 4) } 
        }
    } else if rarity == CardsRarity.Rare {
        if target == TargetTypes.SingleEnemyTarget {
            return function() { return irandom_range(1, 8) } 
        } else {
            return function() { return irandom_range(1, 6) } 
        }
    } else if rarity == CardsRarity.Epic {
        if target == TargetTypes.SingleEnemyTarget {
            return function() { return irandom_range(1, 12) } 
        } else {
            return function() { return irandom_range(1, 8) } 
        }
    }
}

// Есть ли у карты эффект воскрешения?
function cardIsResurrection(card) {
    for (var i = 0; i < array_length(card.effects); i++) {
        var e = card.effects[i]
        if (variable_struct_exists(e, "type") && e.type == EffectTypes.Resurrection) return true
    }
    return false
}

function checkIfCanPlayCard(caster, card) {
    // Воскрешение: нужен хотя бы один павший (не-кукла) союзник
    if (cardIsResurrection(card)) {
        var team = caster.isEnemy ? enemies : heroes
        var hasKO = false
        for (var i = 0; i < array_length(team); i++)
            if (!team[i].isPuppet && team[i].isKO()) { hasKO = true; break }
        if (!hasKO) return false
    }

    if (caster.isEnemy) return true                   // враги играют бесплатно (нет маны)

    if (card.costType() == CostType.Mana) {
        if (caster.maxMana <= 0) return true
        return caster.mana >= card.costValue()
    } else {
        return caster.hp > card.costValue()           // нельзя уйти в 0 HP от стоимости
    }
}

function applyCost(caster, card) {
    if (caster.isEnemy) return                        // враги играют бесплатно (не режут себе HP)

    if (card.costType() == CostType.Mana) {
        if (caster.maxMana <= 0) return
        caster.mana = caster.mana - card.costValue()
    } else {
        caster.hp = caster.hp - card.costValue()
        // подстраховка: если герой всё же ушёл в 0 HP — нокаут
        if (caster.hp <= 0 && caster.actionState != StarriorStates.KnockOut) {
            caster.changeActionState(StarriorStates.KnockOut, undefined)
        }
    }
}

function playCard(card, caster, targets) {
    caster.pendingCard = card
    caster.pendingTargets = targets 
    applyCost(caster, card)
    if checkIfHasEffectType(selectedCharacter, EffectTypes.CopyCard) { 
        copyNextCard = true
        reduceOrRemoveEffectType(selectedCharacter, EffectTypes.CopyCard)
    }
    
    removeCardFromHand(caster, card)
    show_debug_message("play card: " + card.name)
    caster.changeActionState(card.actionType, function() {
        var card = other.pendingCard
        var effects = card.effects
        var targets = other.pendingTargets
        var caster = other
        for(var i = 0; i < array_length(effects); i++) {
            var effect = effects[i]
            show_debug_message("processing effect: " + (variable_struct_exists(effect, "kind") ? string(effect.kind) : effectTypeToString(effect.type)))
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
                case Timing.OnActions:
                    runOnPlay(effect, caster, targets)
                    targets.showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
                break
            }
        }
        selectedCharacter.energy -= card.energy 
        if copyNextCard {
            copyNextCard = false
            array_push(selectedCharacter.deck.cardsInHand, card)
        }
        afterPlayChecks()
    })
}

// Конец хода: обобщённый проход. Для каждого EndOfTurn-эффекта вызываем
// onEndOfTurn его обработчика, показываем нотификацию и тикаем длительность.
// Никакого switch по типу — поведение задано в реестре (scrEffectSystem).
function executeEndOfTurn(character) {
    var effects = character.effects
    for(var i = array_length(effects) - 1; i >= 0; i--) {
        var effect = effects[i]
        if (effect.timing != Timing.EndOfTurn) continue
        var h = effectHandler(effect)
        if (effectHasHook(h, "onEndOfTurn")) {
            h.onEndOfTurn(effect, character)
            character.showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
            if (variable_instance_exists(effect, "duration")) {
                effect.duration -= 1
                if (effect.duration <= 0) array_delete(effects, i, 1)
            }
        }
    }
}

// Поверхностная копия эффекта. Нужна, чтобы у каждой цели был свой
// экземпляр (своя duration), а не общая ссылка на эффект карты.
function cloneEffect(effect) {
    var copy = {}
    var names = variable_struct_get_names(effect)
    for (var i = 0; i < array_length(names); i++) {
        variable_struct_set(copy, names[i], variable_struct_get(effect, names[i]))
    }
    return copy
}

// Поле эффекта или undefined, если его нет (для structs работает так же)
function effectField(effect, fieldName) {
    return variable_instance_exists(effect, fieldName)
        ? variable_struct_get(effect, fieldName)
        : undefined
}

// Считаем эффекты "одинаковыми", если совпадает тип и уточняющие признаки:
// статус (Burn/Freeze...), модификатор баффа/дебаффа, цель временной слабости.
function effectsMatch(a, b) {
    if (effectField(a, "type") != effectField(b, "type")) return false
    if (effectField(a, "statusName") != effectField(b, "statusName")) return false
    if (effectField(a, "buffType")   != effectField(b, "buffType"))   return false
    if (effectField(a, "weakness")   != effectField(b, "weakness"))   return false
    return true
}

// Если такой же эффект уже наложен — обновляем длительность вместо дубликата.
function refreshOrPushEffect(target, effect) {
    var effects = target.effects
    for (var i = 0; i < array_length(effects); i++) {
        if (effectsMatch(effects[i], effect)) {
            if (variable_instance_exists(effect, "duration")) {
                effects[i].duration = effect.duration
            }
            return effects[i]
        }
    }
    var applied = cloneEffect(effect)
    array_push(effects, applied)
    return applied
}

// Эффективный шанс наложения статуса на цель: базовый + бонус, если цель слаба
// к этому статусу («выше вероятность быть оглушённым/подожжённым» из спеки).
function effectChanceFor(target, effect) {
    if (!variable_instance_exists(effect, "chance")) return 1   // без шанса — всегда
    var c = effect.chance
    if (checkIfHasWeaknesses(target, effect)) c += WEAKNESS_STATUS_CHANCE_BONUS
    return clamp(c, 0, 1)
}

function effectApplyStatus(effect, caster, targets) {
    var prob = random(1)

    if (is_array(targets)) {
        for(var i = 0; i < array_length(targets); i++) {
            if (prob <= effectChanceFor(targets[i], effect)) {
                var applied = refreshOrPushEffect(targets[i], effect)
                runOnApply(applied, caster, targets[i])
                if variable_instance_exists(targets[i], "showEffectNotification") {
                    targets[i].showEffectNotification(applied, EffectVisualizerType.TimeBased, 1)
                }
            }
        }
    } else {
        if (prob <= effectChanceFor(targets, effect)) {
            var applied = refreshOrPushEffect(targets, effect)
            runOnApply(applied, caster, targets)
            if variable_instance_exists(targets, "showEffectNotification") {
                targets.showEffectNotification(applied, EffectVisualizerType.TimeBased, 1)
            }
        }
    }
}

// Мгновенный эффект: вызываем onInstant обработчика и сбрасываем выбор цели.
// Поведение каждого типа задано в реестре (scrEffectSystem), без switch.
function executeEffect(effect, caster, targets) {
    runInstant(effect, caster, targets)
    selectedTargetNumber = -1
    selectedTarget = noone
    battleState = BattleStates.AfterPlayChecks
}

// Сила к стихии/статусу входящего эффекта (совпадение по statusName; массивы
// strengths хранят значения StatusNames, поэтому сравниваем только с ним, чтобы
// не пересечься по числам с EffectTypes).
function checkIfHasStrengths(target, effect) {
    if (variable_instance_exists(effect, "statusName")
        && array_contains(target.strengths, effect.statusName)) {
        return true
    }
    return false
}

// Слабость к стихии/статусу входящего эффекта (по statusName) + временная
// слабость к типу урона от карты Create Temporary Weakness.
function checkIfHasWeaknesses(target, effect) {
    if checkIfHasEffectType(target, EffectTypes.IgnoreWeakness) return false
    if (variable_instance_exists(effect, "statusName")
        && array_contains(target.weaknesses, effect.statusName)) {
        return true
    }
    var effects = target.effects
    for(var i = 0; i < array_length(effects); i++) {
        var curFffect = effects[i]
        if(curFffect.type == EffectTypes.CreateTemporaryWeakness
            && variable_instance_exists(effect, "weakness")) {
            if curFffect.weakness == effect.type {
                return true
            }
        }
    }
    return false
}

// Находится ли цель в состоянии (активный статус), к которому она слаба?
// Спека: «повышенное получение урона в таком состоянии».
function checkIfWeakStateActive(target) {
    if checkIfHasEffectType(target, EffectTypes.IgnoreWeakness) return false
    var effects = target.effects
    for (var i = 0; i < array_length(effects); i++) {
        var e = effects[i]
        if (variable_instance_exists(e, "statusName")
            && array_contains(target.weaknesses, e.statusName)) {
            return true
        }
    }
    return false
}

function executeDamageEffect(
    effect,
    caster,
    targets
) {
    var damageType = effect.damageType
    var damage = is_method(effect.value) ? effect.value() : effect.value

    // Базовый урон с учетом характеристики кастера
    switch (damageType) {
        case DamageTypes.Physical: damage *= caster.strength;     break
        case DamageTypes.Magical:  damage *= caster.intelligence; break
    }

    // Модификаторы ИСХОДЯЩЕГО урона кастера: баффы/дебаффы атаки — множители
    // (бафф value=1.5 => x1.5, дебафф value=1.5 => /1.5).
    var outMult = 1
    if (damageType == DamageTypes.Physical) {
        var pdBuff   = checkIfHasBuff(caster, EffectTypes.Buff,   ModifiersToBuff.PhysicalDamage)
        var pdDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, ModifiersToBuff.PhysicalDamage)
        if (pdBuff   != undefined && pdBuff.value   != 0) outMult *= pdBuff.value
        if (pdDebuff != undefined && pdDebuff.value != 0) outMult /= pdDebuff.value
    } else {
        var mdBuff   = checkIfHasBuff(caster, EffectTypes.Buff,   ModifiersToBuff.MagicalDamage)
        var mdDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, ModifiersToBuff.MagicalDamage)
        if (mdBuff   != undefined && mdBuff.value   != 0) outMult *= mdBuff.value
        if (mdDebuff != undefined && mdDebuff.value != 0) outMult /= mdDebuff.value
    }
    if (checkIfHasEffectType(caster, EffectTypes.Weakening)) outMult *= 0.9

    damage *= outMult

    // Митигация на стороне ЦЕЛИ: защита (баффы/дебаффы), броня, слабости/сопротивления.
    // Та же функция используется и для End Of Turn урона, поэтому логика едина.
    damage = mitigateDamage(targets, effect, damage)

    show_debug_message("damage " + string(damage) )
    targets.applyDamage(damage)
    targets.showEffectNotification(effect, EffectVisualizerType.AnimationEnd, 1)
    if variable_instance_exists(effect, "chance") 
       && variable_instance_exists(effect, "statusName") {
        var prob = random(1) 
        if effect.statusName == StatusNames.Vampirism
           && prob <= effect.chance {
            caster.applyHeal(round(damage * 0.2))
        }
    }
    show_debug_message("executeDamageEffect")
}

function executeRemoveStatus(target, status) {
    var effects = target.effects
    for(var i = 0; i < array_length(effects); i++) {
        if effects[i].statusName == status {
            target.showEffectNotification(effects[i], EffectVisualizerType.TimeBased, 1)
            array_delete(effects, i, 1)
            return
        }
    }
}

function reduceOrRemoveEffectType(target, effectType) {
    var effects = target.effects
    for (var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        if (effect.type == effectType) {
            if (variable_instance_exists(effect, "duration")) {
                effect.duration -= 1
                if (effect.duration <= 0) array_delete(effects, i, 1)
            } else {
                array_delete(effects, i, 1)
            }
            return
        }
    }
}

function executeHealing(effect, caster, targets) { 
    if (is_array(targets)) {
        for(var i = 0; i < array_length(targets); i++) {
            if !targets[i].isKO() {
                targets[i].applyHeal(effect.value)
                targets[i].showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
            }
        }
    } else {
        if !targets.isKO() {
            targets.applyHeal(effect.value)
            targets.showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
        }
    }
}

function executeManaGain(effect, caster, targets) { 
    if (is_array(targets)) {
        for(var i = 0; i < array_length(targets); i++) {
            if !targets[i].isKO() {
                targets[i].applyMana(effect.value)
                targets[i].showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
            }
        }
    } else {
        if !targets.isKO() {
            targets.applyMana(effect.value)
            targets.showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
        }
    }
}

// Помощь в расчете урона

function getEffectDamageType(effect) {
    return variable_instance_exists(effect, "damageType") ? effect.damageType : DamageTypes.Physical;
}

function mitigateDamage(target, effect, rawDamage) {
    var damage = rawDamage
    var modifier = 0
    var damageType = getEffectDamageType(effect)

    switch (damageType) {
        case DamageTypes.Physical:
            damage -= target.guts
            var pProtBuff = checkIfHasBuff(target, EffectTypes.Buff,   ModifiersToBuff.PhysicalProtection)
            var pProtDebuff = checkIfHasBuff(target, EffectTypes.Debuff, ModifiersToBuff.PhysicalProtection)
            if (pProtBuff != undefined) modifier -= pProtBuff.value
            if (pProtDebuff != undefined) modifier += pProtDebuff.value
            break
        case DamageTypes.Magical:
            damage -= target.aura
            var mProtBuff   = checkIfHasBuff(target, EffectTypes.Buff,   ModifiersToBuff.MagicalProtection)
            var mProtDebuff = checkIfHasBuff(target, EffectTypes.Debuff, ModifiersToBuff.MagicalProtection)
            if (mProtBuff   != undefined) modifier -= mProtBuff.value
            if (mProtDebuff != undefined) modifier += mProtDebuff.value
            break
    }

    if (checkIfHasEffectType(target, EffectTypes.Weakening)) modifier += 0.1
    // Слабые места: сила (−); слабость к стихии входящего эффекта (+);
    // и доп. урон, пока цель В СОСТОЯНИИ, к которому слаба (+).
    if (checkIfHasStrengths(target, effect))  modifier -= WEAKNESS_DAMAGE_MODIFIER
    if (checkIfHasWeaknesses(target, effect)) modifier += WEAKNESS_DAMAGE_MODIFIER
    if (checkIfWeakStateActive(target))       modifier += WEAKNESS_DAMAGE_MODIFIER

    damage += damage * modifier
    return max(round(damage), 0)   // урон — целое число
}
