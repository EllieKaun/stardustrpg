// Эффекта
// Поведение каждого эффекта хранится в репо эффектов
// Карты состоят из набора эффектов
// "kind": { структура с хуками жизненного цикла }
// Проигрывание находит обработчик и
// вызывает нужный хук в зависимости от тайминга:
// onInstant(effect, caster, targets) — Timing.Instant (мгновенно)
// onPlay(effect, caster, targets) — Timing.OnActions (по выпронению какого-либо действия)
// onEndOfTurn(effect, character) — Timing.EndOfTurn (тик в конце хода)
// onApply(effect, caster, target) — в момент наложения статуса
// iconFor(effect) / icon — иконка статуса
//
// Пассивные модификаторы (Buff/Debuff/Stun/Weakening/IgnoreWeakness/
// CreateTemporaryWeakness) не имеют активного хука
//
// initEffectRegistry() вызывается один раз в Battle Create

function initEffectRegistry() {
    var effectsRepository = {}

    // Урон: мгновенный (атаки) и по времени (Burn/Bleeding)
    variable_struct_set(effectsRepository, "Damage", {
        onInstant: function(effect, caster, targets) {
            if (is_array(targets)) {
                for (var i = 0; i < array_length(targets); i++)
                    if (!targets[i].isKO()) executeDamageEffect(effect, caster, targets[i])
            } else {
                if (!targets.isKO()) executeDamageEffect(effect, caster, targets)
            }
        },
        onEndOfTurn: function(effect, character) {
            var raw = is_method(effect.value) ? effect.value() : effect.value
            character.applyDamage(mitigateDamage(character, effect, raw))
        },
    })

    // Лечение: мгновенное и по времени
    variable_struct_set(effectsRepository, "Heal", {
        onInstant: function(effect, caster, targets) { executeHealing(effect, caster, targets) },
        onEndOfTurn: function(effect, character) { character.applyHeal(effect.value) },
    })

    // Восстановление маны: мгновенное и по времени 
    variable_struct_set(effectsRepository, "ManaGain", {
        onInstant: function(effect, caster, targets) { executeManaGain(effect, caster, targets) },
        onEndOfTurn: function(effect, character) { character.applyMana(effect.value) },
    })

    // Снятие статуса 
    variable_struct_set(effectsRepository, "RemoveEffect", {
        onInstant: function(effect, caster, targets) { executeRemoveStatus(targets, effect.statusName) },
    })

    // Воскрешение
    variable_struct_set(effectsRepository, "Resurrection", {
        onInstant: function(effect, caster, targets) {
            if (targets.isPuppet) return
            if (!targets.isKO()) return // воскрешают только павшего
            targets.hp = floor(targets.maxHp / 2) // поднять на половину HP
            targets.changeActionState(StarriorStates.Idle, undefined) // снять нокаут
            targets.showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
        },
    })

    // OnActions
    variable_struct_set(effectsRepository, "AddEnergy", {
        onPlay: function(effect, caster, targets) { targets.energy += effect.value },
    })
    variable_struct_set(effectsRepository, "CopyCard", {
        onPlay: function(effect, caster, targets) {},
    })
    variable_struct_set(effectsRepository, "ShuffleDeck", {
        onPlay: function(effect, caster, targets) {
            with (Battle) { shuffleDeckAndTake4(selectedCharacter) }
        },
    })
    variable_struct_set(effectsRepository, "CreatePuppet", {
        onPlay: function(effect, caster, targets) {
            with (Battle) { spawnPuppet(effect.puppetCategory, caster) }
        },
    })

    // Клоинирование
    variable_struct_set(effectsRepository, "BossClone", {
        onPlay: function(effect, caster, targets) {
            with (Battle) {
                var team = caster.isEnemy ? enemies : heroes
                var free = effect.maxSlots - countAliveOn(team)
                repeat (free) {
                    var clone = cloneStarrior(caster)
                    array_push(team, clone)
                    array_push(playOrder, clone)
                    shuffleDeckAndTake4(clone)
                }
                initStarriorsPositions(posZoneHeight, posScreenWidth, posSpacing)
            }
        },
    })

    // Кража
    variable_struct_set(effectsRepository, "Steal", {
        onInstant: function(effect, caster, targets) {
            var t = is_array(targets) ? (array_length(targets) > 0 ? targets[0] : noone) : targets
            if (t == noone) return

            if (variable_instance_exists(t, "hasSpear") && t.hasSpear) {
                t.hasSpear = false
                t.image_blend = c_white
                questGrantSpear()
            } else {
                var hand = t.getCardsInHand()
                if (array_length(hand) > 0) {
                    var picked = hand[irandom(array_length(hand) - 1)]
                    array_push(caster.deck.cardsInHand, picked)
                }
            }

            if (variable_instance_exists(t, "showEffectNotification"))
                t.showEffectNotification(effect, EffectVisualizerType.TimeBased, 1)
        },
    })

    // Модификаторы
    variable_struct_set(effectsRepository, "Buff", { iconFor: function(e) { return buffIcon(e, true) } })
    variable_struct_set(effectsRepository, "Debuff", { iconFor: function(e) { return buffIcon(e, false) } })
    variable_struct_set(effectsRepository, "Stun", { icon: noone })
    variable_struct_set(effectsRepository, "Weakening", { icon: noone })
    variable_struct_set(effectsRepository, "IgnoreWeakness", { icon: noone })
    variable_struct_set(effectsRepository, "CreateTemporaryWeakness", { icon: noone })

    global.effectRegistry = R
}

//// Поиск обработчика

// Ключ репозитория для эффекта
function effectKind(effect) {
    if (variable_instance_exists(effect, "kind")) return effect.kind
    if (!variable_instance_exists(effect, "type")) return undefined
    return effectKindFromType(effect.type)
}

// EffectTypes -> строковый ключ реестра 
function effectKindFromType(type) {
    switch (type) {
        case EffectTypes.Damage: return "Damage"
        case EffectTypes.Heal: return "Heal"
        case EffectTypes.Stun: return "Stun"
        case EffectTypes.Buff: return "Buff"
        case EffectTypes.RemoveEffect: return "RemoveEffect"
        case EffectTypes.ManaGain: return "ManaGain"
        case EffectTypes.Weakening: return "Weakening"
        case EffectTypes.Debuff: return "Debuff"
        case EffectTypes.CopyCard: return "CopyCard"
        case EffectTypes.AddEnergy: return "AddEnergy"
        case EffectTypes.ShuffleDeck: return "ShuffleDeck"
        case EffectTypes.Resurrection: return "Resurrection"
        case EffectTypes.IgnoreWeakness: return "IgnoreWeakness"
        case EffectTypes.CreateTemporaryWeakness: return "CreateTemporaryWeakness"
        case EffectTypes.CreatePuppet: return "CreatePuppet"
        default: return undefined
    }
}

function effectHandler(effect) {
    if (!variable_global_exists("effectRegistry")) return undefined
    var key = effectKind(effect)
    if (key == undefined || !variable_struct_exists(global.effectRegistry, key)) return undefined
    return variable_struct_get(global.effectRegistry, key)
}

function effectHasHook(handler, hookName) {
    return handler != undefined && variable_struct_exists(handler, hookName)
}

//// Обобщённый запуск хуков

function runInstant(effect, caster, targets) {
    var h = effectHandler(effect)
    if (effectHasHook(h, "onInstant")) h.onInstant(effect, caster, targets)
}

function runOnPlay(effect, caster, targets) {
    var h = effectHandler(effect)
    if (effectHasHook(h, "onPlay")) { h.onPlay(effect, caster, targets); return true }
    return false
}

function runOnApply(effect, caster, target) {
    var h = effectHandler(effect)
    if (effectHasHook(h, "onApply")) h.onApply(effect, caster, target)
}

//// Иконки статусов

function statusNameIcon(effect) {
    if (!variable_instance_exists(effect, "statusName")) return noone
    switch (effect.statusName) {
        case StatusNames.Stun: return StunIcon
        case StatusNames.Burn: return BurnIcon
        case StatusNames.Bleeding: return BleedIcon
        case StatusNames.Freeze: return FreezeIcon
        case StatusNames.Shock: return ShockIcon
    }
    return noone
}

// Иконка слабости по сырому значению StatusNames (для инфы о враге)
function weaknessIcon(sn) {
    switch (sn) {
        case StatusNames.Stun: return StunIcon
        case StatusNames.Burn: return BurnIcon
        case StatusNames.Bleeding: return BleedIcon
        case StatusNames.Freeze: return FreezeIcon
        case StatusNames.Shock: return ShockIcon
    }
    return noone
}

function weaknessLabel(sn) {
    switch (sn) {
        case StatusNames.Stun: return "Stun"
        case StatusNames.Burn: return "Burn"
        case StatusNames.Freeze: return "Freeze"
        case StatusNames.Bleeding: return "Bleed"
        case StatusNames.Shock: return "Shock"
        case StatusNames.Bomb: return "Bomb"
        case StatusNames.Vampirism: return "Vampirism"
        case StatusNames.Weakening: return "Weaken"
    }
    return "?"
}

function buffIcon(effect, isBuff) {
    if (!variable_instance_exists(effect, "buffType")) return noone
    switch (effect.buffType) {
        case ModifiersToBuff.PhysicalDamage: return isBuff ? StrBuffStatus : StrDebuff
        case ModifiersToBuff.MagicalDamage: return isBuff ? MagicBuffStatus : MagicDebuff
        case ModifiersToBuff.PhysicalProtection: return isBuff ? GutsBuff : GutsDebuff
    }
    return noone
}

function effectIcon(effect) {
    var s = statusNameIcon(effect)
    if (s != noone) return s
    var h = effectHandler(effect)
    if (effectHasHook(h, "iconFor")) return h.iconFor(effect)
    if (effectHasHook(h, "icon")) return h.icon
    return noone
}

//  Помощники BossClone

function countAliveOn(team) {
    var n = 0
    for (var i = 0; i < array_length(team); i++) 
        if (!team[i].isKO()) n++
    return n
}

// Клон кастера: те же спрайты/статы/колода. isPuppet=true, чтобы
// removeDeadPuppets корректно убирал клонов при гибели.
function cloneStarrior(src) {
 //   var clone = createStarrior(
 //       src.name,
 //       src.spriteActionIdle, src.spriteActionAttack, src.spriteActionCast, src.spriteActionKO,
  //      src.maxHp, src.maxHp,  src.maxMana, src.maxMana,  src.maxEnergy, src.maxEnergy,
  //      src.strength, src.intelligence, src.aura, src.guts,
  //      cloneDeckFrom(src)
  //  )
  //  clone.isEnemy = src.isEnemy
  //  clone.isPuppet = true
  //  clone.justSummoned = true
  //  return clone
}

function cloneDeckFrom(src) {
    var deck = []
    var origin = src.getOriginalDeck()
    for (var i = 0; i < array_length(origin); i++) array_push(deck, origin[i])
    return deck
}

////  Конструкторы эффектов

// Мгновенная атака
// value — число или функция 
// sprite — визуал попадания на цели,sound — звук эффекта
function DamageEffect(damageType, value, sprite = attackEffect, sound = noone) {
    return { type: EffectTypes.Damage, damageType: damageType, value: value,
             timing: Timing.Instant, sprite: sprite, sound: sound }
}
// Урон со временем времени со статусом (Burn, Bleeding)
function DamageOverTimeEffect(damageType, value, duration, statusName, chance, sprite = noone, sound = noone) {
    var e = { type: EffectTypes.Damage, damageType: damageType, value: value,
              duration: duration, statusName: statusName, chance: chance,
              timing: Timing.EndOfTurn, sound: sound }
    if (sprite != noone) e.sprite = sprite
    return e
}
// Статус-эффект вторым эффектом карты (Stun/Weakening)
function StatusEffect(effectType, statusName, duration, chance, timing) {
    return { type: effectType, statusName: statusName, duration: duration,
             chance: chance, timing: timing }
}

// Стан
function StunEffect(duration, chance) {
    return StatusEffect(EffectTypes.Stun, StatusNames.Stun, duration, chance, Timing.Overtime)
}

// Шок (от молнии)
function ShockEffect(duration, chance) {
    return StatusEffect(EffectTypes.Stun, StatusNames.Shock, duration, chance, Timing.Overtime)
}

// Ослабление
function WeakeningEffect(duration, chance, timing) {
    return StatusEffect(EffectTypes.Weakening, StatusNames.Weakening, duration, chance, timing)
}

// Взрыв: мгновенный удар (statusName Bomb)
function BombEffect(damageType, value, chance, sprite = bombEffect, sound = noone) {
    var e = { type: EffectTypes.Damage, damageType: damageType, value: value,
              chance: chance, statusName: StatusNames.Bomb, timing: Timing.Instant, sound: sound }
    if (sprite != noone) e.sprite = sprite
    return e
}

// Заморозка с дебаффом физ. защиты
function FreezeEffect(duration, chance) {
    return { type: EffectTypes.Debuff, buffType: ModifiersToBuff.PhysicalProtection,
             value: getBuffValueOnRarity(CardsRarity.Default), statusName: StatusNames.Freeze,
             duration: duration, chance: chance, timing: Timing.Overtime }
}
// Вампиризм
function VampirismEffect(damageType, value, chance, sprite = attackEffect, sound = SliceAtc) {
    return { type: EffectTypes.Damage, damageType: damageType, value: value,
             statusName: StatusNames.Vampirism, chance: chance,
             timing: Timing.Instant, sprite: sprite, sound: sound }
}

// Горение и Кровотечение
function Burn(value, duration, chance, sound = FireMagic) {
    return DamageOverTimeEffect(DamageTypes.Magical, value, duration, StatusNames.Burn, chance, flameStrike, sound)
}
function Bleeding(value, duration, chance, sound = SliceAtc) {
    return DamageOverTimeEffect(DamageTypes.Physical, value, duration, StatusNames.Bleeding, chance, slice, sound)
}

// Лечение, мана
function HealEffect(value, sprite = hphealEffect, sound = HealMagic) {
    return { type: EffectTypes.Heal, value: value, timing: Timing.Instant, sprite: sprite, sound: sound }
}
function HealOverTimeEffect(value, duration, sprite = hphealEffect, sound = HealMagic) {
    return { type: EffectTypes.Heal, value: value, duration: duration,
             timing: Timing.EndOfTurn, sprite: sprite, sound: sound }
}
function ManaGainEffect(value, sprite = mphealEffect, sound = HealMagic) {
    return { type: EffectTypes.ManaGain, value: value, timing: Timing.Instant, sprite: sprite, sound: sound }
}
function ManaGainOverTimeEffect(value, duration, sprite = mphealEffect, sound = HealMagic) {
    return { type: EffectTypes.ManaGain, value: value, duration: duration,
             timing: Timing.EndOfTurn, sprite: sprite, sound: sound }
}

// Баффы, дебаффы 
function BuffEffect(modifier, value, duration, sprite = buffEffect, sound = MagicBuff) {
    return { type: EffectTypes.Buff, buffType: modifier, value: value,
             duration: duration, timing: Timing.Overtime, sprite: sprite, sound: sound }
}
function DebuffEffect(modifier, value, duration, sprite = debuffEffect, sound = DebuffMagic) {
    return { type: EffectTypes.Debuff, buffType: modifier, value: value,
             duration: duration, timing: Timing.Overtime, sprite: sprite, sound: sound }
}
function TemporaryWeaknessEffect(weakness, duration) {
    return { type: EffectTypes.CreateTemporaryWeakness, weakness: weakness,
             duration: duration, timing: Timing.Overtime, sprite: debuffEffect }
}

// Прочее
function RemoveStatusEffect(statusName, sprite) {
    return { type: EffectTypes.RemoveEffect, statusName: statusName,
             timing: Timing.Instant, sprite: sprite }
}
function ResurrectionEffect(sprite) {
    return { type: EffectTypes.Resurrection, timing: Timing.Instant, sprite: sprite }
}
function CreatePuppetEffect(category) {
    return { type: EffectTypes.CreatePuppet, timing: Timing.OnActions, puppetCategory: category }
}
function AddEnergyEffect(value) {
    return { type: EffectTypes.AddEnergy, value: value, timing: Timing.OnActions, sprite: attackEffect }
}
function ShuffleDeckEffect() {
    return { type: EffectTypes.ShuffleDeck, timing: Timing.OnActions, sprite: attackEffect }
}
function CopyCardEffect() {
    return { type: EffectTypes.CopyCard, timing: Timing.OnActions, sprite: attackEffect }
}
function IgnoreWeaknessEffect(duration) {
    return { type: EffectTypes.IgnoreWeakness, duration: duration, timing: Timing.Overtime, sprite: attackEffect }
}

function BossClone(maxSlots) {
    return { kind: "BossClone", timing: Timing.OnActions, maxSlots: maxSlots }
}

function StealEffect() {
    return { kind: "Steal", timing: Timing.Instant, sprite: attackEffect }
}
