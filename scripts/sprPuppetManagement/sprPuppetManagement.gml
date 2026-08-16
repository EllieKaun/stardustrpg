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

    var card = playable[irandom(array_length(playable) - 1)]
    var ownTeam = puppet.isEnemy ? enemies : heroes
    var otherTeam = puppet.isEnemy ? heroes : enemies
    var pool = puppetTargetsEnemies(puppet.puppetCategory) ? aliveOf(otherTeam) : aliveOf(ownTeam)

    if (array_length(pool) == 0) { 
        skipTurn() 
        return 
    }
    var target = pool[irandom(array_length(pool) - 1)]
    playCard(card, puppet, target)
}