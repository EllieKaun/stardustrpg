function cloneEffect(effect) {
    var copy = {}
    var names = variable_struct_get_names(effect)
    for (var nameIndex = 0; nameIndex < array_length(names); nameIndex++) {
        variable_struct_set(copy, names[nameIndex], variable_struct_get(effect, names[nameIndex]))
    }
    return copy
}

// Поле эффекта или undefined, если его нет
function effectField(effect, fieldName) {
    return variable_instance_exists(effect, fieldName)
        ? variable_struct_get(effect, fieldName)
        : undefined
}

// Считаем эффекты одинаковыми, если совпадает тип и уточнения:
// статус (Burn/Freeze...), модификатор баффа/дебаффа, цель временной слабости
function effectsMatch(effectA, effectB) {
    if (effectField(effectA, "type") != effectField(effectB, "type")) { return false }
    if (effectField(effectA, "statusName") != effectField(effectB, "statusName")) { return false }
    if (effectField(effectA, "buffType") != effectField(effectB, "buffType")) { return false }
    if (effectField(effectA, "weakness") != effectField(effectB, "weakness")) { return false }
    return true
}

// Если такой же эффект уже наложен — обновляем длительность
// justApplied=true — эффект наложен в текущем ходу
function refreshOrPushEffect(target, effect) {
    var effects = target.effects
    for (var effectIndex = 0; effectIndex < array_length(effects); effectIndex++) {
        if (effectsMatch(effects[effectIndex], effect)) {
            if (variable_instance_exists(effect, "duration")) {
                effects[effectIndex].duration = effect.duration
            }
            effects[effectIndex].justApplied = true
            return effects[effectIndex]
        }
    }
    var applied = cloneEffect(effect)
    applied.justApplied = true
    array_push(effects, applied)
    return applied
}

// шанс наложения статуса на цель: базовый + бонус, если цель слаба к этому статусу 
function effectChanceFor(target, effect) {
    if (!variable_instance_exists(effect, "chance")) { return 1 } 
    var chance = effect.chance
    if (checkIfHasWeaknesses(target, effect)) { chance += WEAKNESS_STATUS_CHANCE_BONUS }
    return clamp(chance, 0, 1)
}

function casterIsIgnited(caster) {
    if (caster == undefined || caster == noone) { return false }
    if (!variable_instance_exists(caster, "isIgnited")) { return false }
    return caster.isIgnited && variable_instance_exists(caster, "igniteEffectChance")
}

function effectChanceForCaster(caster, target, effect) {
    if (!variable_instance_exists(effect, "chance")) { return 1 }
    var base = casterIsIgnited(caster) ? caster.igniteEffectChance : effect.chance
    if (checkIfHasWeaknesses(target, effect)) { base += WEAKNESS_STATUS_CHANCE_BONUS }
    return clamp(base, 0, 1)
}

function effectApplyStatus(effect, caster, targets) {
    var prob = random(1)
    var ignited = variable_instance_exists(effect, "chance") && casterIsIgnited(caster)
    var anyProc = false

    if (is_array(targets)) {
        for(var targetIndex = 0; targetIndex < array_length(targets); targetIndex++) {
            if (prob <= effectChanceForCaster(caster, targets[targetIndex], effect)) {
                anyProc = true
                var applied = refreshOrPushEffect(targets[targetIndex], effect)
                runOnApply(applied, caster, targets[targetIndex])
                if variable_instance_exists(targets[targetIndex], "showEffectNotification") {
                    targets[targetIndex].showEffectNotification(applied, EffectVisualizerType.TimeBased, 1)
                }
            }
        }
    } else {
        if (prob <= effectChanceForCaster(caster, targets, effect)) {
            anyProc = true
            var applied = refreshOrPushEffect(targets, effect)
            runOnApply(applied, caster, targets)
            if variable_instance_exists(targets, "showEffectNotification") {
                targets.showEffectNotification(applied, EffectVisualizerType.TimeBased, 1)
            }
        }
    }

    if (ignited) {
        caster.igniteEffectChance = anyProc ? 0.1 : min(1, caster.igniteEffectChance * 1.5)
    }
}

// Мгновенный эффект: вызываем onInstant обработчика и сбрасываем выбор цели
function executeEffect(effect, caster, targets) {
    runInstant(effect, caster, targets)
    selectedTargetNumber = -1
    selectedTarget = noone
    changeBattleState(BattleStates.AfterPlayChecks)
}

// Сила к стихии/статусу входящего эффекта
function checkIfHasStrengths(target, effect) {
    if (variable_instance_exists(effect, "statusName")
        && array_contains(target.strengths, effect.statusName)) {
        return true
    }
    return false
}

// Слабость к стихии/статусу входящего эффекта
function checkIfHasWeaknesses(target, effect) {
    if checkIfHasEffectType(target, EffectTypes.IgnoreWeakness) { return false }
    if (variable_instance_exists(effect, "statusName")
        && array_contains(target.weaknesses, effect.statusName)) {
        return true
    }
    var effects = target.effects
    for(var effectIndex = 0; effectIndex < array_length(effects); effectIndex++) {
        var currentEffect = effects[effectIndex]
        if(currentEffect.type == EffectTypes.CreateTemporaryWeakness
            && variable_instance_exists(effect, "weakness")) {
            if currentEffect.weakness == effect.type {
                return true
            }
        }
    }
    return false
}

// Находится ли цель в состоянии, к которому она слаба
function checkIfWeakStateActive(target) {
    if checkIfHasEffectType(target, EffectTypes.IgnoreWeakness) { return false }
    var effects = target.effects
    for (var effectIndex = 0; effectIndex < array_length(effects); effectIndex++) {
        var effect = effects[effectIndex]
        if (variable_instance_exists(effect, "statusName")
            && array_contains(target.weaknesses, effect.statusName)) {
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
    var cardMultiplier = is_method(effect.value) ? effect.value() : effect.value

    // Характеристика кастера + баффы и дебаффы атаки
    // Итоговый урон = характеристика * множитель карты
    var casterStat, attackModifier
    if (damageType == DamageTypes.Physical) {
        casterStat = caster.strength
        attackModifier = ModifiersToBuff.PhysicalDamage
    } else {
        casterStat = caster.intelligence
        attackModifier = ModifiersToBuff.MagicalDamage
    }
    var attackBuff = checkIfHasBuff(caster, EffectTypes.Buff,   attackModifier)
    var attackDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, attackModifier)
    if (attackBuff != undefined && is_real(attackBuff.value)) { casterStat += attackBuff.value }
    if (attackDebuff != undefined && is_real(attackDebuff.value)) { casterStat -= attackDebuff.value }
    if (!is_real(casterStat)) { casterStat = 0 }
    casterStat = max(casterStat, 0)

    var damage = cardMultiplier * casterStat

    damage *= handScalingMultiplier(effect, caster)
    
    // Ослабление кастера
    if (checkIfHasEffectType(caster, EffectTypes.Weakening)) { damage *= 0.9 }

    // Модификация на стороне ЦЕЛИ: защита (+ баффы и дебаффы), слабости и сопротивления
    damage = mitigateDamage(targets, effect, damage)
    if (checkIfHasEffectType(targets, EffectTypes.Deflect)) {
        reduceOrRemoveEffectType(targets, EffectTypes.Deflect)
        caster.applyDamage(damage * 2)
        return
    }
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
    for(var effectIndex = 0; effectIndex < array_length(effects); effectIndex++) {
        if effects[effectIndex].statusName == status {
            target.showEffectNotification(effects[effectIndex], EffectVisualizerType.TimeBased, 1)
            array_delete(effects, effectIndex, 1)
            return
        }
    }
}

function reduceOrRemoveEffectType(target, effectType) {
    var effects = target.effects
    for (var effectIndex = 0; effectIndex < array_length(effects); effectIndex++) {
        var effect = effects[effectIndex]
        if (effect.type == effectType) {
            if (variable_instance_exists(effect, "duration")) {
                effect.duration -= 1
                if (effect.duration <= 0) { array_delete(effects, effectIndex, 1) }
            } else {
                array_delete(effects, effectIndex, 1)
            }
            return
        }
    }
}

function executeHealing(effect, caster, targets) {
    if (is_array(targets)) {
        for(var targetIndex = 0; targetIndex < array_length(targets); targetIndex++) {
            if !targets[targetIndex].isKO() {
                targets[targetIndex].applyHeal(effect.value)
                targets[targetIndex].showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
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
        for(var targetIndex = 0; targetIndex < array_length(targets); targetIndex++) {
            if !targets[targetIndex].isKO() {
                targets[targetIndex].applyMana(effect.value)
                targets[targetIndex].showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
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

    // Защита цели + баффы и дебаффы защиты + заморозка как дебафф физ. защиты
    var defense, protectionModifier
    if (damageType == DamageTypes.Magical) {
        defense = target.aura
        protectionModifier = ModifiersToBuff.MagicalProtection
    } else {
        defense = target.guts
        protectionModifier = ModifiersToBuff.PhysicalProtection
    }
    var protectionBuff = checkIfHasBuff(target, EffectTypes.Buff, protectionModifier)
    var protectionDebuff = checkIfHasBuff(target, EffectTypes.Debuff, protectionModifier)
    if (protectionBuff != undefined && is_real(protectionBuff.value)) { defense += protectionBuff.value }
    if (protectionDebuff != undefined && is_real(protectionDebuff.value)) { defense -= protectionDebuff.value }
    if (!is_real(defense)) { defense = 0 }
    damage -= max(defense, 0)

    // Слабые места и ослабление как процентные модификаторы урона
    if (checkIfHasEffectType(target, EffectTypes.Weakening)) { modifier += 0.1 }
    // Слабые места: сила (−); слабость к стихии входящего эффекта (+);
    // и доп. урон, пока цель В СОСТОЯНИИ, к которому слаба (+).
    if (checkIfHasStrengths(target, effect)) { modifier -= WEAKNESS_DAMAGE_MODIFIER }
    if (checkIfHasWeaknesses(target, effect)) { modifier += WEAKNESS_DAMAGE_MODIFIER }
    if (checkIfWeakStateActive(target)) { modifier += WEAKNESS_DAMAGE_MODIFIER }

    damage += damage * modifier
    return max(round(damage), 1)
}

// Изменение урона в зависимости от руки

function handScalingMultiplier(effect, caster) {
    if (!variable_struct_exists(effect, "handScaling")) {
        return 1
    }
    var cardsInHand = array_length(caster.getCardsInHand())
    switch (effect.handScaling) {
        case HandScaling.MoreCard:
            return cardsInHand * HAND_SCALING_STEP
        case HandScaling.FewerCards:
            var missing = max(0, CARDS_DRAW_COUNT - 1 - cardsInHand)
            return 1 + missing * HAND_SCALING_STEP
        default:
            return 1
    }
}
