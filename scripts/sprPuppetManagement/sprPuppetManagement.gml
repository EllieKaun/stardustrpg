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
    puppet.brain = brainPreset((category == CardCategory.Heal || category == CardCategory.Buff) ? AiBrainType.Healer : AiBrainType.Skirmisher)
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

function runPuppetTurn(puppet) {
    if (puppet.justSummoned) {
        puppet.justSummoned = false
        skipTurn()
        return
    }

    if (array_length(puppet.getCardsInHand()) == 0) {
        shuffleDeckAndTake4(puppet)
    }

    var move = chooseMove(puppet)
    if (move == undefined) { 
        skipTurn()
        return 
    }

    playCard(move.card, puppet, move.target)
}