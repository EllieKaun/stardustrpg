//// Спавн Марионеток 

function countAlivePuppetsIn(team) {
    var n = 0;
    for (var i = 0; i < array_length(team); i++)
        if (team[i].isPuppet && !team[i].isKO()) n++;
    return n;
}

function puppetSpritesForCategory(category) {
    switch (category) {
        case CardCategory.Attack: return { idle: scrWarriorPuppetIdle, attack: sprWarriorPuppetAttack, spell: scrWarriorPuppetIdle, cast: scrWarriorPuppetIdle, ko: scrWarriorPuppetIdle, dance: noone }
        case CardCategory.Magic:  return { idle: scrWizardPuppetIIdle,  attack: scrWizardPuppetIIdle,   spell: sprWizardPuppetSpell,  cast: sprWizardPuppetCast,    ko: scrWizardPuppetIIdle,   dance: noone }
        case CardCategory.Heal:   return { idle: scrHealerPuppetIdle,   attack: scrHealerPuppetIdle,    spell: scrHealerPuppetIdle,   cast: sprHealerPuppetHeal,    ko: scrHealerPuppetIdle,    dance: noone }
        case CardCategory.Buff:   return { idle: sprPriestPuppetIdle,   attack: sprPriestPuppetIdle,    spell: sprPriestPuppetIdle,   cast: sprPriestPuppetIdle,    ko: sprPriestPuppetIdle,    dance: noone }
    }
}

// Спрайт-эффект появления марионетки по её категории
function puppetSpawnSprite(category) {
    switch (category) {
        case CardCategory.Attack: return WarriotPuppetSpawn
        case CardCategory.Magic:  return WizardPuppetSpawn
        case CardCategory.Heal:   return HealerPuppetSpawn
        case CardCategory.Buff:   return PriestPuppetSpawn
    }
    return noone
}

function puppetDeckForCategory(category) {
    var C = global.CardId
    var ids = []
    switch (category) {
        case CardCategory.Attack: 
            ids = [C.physicalDamageSingleTarget, C.physicalDamageStunChanceSingleTarget]
        break
        case CardCategory.Magic: 
            ids = [C.magicalDamageSingleTarget, C.magicalDamageBurnChanceSingleTarget]
        break
        case CardCategory.Heal:   
            ids = [C.instantHealSingleTarget, C.overtimeHealSingleTarget]     
        break
        case CardCategory.Buff:   
            ids = [C.buffPhysicalDamageSingleTarget, C.buffMagicalDamageSingleTarget]
        break
    }
    var deck = []
    for (var i = 0; i < array_length(ids); i++)
        array_push(deck, cardFromRef({ id: ids[i], rarity: CardsRarity.Default }))
    return deck
}

function spawnPuppet(category, caster) {
    var enemySide = caster.isEnemy  
    var team      = enemySide ? enemies : heroes
    if (countAlivePuppetsIn(team) >= MAX_PUPPETS) return

    var spr = puppetSpritesForCategory(category)
    var p = createStarrior(
        "Puppet",
        spr.idle, spr.attack, spr.spell, spr.cast, spr.ko, spr.dance,
        8, 8,  0, 0,  1, 1,  /*str*/2, /*int*/2, /*aura*/0, /*guts*/0,
        puppetDeckForCategory(category)
    );
    p.isPuppet = true
    p.isEnemy = enemySide
    p.puppetCategory = category
    p.justSummoned   = true
    array_push(team, p)
    array_push(playOrder, p)
    shuffleDeckAndTake4(p)

    initStarriorsPositions(posZoneHeight, posScreenWidth, posSpacing)

    var spawnSpr = puppetSpawnSprite(category)
    if (spawnSpr != noone) {
        p.spriteActionSpawn = spawnSpr
        p.changeActionState(StarriorStates.Spawn, undefined)
    }
}

//// Логика ходов Марионеток

function isSingleTargetCard(card) {
    return card.target != TargetTypes.AllEnemies && card.target != TargetTypes.AllAllies
}

function puppetTargetsEnemies(category) {
    return (category == CardCategory.Attack || category == CardCategory.Magic)
}

function aliveOf(arr) {
    var r = []
    for (var i = 0; i < array_length(arr); i++) if (!arr[i].isKO()) array_push(r, arr[i])
    return r
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
    for (var i = 0; i < array_length(hand); i++) {
        var c = hand[i]
        if (isSingleTargetCard(c) && checkIfCanPlayCard(puppet, c)) array_push(playable, c)
    }

    if (array_length(playable) == 0) {
        skipTurn()
        return
    }

    var allies = aliveOf(puppet.isEnemy ? enemies : heroes)   // союзники марионетки
    var foes   = aliveOf(puppet.isEnemy ? heroes : enemies)   // противники марионетки

    // Категоризируем играбельные карты: первый хил / бафф / атака
    var healChoice = noone, buffChoice = noone, attackChoice = noone
    for (var i = 0; i < array_length(playable); i++) {
        var c = playable[i]
        switch (cardCategoryOf(c)) {
            case CardCategory.Heal: if (healChoice == noone) healChoice = c; break
            case CardCategory.Buff: if (buffChoice == noone) buffChoice = c; break
            case CardCategory.Attack:
            case CardCategory.Magic: if (attackChoice == noone) attackChoice = c; break
        }
    }

    // Самый раненый союзник (для хила)
    var woundedAlly = noone
    var lowestHp = 999999
    for (var i = 0; i < array_length(allies); i++) {
        var a = allies[i]
        if (a.hp < a.maxHp && a.hp < lowestHp) { lowestHp = a.hp; woundedAlly = a }
    }

    var card = noone
    var target = noone

    // Лечим самого раненого союзника
    if (healChoice != noone && woundedAlly != noone) {
        target = enemyResolveTarget(healChoice, puppet, foes, allies, woundedAlly, noone)
        if (target != noone) card = healChoice
    }

    // Баффаем себя, если ещё не забаффаны этим модификатором
    if (card == noone && buffChoice != noone) {
        var alreadyBuffed = false
        var e0 = buffChoice.effects[0]
        if (variable_struct_exists(e0, "buffType"))
            alreadyBuffed = !is_undefined(checkIfHasBuff(puppet, EffectTypes.Buff, e0.buffType))
        if (!alreadyBuffed) {
            target = enemyResolveTarget(buffChoice, puppet, foes, allies, puppet, noone)
            if (target != noone) card = buffChoice
        }
    }

    // Атакуем
    if (card == noone && attackChoice != noone) {
        target = enemyResolveTarget(attackChoice, puppet, foes, allies, noone, noone)
        if (target != noone) card = attackChoice
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