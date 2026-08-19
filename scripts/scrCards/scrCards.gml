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

    self.costTypeCached  = (actionType == StarriorStates.Attack) ? CostType.Health : CostType.Mana
    self.costValueCached = computeCardCost(rarity, effects)
    self.costType  = function() { return self.costTypeCached }
    self.costValue = function() { return self.costValueCached }
}

// Стоимость карты по её первому эффекту и редкости (кэшируется в costValueCached)
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

// Множитель к характеристике (сила/интеллект) для мгновенного урона карты
// по редкости и типу цели
function getDamageMultiplierOnRarityAndTarget(rarity, target) {
    var single = (target == TargetTypes.SingleEnemyTarget)
    if rarity == CardsRarity.Default {
        return single ? 1 : 1
    } else if rarity == CardsRarity.Unusual {
        return single ? 1.5 : 1
    } else if rarity == CardsRarity.Rare {
        return single ? 2 : 1.5
    } else if rarity == CardsRarity.Epic {
        return single ? 2.5 : 2
    }
}

// Мгновенное лечение по редкости
function getInstantHealValueOnRarity(rarity) {
    switch (rarity) {
        case CardsRarity.Default: return 10
        case CardsRarity.Unusual: return 20
        case CardsRarity.Rare: return 30
        case CardsRarity.Epic: return HEAL_FULL
    }
}

// Постепенное лечение по редкости
function getOvertimeHealValueOnRarity(rarity) {
    switch (rarity) {
        case CardsRarity.Default: return 6
        case CardsRarity.Unusual: return 8
        case CardsRarity.Rare: return 12
        case CardsRarity.Epic: return 16
    }
}

// Длительность постепенного лечения по редкости 
function getOvertimeHealDurationOnRarity(rarity) {
    switch (rarity) {
        case CardsRarity.Default: return 2
        case CardsRarity.Unusual: return 2
        case CardsRarity.Rare: return 3
        case CardsRarity.Epic: return 3
    }
}


// Мгновенное восстановление маны по редкости
function getInstantManaValueOnRarity(rarity) {
    switch (rarity) {
        case CardsRarity.Default: return 10
        case CardsRarity.Unusual: return 20
        case CardsRarity.Rare: return 30
        case CardsRarity.Epic: return MANA_FULL
    }
}

// Постепенное восстановление маны по редкости за ход
function getOvertimeManaValueOnRarity(rarity) {
    switch (rarity) {
        case CardsRarity.Default: return 6
        case CardsRarity.Unusual: return 8
        case CardsRarity.Rare: return 12
        case CardsRarity.Epic: return 16
    }
}

// Длительность постепенного восстановления маны
function getOvertimeManaDurationOnRarity(rarity) {
    switch (rarity) {
        case CardsRarity.Default: return 2
        case CardsRarity.Unusual: return 2
        case CardsRarity.Rare: return 3
        case CardsRarity.Epic: return 3
    }
}

// Величина усиления/снижения характеристики по редкости
function getBuffValueOnRarity(rarity) {
    switch (rarity) {
        case CardsRarity.Default: return 2
        case CardsRarity.Unusual: return 4
        case CardsRarity.Rare:    return 6
        case CardsRarity.Epic:    return 8
    }
}

// Есть ли у карты эффект воскрешения
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

    if (caster.isEnemy) return true // враги играют бесплатно

    if (card.costType() == CostType.Mana) {
        if (caster.maxMana <= 0) return true
        return caster.mana >= card.costValue()
    } else {
        return caster.hp > card.costValue() // нельзя уйти в 0 HP от стоимости
    }
}

function applyCost(caster, card) {
    if (caster.isEnemy) return // враги играют бесплатно 

    if (card.costType() == CostType.Mana) {
        if (caster.maxMana <= 0) return
        caster.mana = caster.mana - card.costValue()
    } else {
        caster.hp = caster.hp - card.costValue()
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
    playPendingCaster = caster
    show_debug_message("play card: " + card.name)
    caster.changeActionState(cardAnimState(card), function() {
        var caster = playPendingCaster
        var card = caster.pendingCard
        var effects = card.effects
        var targets = caster.pendingTargets
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
    }, cardCastSpriteOverride(card))
}

// Конец хода. Для каждого EndOfTurn-эффекта вызываем
// onEndOfTurn его обработчика
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
// экземпляр, а не общая ссылка на эффект карты
function cloneEffect(effect) {
    var copy = {}
    var names = variable_struct_get_names(effect)
    for (var i = 0; i < array_length(names); i++) {
        variable_struct_set(copy, names[i], variable_struct_get(effect, names[i]))
    }
    return copy
}

// Поле эффекта или undefined, если его нет
function effectField(effect, fieldName) {
    return variable_instance_exists(effect, fieldName)
        ? variable_struct_get(effect, fieldName)
        : undefined
}

// Считаем эффекты "одинаковыми", если совпадает тип и уточняющие признаки:
// статус (Burn/Freeze...), модификатор баффа/дебаффа, цель временной слабости
function effectsMatch(a, b) {
    if (effectField(a, "type") != effectField(b, "type")) return false
    if (effectField(a, "statusName") != effectField(b, "statusName")) return false
    if (effectField(a, "buffType") != effectField(b, "buffType")) return false
    if (effectField(a, "weakness") != effectField(b, "weakness")) return false
    return true
}

// Если такой же эффект уже наложен — обновляем длительность вместо дубликата
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
// к этому статусу 
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

// Мгновенный эффект: вызываем onInstant обработчика и сбрасываем выбор цели
function executeEffect(effect, caster, targets) {
    runInstant(effect, caster, targets)
    selectedTargetNumber = -1
    selectedTarget = noone
    battleState = BattleStates.AfterPlayChecks
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

// Находится ли цель в состоянии, к которому она слаба?
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
    var cardMult = is_method(effect.value) ? effect.value() : effect.value

    // Характеристика кастера + баффы/дебаффы атаки
    // Итоговый урон = характеристика * множитель карты
    var stat, atkModifier
    if (damageType == DamageTypes.Physical) {
        stat = caster.strength
        atkModifier = ModifiersToBuff.PhysicalDamage
    } else {
        stat = caster.intelligence
        atkModifier = ModifiersToBuff.MagicalDamage
    }
    var atkBuff   = checkIfHasBuff(caster, EffectTypes.Buff,   atkModifier)
    var atkDebuff = checkIfHasBuff(caster, EffectTypes.Debuff, atkModifier)
    if (atkBuff   != undefined) stat += atkBuff.value
    if (atkDebuff != undefined) stat -= atkDebuff.value
    stat = max(stat, 0)

    var damage = cardMult * stat

    // Ослабление кастера
    if (checkIfHasEffectType(caster, EffectTypes.Weakening)) damage *= 0.9

    // Модификация на стороне ЦЕЛИ: защита (+ баффы/дебаффы), слабости/сопротивления
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

    // Защита цели + баффы/дебаффы защиты + заморозка как дебафф физ. защиты
    var def, protModifier
    if (damageType == DamageTypes.Magical) {
        def = target.aura
        protModifier = ModifiersToBuff.MagicalProtection
    } else {
        def = target.guts
        protModifier = ModifiersToBuff.PhysicalProtection
    }
    var protBuff   = checkIfHasBuff(target, EffectTypes.Buff,   protModifier)
    var protDebuff = checkIfHasBuff(target, EffectTypes.Debuff, protModifier)
    if (protBuff   != undefined) def += protBuff.value
    if (protDebuff != undefined) def -= protDebuff.value
    damage -= max(def, 0)

    // Слабые места и ослабление как процентные модификаторы урона
    if (checkIfHasEffectType(target, EffectTypes.Weakening)) modifier += 0.1
    // Слабые места: сила (−); слабость к стихии входящего эффекта (+);
    // и доп. урон, пока цель В СОСТОЯНИИ, к которому слаба (+).
    if (checkIfHasStrengths(target, effect))  modifier -= WEAKNESS_DAMAGE_MODIFIER
    if (checkIfHasWeaknesses(target, effect)) modifier += WEAKNESS_DAMAGE_MODIFIER
    if (checkIfWeakStateActive(target))       modifier += WEAKNESS_DAMAGE_MODIFIER

    damage += damage * modifier
    return max(round(damage), 1)
}
