// ============================================================
//  СИСТЕМА ЭФФЕКТОВ (data-driven)
//
//  Поведение каждого эффекта живёт в реестре global.effectRegistry:
//  ключ ("kind") -> структура с хуками жизненного цикла.
//
//  Движок НЕ делает switch по типу эффекта. Он находит обработчик и
//  вызывает нужный хук в зависимости от тайминга:
//    onInstant(effect, caster, targets)  — Timing.Instant
//    onPlay(effect, caster, targets)     — Timing.OnActions (мгновенно)
//    onEndOfTurn(effect, character)      — Timing.EndOfTurn (тик в конце хода)
//    onApply(effect, caster, target)     — в момент наложения статуса
//    iconFor(effect) / icon              — иконка статуса
//
//  Пассивные модификаторы (Buff/Debuff/Stun/Weakening/IgnoreWeakness/
//  CreateTemporaryWeakness) не имеют активного хука — они просто лежат
//  на цели как данные, а боевые расчёты их опрашивают (checkIfHasBuff,
//  mitigateDamage, beginTurnFor и т.д.).
//
//  Добавить новый эффект = добавить ОДНУ запись в initEffectRegistry().
//  Никаких правок в executeEffect / executeEndOfTurn / statusIconFor.
//
//  initEffectRegistry() вызывается один раз в Battle → Create.
// ============================================================

function initEffectRegistry() {
    var R = {}

    // --- Урон: мгновенный (атаки) и по времени (Burn/Bleeding). ---
    variable_struct_set(R, "Damage", {
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

    // --- Лечение: мгновенное и по времени. ---
    variable_struct_set(R, "Heal", {
        onInstant: function(effect, caster, targets) { executeHealing(effect, caster, targets) },
        onEndOfTurn: function(effect, character) { character.applyHeal(effect.value) },
    })

    // --- Восстановление маны: мгновенное и по времени. ---
    variable_struct_set(R, "ManaGain", {
        onInstant: function(effect, caster, targets) { executeManaGain(effect, caster, targets) },
        onEndOfTurn: function(effect, character) { character.mana += effect.value },
    })

    // --- Снятие статуса. ---
    variable_struct_set(R, "RemoveEffect", {
        onInstant: function(effect, caster, targets) { executeRemoveStatus(targets, effect.statusName) },
    })

    // --- Воскрешение: восстанавливает половину максимального HP. ---
    variable_struct_set(R, "Resurrection", {
        onInstant: function(effect, caster, targets) {
            if (targets.isPuppet) return
            effect.value = targets.maxHp / 2
            executeHealing(effect, caster, targets)
        },
    })

    // --- Мгновенные эффекты OnActions. ---
    variable_struct_set(R, "AddEnergy", {
        onPlay: function(effect, caster, targets) { targets.energy += effect.value },
    })
    variable_struct_set(R, "CopyCard", {
        // Сама копия обрабатывается в playCard (флаг copyNextCard) — здесь noop.
        onPlay: function(effect, caster, targets) {},
    })
    variable_struct_set(R, "ShuffleDeck", {
        // with(Battle): хук — метод структуры (self=структура), а selectedCharacter —
        // переменная контроллера Battle. with переключает self на контроллер.
        onPlay: function(effect, caster, targets) {
            with (Battle) { shuffleDeckAndTake4(selectedCharacter) }
        },
    })
    variable_struct_set(R, "CreatePuppet", {
        onPlay: function(effect, caster, targets) {
            with (Battle) { spawnPuppet(effect.puppetCategory, caster) }
        },
    })

    // --- BossClone: ЭКСКЛЮЗИВНАЯ карта. Клонирует кастера во все
    //     свободные слоты его команды. Вся уникальная логика — здесь. ---
    variable_struct_set(R, "BossClone", {
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

    // --- Пассивные модификаторы: только иконка (поведение читают расчёты). ---
    variable_struct_set(R, "Buff",   { iconFor: function(e) { return buffIcon(e, true) } })
    variable_struct_set(R, "Debuff", { iconFor: function(e) { return buffIcon(e, false) } })
    variable_struct_set(R, "Stun",                    { icon: noone })
    variable_struct_set(R, "Weakening",               { icon: noone })
    variable_struct_set(R, "IgnoreWeakness",          { icon: noone })
    variable_struct_set(R, "CreateTemporaryWeakness", { icon: noone })

    global.effectRegistry = R
}

// ------------------------------------------------------------
//  Поиск обработчика
// ------------------------------------------------------------

// Ключ реестра для эффекта: явный effect.kind или производный от type.
function effectKind(effect) {
    if (variable_instance_exists(effect, "kind")) return effect.kind
    if (!variable_instance_exists(effect, "type")) return undefined
    return effectKindFromType(effect.type)
}

// EffectTypes -> строковый ключ реестра (без пробелов, в отличие от
// effectTypeToString, который для UI).
function effectKindFromType(type) {
    switch (type) {
        case EffectTypes.Damage:                  return "Damage"
        case EffectTypes.Heal:                    return "Heal"
        case EffectTypes.Stun:                    return "Stun"
        case EffectTypes.Buff:                    return "Buff"
        case EffectTypes.RemoveEffect:            return "RemoveEffect"
        case EffectTypes.ManaGain:                return "ManaGain"
        case EffectTypes.Weakening:               return "Weakening"
        case EffectTypes.Debuff:                  return "Debuff"
        case EffectTypes.CopyCard:                return "CopyCard"
        case EffectTypes.AddEnergy:               return "AddEnergy"
        case EffectTypes.ShuffleDeck:             return "ShuffleDeck"
        case EffectTypes.Resurrection:            return "Resurrection"
        case EffectTypes.IgnoreWeakness:          return "IgnoreWeakness"
        case EffectTypes.CreateTemporaryWeakness: return "CreateTemporaryWeakness"
        case EffectTypes.CreatePuppet:            return "CreatePuppet"
        default:                                  return undefined
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

// ------------------------------------------------------------
//  Обобщённый запуск хуков (вызывается из тех же мест, что старые switch).
// ------------------------------------------------------------

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

// ------------------------------------------------------------
//  Иконки статусов (заменяет statusIconFor). Приоритет — как раньше:
//  сначала statusName, затем buffType (через iconFor обработчика).
// ------------------------------------------------------------

function statusNameIcon(effect) {
    if (!variable_instance_exists(effect, "statusName")) return noone
    switch (effect.statusName) {
        case StatusNames.Stun:     return StunIcon
        case StatusNames.Burn:     return BurnIcon
        case StatusNames.Bleeding: return BleedIcon
        case StatusNames.Freeze:   return FreezeIcon
        case StatusNames.Shock:    return ShockIcon
    }
    return noone
}

function buffIcon(effect, isBuff) {
    if (!variable_instance_exists(effect, "buffType")) return noone
    switch (effect.buffType) {
        case ModifiersToBuff.PhysicalDamage:     return isBuff ? StrBuff104 : StrDebuff
        case ModifiersToBuff.MagicalDamage:      return isBuff ? MagicBuff107 : MagicDebuff
        case ModifiersToBuff.PhysicalProtection: return isBuff ? GutsBuff : GutsDebuff
    }
    return noone
}

function effectIcon(effect) {
    var s = statusNameIcon(effect)
    if (s != noone) return s
    var h = effectHandler(effect)
    if (effectHasHook(h, "iconFor")) return h.iconFor(effect)
    if (effectHasHook(h, "icon"))    return h.icon
    return noone
}

// ------------------------------------------------------------
//  Помощники BossClone
// ------------------------------------------------------------

function countAliveOn(team) {
    var n = 0
    for (var i = 0; i < array_length(team); i++) if (!team[i].isKO()) n++
    return n
}

// Клон кастера: те же спрайты/статы/колода. isPuppet=true, чтобы
// removeDeadPuppets корректно убирал клонов при гибели.
function cloneStarrior(src) {
    var clone = createStarrior(
        src.name,
        src.spriteActionIdle, src.spriteActionAttack, src.spriteActionCast, src.spriteActionKO,
        src.maxHp, src.maxHp,  src.maxMana, src.maxMana,  src.maxEnergy, src.maxEnergy,
        src.strength, src.intelligence, src.aura, src.guts,
        cloneDeckFrom(src)
    )
    clone.isEnemy      = src.isEnemy
    clone.isPuppet     = true
    clone.justSummoned = true
    return clone
}

function cloneDeckFrom(src) {
    var deck = []
    var origin = src.getOriginalDeck()
    for (var i = 0; i < array_length(origin); i++) array_push(deck, origin[i])
    return deck
}

// ------------------------------------------------------------
//  Конструкторы эффектов (сахар; фабрики могут переходить постепенно).
// ------------------------------------------------------------

// --- Урон ---
// Мгновенная атака. value — число или функция (бросок кубика).
function DamageEffect(damageType, value) {
    return { type: EffectTypes.Damage, damageType: damageType, value: value,
             timing: Timing.Instant, sprite: attackEffect }
}
// Урон по времени со статусом (Burn, Bleeding).
function DamageOverTimeEffect(damageType, value, duration, statusName, chance) {
    return { type: EffectTypes.Damage, damageType: damageType, value: value,
             duration: duration, statusName: statusName, chance: chance,
             timing: Timing.EndOfTurn }
}
// Статус-эффект вторым эффектом карты (Stun/Weakening). Без спрайта —
// иконка берётся по statusName. timing задаём явно (в исходных картах он
// различается). Без спрайта, как в оригинале.
function StatusEffect(effectType, statusName, duration, chance, timing) {
    return { type: effectType, statusName: statusName, duration: duration,
             chance: chance, timing: timing }
}
function StunEffect(duration, chance) {
    return StatusEffect(EffectTypes.Stun, StatusNames.Stun, duration, chance, Timing.Overtime)
}
// timing оставлен параметром: в исходных картах одиночная слабость Overtime,
// групповая — EndOfTurn (сохраняем как было).
function WeakeningEffect(duration, chance, timing) {
    return StatusEffect(EffectTypes.Weakening, StatusNames.Weakening, duration, chance, timing)
}
// Взрыв: ещё один мгновенный удар (statusName Bomb — декоративный). Без спрайта.
function BombEffect(damageType, value, chance) {
    return { type: EffectTypes.Damage, damageType: damageType, value: value,
             chance: chance, statusName: StatusNames.Bomb, timing: Timing.Instant }
}
// Заморозка: дебафф физ. защиты + statusName Freeze (для иконки).
// value добавлено намеренно (в оригинале его не было -> чтение .value в
// mitigateDamage падало). 0.3 => замороженный получает +30% физ. урона.
function FreezeEffect(duration, chance) {
    return { type: EffectTypes.Debuff, buffType: ModifiersToBuff.PhysicalProtection,
             value: 0.3, statusName: StatusNames.Freeze, duration: duration,
             chance: chance, timing: Timing.Overtime }
}
// Вампиризм: полноценный урон + statusName Vampirism + chance (лечит кастера
// в executeDamageEffect).
function VampirismEffect(damageType, value, chance) {
    return { type: EffectTypes.Damage, damageType: damageType, value: value,
             statusName: StatusNames.Vampirism, chance: chance,
             timing: Timing.Instant, sprite: attackEffect }
}

function Burn(value, duration, chance) {
    return DamageOverTimeEffect(DamageTypes.Magical, value, duration, StatusNames.Burn, chance)
}
function Bleeding(value, duration, chance) {
    return DamageOverTimeEffect(DamageTypes.Physical, value, duration, StatusNames.Bleeding, chance)
}

// --- Лечение / мана ---
function HealEffect(value) {
    return { type: EffectTypes.Heal, value: value, timing: Timing.Instant, sprite: hphealEffect }
}
function HealOverTimeEffect(value, duration) {
    return { type: EffectTypes.Heal, value: value, duration: duration,
             timing: Timing.EndOfTurn, sprite: hphealEffect }
}
function ManaGainEffect(value) {
    return { type: EffectTypes.ManaGain, value: value, timing: Timing.Instant, sprite: mphealEffect }
}
function ManaGainOverTimeEffect(value, duration) {
    return { type: EffectTypes.ManaGain, value: value, duration: duration,
             timing: Timing.EndOfTurn, sprite: mphealEffect }
}

// --- Баффы / дебаффы (модификатор атаки или защиты) ---
function BuffEffect(modifier, value, duration) {
    return { type: EffectTypes.Buff, buffType: modifier, value: value,
             duration: duration, timing: Timing.Overtime, sprite: buffEffect }
}
function DebuffEffect(modifier, value, duration) {
    return { type: EffectTypes.Debuff, buffType: modifier, value: value,
             duration: duration, timing: Timing.Overtime, sprite: debuffEffect }
}
function TemporaryWeaknessEffect(weakness, duration) {
    return { type: EffectTypes.CreateTemporaryWeakness, weakness: weakness,
             duration: duration, timing: Timing.Overtime, sprite: debuffEffect }
}

// --- Прочее ---
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
