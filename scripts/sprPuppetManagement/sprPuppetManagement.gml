//// Спавн Марионеток 

function countAlivePuppetsIn(team) {
    var aliveCount = 0;
    for (var memberIndex = 0; memberIndex < array_length(team); memberIndex++)
        if (team[memberIndex].isPuppet && !team[memberIndex].isKO()) { aliveCount++; }
    return aliveCount;
}

function puppetSpritesForCategory(category) {
    switch (category) {
        case CardCategory.Attack: return { idle: scrWarriorPuppetIdle, attack: sprWarriorPuppetAttack, spell: scrWarriorPuppetIdle, cast: scrWarriorPuppetIdle, ko: scrWarriorPuppetIdle, dance: noone }
        case CardCategory.Magic: return { idle: scrWizardPuppetIIdle, attack: scrWizardPuppetIIdle,   spell: sprWizardPuppetSpell,  cast: sprWizardPuppetCast,    ko: scrWizardPuppetIIdle,   dance: noone }
        case CardCategory.Heal: return { idle: scrHealerPuppetIdle, attack: scrHealerPuppetIdle,    spell: scrHealerPuppetIdle,   cast: sprHealerPuppetHeal,    ko: scrHealerPuppetIdle,    dance: noone }
        case CardCategory.Buff: return { idle: sprPriestPuppetIdle, attack: sprPriestPuppetIdle,    spell: sprPriestPuppetIdle,   cast: sprPriestPuppetIdle,    ko: sprPriestPuppetIdle,    dance: noone }
    }
}

// Спрайт-эффект появления марионетки по её категории
function puppetSpawnSprite(category) {
    switch (category) {
        case CardCategory.Attack: return WarriotPuppetSpawn
        case CardCategory.Magic: return WizardPuppetSpawn
        case CardCategory.Heal: return HealerPuppetSpawn
        case CardCategory.Buff: return PriestPuppetSpawn
    }
    return noone
}

function puppetDeckForCategory(category) {
    var cardIds = global.CardId
    var ids = []
    switch (category) {
        case CardCategory.Attack: 
            ids = [cardIds.physicalDamageSingleTarget, cardIds.physicalDamageStunChanceSingleTarget]
        break
        case CardCategory.Magic: 
            ids = [cardIds.magicalDamageSingleTarget, cardIds.magicalDamageBurnChanceSingleTarget]
        break
        case CardCategory.Heal:   
            ids = [cardIds.instantHealSingleTarget, cardIds.overtimeHealSingleTarget]     
        break
        case CardCategory.Buff:   
            ids = [cardIds.buffPhysicalDamageSingleTarget, cardIds.buffMagicalDamageSingleTarget]
        break
    }
    var deck = []
    for (var idIndex = 0; idIndex < array_length(ids); idIndex++)
        array_push(deck, cardFromRef({ id: ids[idIndex], rarity: CardsRarity.Default }))
    return deck
}

// Карта призывает марионетку
function cardSummonsPuppet(card) {
    for (var effectIndex = 0; effectIndex < array_length(card.effects); effectIndex++) {
        var effect = card.effects[effectIndex]
        if (variable_struct_exists(effect, "type") && effect.type == EffectTypes.CreatePuppet) { return true }
    }
    return false
}

function canSpawnPuppetFor(caster) {
    var team = caster.isEnemy ? enemies : heroes
    return countAlivePuppetsIn(team) < MAX_PUPPETS
}

function spawnPuppet(category, caster) {
    var enemySide = caster.isEnemy
    var team      = enemySide ? enemies : heroes
    if (!canSpawnPuppetFor(caster)) { return }

    var sprites = puppetSpritesForCategory(category)
    var puppet = createStarrior(
        "Puppet",
        sprites.idle, sprites.attack, sprites.spell, sprites.cast, sprites.ko, sprites.dance,
        8, 8,  0, 0,  1, 1,  /*str*/2, /*int*/2, /*aura*/0, /*guts*/0,
        puppetDeckForCategory(category)
    );
    puppet.isPuppet = true
    puppet.isEnemy = enemySide
    puppet.puppetCategory = category
    puppet.justSummoned   = true
    puppet.image_xscale   = enemySide ? 1 : -1 // спрайты марионеток нарисованы лицом влево - у героев зеркалим
    array_push(team, puppet)
    array_push(playOrder, puppet)
    shuffleDeckAndTake4(puppet)

    initStarriorsPositions(posZoneHeight, posScreenWidth, posSpacing)

    var spawnSprite = puppetSpawnSprite(category)
    if (spawnSprite != noone) {
        puppet.spriteActionSpawn = spawnSprite
        puppet.changeActionState(StarriorStates.Spawn, undefined)
    }
}

//// Логика ходов Марионеток

function isSingleTargetCard(card) {
    return card.target != TargetTypes.AllEnemies && card.target != TargetTypes.AllAllies
}

function puppetTargetsEnemies(category) {
    return (category == CardCategory.Attack || category == CardCategory.Magic)
}

function aliveOf(members) {
    var alive = []
    for (var memberIndex = 0; memberIndex < array_length(members); memberIndex++) if (!members[memberIndex].isKO()) { array_push(alive, members[memberIndex]) }
    return alive
}

function runPuppetTurn(puppet) {
    if (puppet.justSummoned) {
        puppet.justSummoned = false
        skipTurn()
        return
    }

    if (array_length(puppet.getCardsInHand()) == 0) {
        shuffleDeckAndTake4(puppet)
    }

    var hand = puppet.getCardsInHand()
    var playable = []
    for (var index = 0; index < array_length(hand); index++) {
        var candidateCard = hand[index]
        if (isSingleTargetCard(candidateCard) && checkIfCanPlayCard(puppet, candidateCard)) { array_push(playable, candidateCard) }
    }

    if (array_length(playable) == 0) {
        skipTurn()
        return
    }

    var allies = aliveOf(puppet.isEnemy ? enemies : heroes)   // союзники марионетки
    var foes   = aliveOf(puppet.isEnemy ? heroes : enemies)   // противники марионетки

    // Категоризируем играбельные карты: первый хил / бафф / атака
    var healChoice = noone, buffChoice = noone, attackChoice = noone
    for (var index = 0; index < array_length(playable); index++) {
        var candidateCard = playable[index]
        switch (cardCategoryOf(candidateCard)) {
            case CardCategory.Heal: if (healChoice == noone) { healChoice = candidateCard; } break
            case CardCategory.Buff: if (buffChoice == noone) { buffChoice = candidateCard; } break
            case CardCategory.Attack:
            case CardCategory.Magic: if (attackChoice == noone) { attackChoice = candidateCard; } break
        }
    }

    // Самый раненый союзник (для хила)
    var woundedAlly = noone
    var lowestHp = 999999
    for (var index = 0; index < array_length(allies); index++) {
        var ally = allies[index]
        if (ally.hp < ally.maxHp && ally.hp < lowestHp) { lowestHp = ally.hp; woundedAlly = ally }
    }

    var card = noone
    var target = noone

    // Лечим самого раненого союзника
    if (healChoice != noone && woundedAlly != noone) {
        target = enemyResolveTarget(healChoice, puppet, foes, allies, woundedAlly, noone)
        if (target != noone) { card = healChoice }
    }

    // Баффаем союзника, у которого ещё нет этого модификатора (сначала других, себя - в последнюю очередь)
    if (card == noone && buffChoice != noone) {
        var firstEffect = buffChoice.effects[0]
        var buffTarget = noone
        for (var index = 0; index < array_length(allies) && buffTarget == noone; index++) {
            var ally = allies[index]
            if (ally == puppet) { continue }
            if (variable_struct_exists(firstEffect, "buffType") && !is_undefined(checkIfHasBuff(ally, EffectTypes.Buff, firstEffect.buffType))) { continue }
            buffTarget = ally
        }
        if (buffTarget == noone) {
            var selfBuffed = variable_struct_exists(firstEffect, "buffType") && !is_undefined(checkIfHasBuff(puppet, EffectTypes.Buff, firstEffect.buffType))
            if (!selfBuffed) { buffTarget = puppet }
        }
        if (buffTarget != noone) {
            target = enemyResolveTarget(buffChoice, puppet, foes, allies, buffTarget, noone)
            if (target != noone) { card = buffChoice }
        }
    }

    // Атакуем
    if (card == noone && attackChoice != noone) {
        target = enemyResolveTarget(attackChoice, puppet, foes, allies, noone, noone)
        if (target != noone) { card = attackChoice }
    }

    // Если не получилось, случайная играбельная карта
    if (card == noone) {
        card = playable[irandom(array_length(playable) - 1)]
        target = enemyResolveTarget(card, puppet, foes, allies, woundedAlly, noone)
        if (target == noone) {
            skipTurn()
            return
        }
    }

    playCard(card, puppet, target)
}