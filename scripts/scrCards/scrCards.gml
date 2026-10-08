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
    // Рамка по редкости
    self.cardBorderSpr = cardBorderForRarity(rarity)
    self.costValueCached = computeCardCost(rarity, effects)
    if (self.costTypeCached == CostType.Mana) { self.costValueCached *= CARD_MANA_COST_MULTIPLIER }
    self.costType  = function() { return self.costTypeCached }
    self.costValue = function() { return self.costValueCached }
}

// Рамка карты по редкости
function cardBorderForRarity(rarity) {
    switch (rarity) {
        case CardsRarity.Unusual: return uncommonBorder
        case CardsRarity.Rare: return rareBorder
        case CardsRarity.Epic: return epicBorder
        default: return commonBorder
    }
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
    var balance = cardBalance()
    return (target == TargetTypes.SingleEnemyTarget) ? balance.damageMulSingle[rarity] : balance.damageMulGroup[rarity]
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
function showCardEffectVisuals(effects, targets) {
    for (var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        var dismiss = (variable_struct_exists(effect, "timing") && effect.timing == Timing.Instant
                    && variable_struct_exists(effect, "type") && effect.type == EffectTypes.Damage)
                    ? EffectVisualizerType.AnimationEnd : EffectVisualizerType.TimeBased
        if (is_array(targets)) {
            for (var t = 0; t < array_length(targets); t++) {
                if (!targets[t].isKO()) { targets[t].showEffectNotification(effect, dismiss, 1) }
            }
        } else {
            targets.showEffectNotification(effect, dismiss, 1)
        }
    }
}

function cardEffectAnimFrames(effects) {
    var frames = 0
    for (var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        if (variable_struct_exists(effect, "sprite") && effect.sprite != noone) {
            frames = max(frames, spritePlayFrames(effect.sprite))
        }
    }
    return frames
}

function cardPlaySequence(card, caster, targets) {
    return [
        // 1) разыгрывание карты
        stepDo(function(ctx) {
            with (Battle) {
                applyCost(ctx.caster, ctx.card)
                if (checkIfHasEffectType(ctx.caster, EffectTypes.CopyCard)) {
                    copyNextCard = true
                    reduceOrRemoveEffectType(ctx.caster, EffectTypes.CopyCard)
                }
                removeCardFromHand(ctx.caster, ctx.card)
            }
        }),

        // 2) анимация кастера
        stepActorAnim(caster, cardAnimState(card), cardCastSpriteOverride(card, caster)),

        // 3) анимация эффектов
        stepDo(function(ctx) {
            with (Battle) { showCardEffectVisuals(ctx.card.effects, ctx.targets) }
        }),
        stepWait(cardEffectAnimFrames(card.effects)),

        // 4) применение значений
        stepDo(function(ctx) {
            with (Battle) {
                global.suppressEffectVisual = true
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
                        break
                    }
                }
                ctx.caster.energy -= ctx.card.energy
                if (copyNextCard) {
                    copyNextCard = false
                    array_push(ctx.caster.deck.cardsInHand, ctx.card)
                }
                global.suppressEffectVisual = false
            }
        }),

        // 5) пауза — дождаться просадки хп до перехода
        stepWaitBars(targets),

        // 6) проверки после розыгрыша
        stepDo(function(ctx) { with (Battle) { afterPlayChecks() } })
    ]
}

function playCard(card, caster, targets) {
    // аналитика
    if (!caster.isEnemy && !caster.isPuppet) {
        var playedCardId = variable_struct_exists(card, "cardId") ? card.cardId : card.name
        analyticsPlayCard(playedCardId, card.rarity, caster.name)
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

