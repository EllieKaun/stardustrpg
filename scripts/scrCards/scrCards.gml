// Геометрия иллюстрации карты (оригинальный размер и поле под текст)
#macro CARD_ART_W 387
#macro CARD_ART_H 554
#macro CARD_TEXT_X 60
#macro CARD_TEXT_Y 375
#macro CARD_TEXT_W 258 // 318 - 60
#macro CARD_TEXT_H 125 // 500 - 375

function Card(name,
            rarity,
            target,
            actionType,
            energy,
            effects,
            cardBaseSpr,
            cardIllustrationSpr,
            cardBorderSpr,
            cardTokenSpr,
            description = "",
            cardAlbumSpr = noone) constructor {
    self.name = name
    self.rarity = rarity
    self.target = target
    self.effects = effects
    self.actionType = actionType
    self.cardBaseSpr = cardBaseSpr
    self.cardIllustrationSpr = cardIllustrationSpr
    self.cardBorderSpr = cardBorderSpr
    self.cardTokenSpr = cardTokenSpr
    self.description = description // текст на карте
    self.cardAlbumSpr = cardAlbumSpr
    self.energy = energy

    self.costTypeCached  = (actionType == StarriorStates.Attack) ? CostType.Health : CostType.Mana
  
    self.cardTokenSpr = (self.costTypeCached == CostType.Health) ? hpCostToken : mpCostToken
    self.costValueCached = computeCardCost(rarity, effects)
    if (self.costTypeCached == CostType.Mana) { self.costValueCached *= CARD_MANA_COST_MULTIPLIER }
    self.costType  = function() { return self.costTypeCached }
    self.costValue = function() { return self.costValueCached }
}

// Стоимость карты по её первому эффекту и редкости (кэшируется в costValueCached)
function computeCardCost(rarity, effects) {
    var effectsCount = array_length(effects)
    if (effectsCount == 0) { return 0 }

    var costs = cardBalance().cost
    var effect = effects[0]
    var effectType = variable_struct_exists(effect, "type") ? effect.type : undefined
    if (effectType == EffectTypes.Damage && effect.damageType == DamageTypes.Physical) {
        return (effectsCount > 1) ? costs.physicalMulti[rarity] : costs.physicalSingle[rarity]
    } else if (effectType == EffectTypes.Damage && effect.damageType == DamageTypes.Magical) {
        return costs.magical[rarity]
    } else if (effectType == EffectTypes.Heal && effect.timing == Timing.Instant) {
        return costs.instantHeal[rarity]
    } else if (effectType == EffectTypes.Heal && effect.timing == Timing.EndOfTurn) {
        return costs.overtimeHeal[rarity]
    } else {
        return costs.other[rarity]
    }
}

// Множитель к характеристике (сила/интеллект) для мгновенного урона карты
// по редкости и типу цели
function getDamageMultiplierOnRarityAndTarget(rarity, target) {
    var b = cardBalance()
    return (target == TargetTypes.SingleEnemyTarget) ? b.damageMulSingle[rarity] : b.damageMulGroup[rarity]
}

// Мгновенное лечение по редкости
function getInstantHealValueOnRarity(rarity) { return cardBalance().instantHeal[rarity] }

// Постепенное лечение по редкости
function getOvertimeHealValueOnRarity(rarity) { return cardBalance().overtimeHeal[rarity] }

// Длительность постепенного лечения по редкости
function getOvertimeHealDurationOnRarity(rarity) { return cardBalance().overtimeHealDur[rarity] }

// Мгновенное восстановление маны по редкости
function getInstantManaValueOnRarity(rarity) { return cardBalance().instantMana[rarity] }

// Постепенное восстановление маны по редкости за ход
function getOvertimeManaValueOnRarity(rarity) { return cardBalance().overtimeMana[rarity] }

// Длительность постепенного восстановления маны
function getOvertimeManaDurationOnRarity(rarity) { return cardBalance().overtimeManaDur[rarity] }

// Величина усиления/снижения характеристики по редкости
function getBuffValueOnRarity(rarity) { return cardBalance().buff[rarity] }

// Есть ли у карты эффект воскрешения
function cardIsResurrection(card) {
    for (var effectIndex = 0; effectIndex < array_length(card.effects); effectIndex++) {
        var effect = card.effects[effectIndex]
        if (variable_struct_exists(effect, "type") && effect.type == EffectTypes.Resurrection) {
            return true
        }
    }
    return false
}

function checkIfCanPlayCard(caster, card) {
    // Воскрешение: нужен хотя бы один павший (не-кукла) союзник
    if (cardIsResurrection(card)) {
        var team = caster.isEnemy ? enemies : heroes
        var hasKO = false
        for (var memberIndex = 0; memberIndex < array_length(team); memberIndex++)
            if (!team[memberIndex].isPuppet && team[memberIndex].isKO()) { hasKO = true; break }
        if (!hasKO) { 
            return false
        }
    }

    // Марионетку не призвать, если команда уже держит максимум
    if (cardSummonsPuppet(card) && !canSpawnPuppetFor(caster)) {
        return false
    }

    if (caster.isEnemy){ 
        return true // враги играют бесплатно
    }

    if (card.costType() == CostType.Mana) {
        if (caster.maxMana <= 0) { 
            return true
        }
        return caster.mana >= card.costValue()
    } else {
        return caster.hp > card.costValue() // нельзя уйти в 0 HP от стоимости
    }
}

function applyCost(caster, card) {
    if (caster.isEnemy) {
        return // враги играют бесплатно 
    }

    if (card.costType() == CostType.Mana) {
        if (caster.maxMana <= 0) { return }
        caster.mana = caster.mana - card.costValue()
    } else {
        caster.hp = caster.hp - card.costValue()
        if (caster.hp <= 0 && caster.actionState != StarriorStates.KnockOut) {
            caster.changeActionState(StarriorStates.KnockOut, undefined)
        }
    }
}

// Розыгрыш карты как последовательность действий
// 1) каст-анимация (эффекты срабатывают по её концу)
// 2) применение эффектов
// 3) проверки после розыгрыша
function cardPlaySequence(card, caster, targets) {
    return [
        {
            start: function(ctx) {
                with (Battle) {
                    var caster = ctx.caster
                    applyCost(caster, ctx.card)
                    if (checkIfHasEffectType(caster, EffectTypes.CopyCard)) {
                        copyNextCard = true
                        reduceOrRemoveEffectType(caster, EffectTypes.CopyCard)
                    }
                    removeCardFromHand(caster, ctx.card)
                    ctx.animEnded = false
                    caster.changeActionState(
                        cardAnimState(ctx.card),
                        method(ctx, function() { self.animEnded = true }),
                        cardCastSpriteOverride(ctx.card, caster)
                    )
                }
            },
            update: function(ctx) { return ctx.animEnded }
        },
        {
            start: function(ctx) {
                with (Battle) {
                    var effects = ctx.card.effects
                    for (var effectIndex = 0; effectIndex < array_length(effects); effectIndex++) {
                        var effect = effects[effectIndex]
                        switch (effect.timing) {
                            case Timing.Instant:
                                executeEffect(effect, ctx.caster, ctx.targets)
                            break
                            case Timing.EndOfTurn:
                                effectApplyStatus(effect, ctx.caster, ctx.targets)
                            break
                            case Timing.Overtime:
                                effectApplyStatus(effect, ctx.caster, ctx.targets)
                            break
                            case Timing.OnActions:
                                runOnPlay(effect, ctx.caster, ctx.targets)
                                ctx.targets.showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
                            break
                        }
                    }
                    ctx.caster.energy -= ctx.card.energy
                    if (copyNextCard) {
                        copyNextCard = false
                        array_push(ctx.caster.deck.cardsInHand, ctx.card)
                    }
                }
            }
        },
        {
            start: function(ctx) { with (Battle) { afterPlayChecks() } }
        }
    ]
}

function playCard(card, caster, targets) {
    // аналитика
    if (!caster.isEnemy && !caster.isPuppet) {
        var _cid = variable_struct_exists(card, "cardId") ? card.cardId : card.name
        analyticsPlayCard(_cid, card.rarity, caster.name)
    }
    var runner = new SequenceRunner()
    runner.play(cardPlaySequence(card, caster, targets), {
        card: card, caster: caster, targets: targets, animEnded: false
    })
    array_push(actionsQueue, runner)
}

// Конец хода. Для каждого EndOfTurn-эффекта вызываем onEndOfTurn его обработчика
function executeEndOfTurn(character) {
    var effects = character.effects
    for(var effectIndex = array_length(effects) - 1; effectIndex >= 0; effectIndex--) {
        var effect = effects[effectIndex]
        if (effect.timing != Timing.EndOfTurn) { continue }
        var handler = effectHandler(effect)
        if (effectHasHook(handler, "onEndOfTurn")) {
            handler.onEndOfTurn(effect, character)
            character.showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
            if (variable_instance_exists(effect, "duration")) {
                effect.duration -= 1
                if (effect.duration <= 0) { array_delete(effects, effectIndex, 1) }
            }
        }
    }
}

// Копия эффекта
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

    // Ослабление кастера
    if (checkIfHasEffectType(caster, EffectTypes.Weakening)) { damage *= 0.9 }

    // Модификация на стороне ЦЕЛИ: защита (+ баффы и дебаффы), слабости и сопротивления
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
