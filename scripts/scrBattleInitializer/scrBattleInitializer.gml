function generateLevel(zoneH, screenW, spacing, encounter) {
    initStarriorsFromEncounter(encounter)
    initStarriorsPositions(zoneH, screenW, spacing)
    selectNextCharacter()
    changeBattleState(BattleStates.CharacterPlay)
}

function initStarriorsFromEncounter(encounter) {
    if (TEST_BATTLE_ENABLED) {
        encounter = testBattleEncounter()
        global.battleEncounter = encounter
    }
    if (variable_struct_exists(encounter, "heroCreators")) {
        heroes = []
        for (var i = 0; i < array_length(encounter.heroCreators); i++) {
            array_push(heroes, encounter.heroCreators[i]())
        }
    } else {
        heroes = [createLana(), createViv()]
        if (variable_global_exists("safarJoined") && global.safarJoined) {
            array_push(heroes, createSafar())
        }
    }
    enemies = []
    var creators = encounter.enemyCreators
    for (var i = 0; i < array_length(creators); i++) {
        array_push(enemies, creators[i]())
    }

    array_copy(playOrder, array_length(playOrder), heroes,  0, array_length(heroes))
    array_copy(playOrder, array_length(playOrder), enemies, 0, array_length(enemies))
    for (var i = 0; i < array_length(playOrder); i++) {
        shuffleDeckAndTake4(playOrder[i])
    }
    
    var raw = variable_struct_exists(encounter, "raw") && encounter.raw
    var bonus = enemyStatBonus()
    for (var i = 0; i < array_length(enemies); i++) {
        var e = enemies[i]
        e.isEnemy = true
        e.hasSpear = false
        if (raw) continue
        if (enemyIgniteRoll()) {
            igniteEnemy(e)
        } else {
            applyEnemyStatBonus(e, bonus)
        }
    }

    // Копьё в бою только пока квест активен
    var spearQuestActive = (questSpearState() == QuestSpearState.Active)
    if (variable_global_exists("battleHasSpear") && global.battleHasSpear && !spearQuestActive) {
        global.battleHasSpear = false
    }

    if (!raw
        && variable_global_exists("battleHasSpear")
        && global.battleHasSpear
        && array_length(enemies) > 0) {
        var spearIdx = irandom(array_length(enemies) - 1)
        enemies[spearIdx].hasSpear = true
        if (spearBattleSprite() == noone) enemies[spearIdx].image_blend = c_yellow

        var db = spearBattleBonus()
        for (var i = 0; i < array_length(enemies); i++) {
            applyEnemyStatBonus(enemies[i], db)
        }
        global.battleHasSpear = false
    }
}

function igniteEnemy(e) {
    e.strength = e.strength * 10
    e.hp = e.hp * 6
    e.maxHp = e.maxHp * 6
    e.isIgnited = true
    e.igniteEffectChance = 0.1
}

function createStarrior(
    name, 
    spriteIdle, 
    spriteAttack, 
    spriteSpell,
    spriteCast,
    spriteKO,
    spriteDance,
    hp, 
    maxHp, 
    mana,
    maxMana,
    energy, 
    maxEnergy,
    strength,
    intelligence,
    aura,
    guts,
    deck,
    weaknesses = undefined,
    strengths = undefined
) {
    var starrior = instance_create_depth(0, 0, depth - 1, Starrior)
    starrior.name = name
    starrior.weaknesses = weaknesses ?? []
    starrior.strengths  = strengths  ?? []
    starrior.hp = hp 
    starrior.maxHp = maxHp
    starrior.mana = mana 
    starrior.maxMana = maxMana
    starrior.deck = new Deck(deck) 
    starrior.energy = energy 
    starrior.maxEnergy = maxEnergy 
    starrior.spriteActionAttack = spriteAttack
    starrior.spriteActionIdle = spriteIdle
    starrior.spriteActionCast = spriteCast
    starrior.spriteActionSpell = spriteSpell
    starrior.spriteActionDance = spriteDance
    starrior.spriteActionKO = spriteKO
    starrior.sprite_index = spriteIdle
    starrior.strength = strength 
    starrior.intelligence = intelligence 
    starrior.aura = aura 
    starrior.guts = guts 
    starrior.mask_index = spriteIdle
    starrior.isPuppet = false
    starrior.isEnemy  = false
    return starrior
}

function playerDeckFor(character) {
    var saved = deckOf(character).cards

    var sorted = array_create(array_length(saved))
    array_copy(sorted, 0, saved, 0, array_length(saved))
    array_sort(sorted, function(a, b) { return a.slot - b.slot; })

    var deck = []
    for (var i = 0; i < array_length(sorted); i++) {
        array_push(deck, cardFromRef(sorted[i]))
    }
    return deck
}

// Закрепляет за каждым персонажем слот
function assignStarriorSlots(team) {
    var used = []
    for (var i = 0; i < array_length(team); i++) {
        var slot = team[i].slotIndex
        if (slot >= 0 && !array_contains(used, slot)) array_push(used, slot)
        else team[i].slotIndex = -1 // повторный слот - назначим заново
    }
    for (var i = 0; i < array_length(team); i++) {
        if (team[i].slotIndex >= 0) continue
        var free = 0
        while (array_contains(used, free)) free++
        team[i].slotIndex = free
        array_push(used, free)
    }
}

// Порядок ходов по слотам
function rebuildPlayOrder() {
    var bySlot = function(a, b) { return a.slotIndex - b.slotIndex }
    var sortedHeroes  = array_create(array_length(heroes))
    var sortedEnemies = array_create(array_length(enemies))
    array_copy(sortedHeroes,  0, heroes,  0, array_length(heroes))
    array_copy(sortedEnemies, 0, enemies, 0, array_length(enemies))
    array_sort(sortedHeroes,  bySlot)
    array_sort(sortedEnemies, bySlot)

    array_resize(playOrder, 0)
    for (var i = 0; i < array_length(sortedHeroes); i++)  array_push(playOrder, sortedHeroes[i])
    for (var i = 0; i < array_length(sortedEnemies); i++) array_push(playOrder, sortedEnemies[i])

    // очередь сдвинулась - указатель хода должен остаться на том же персонаже
    var idx = array_get_index(playOrder, selectedCharacter)
    if (idx >= 0) selectedCharacterNumber = idx
}

function initStarriorsPositions(
    starriorsZoneHeight,
    screenWidth,
    spacingBetweenStarriors,
) {
    var verticalSpacing = (starriorsZoneHeight - 16 * 2) / 2
    var extraSpread = 8 
    var startY = starriorsZoneHeight
    var halfW = screenWidth / 2
    var heroesCenterX  = halfW * 0.5 // центр левой половины
    var enemiesCenterX = halfW + halfW * 0.5 // центр правой половины

    var slotCount = MAX_STARRIORS_PER_SIDE

   
    var edgeMargin = 16
    var baseStep = spacingBetweenStarriors + 16
    var fitStep  = (halfW - edgeMargin * 2) / (slotCount - 1)
    var step = min(baseStep, fitStep)

    assignStarriorSlots(heroes)
    assignStarriorSlots(enemies)
    rebuildPlayOrder()

    // Герои — по центру левой половины, заполняются справа налево
    var heroCount  = array_length(heroes)
    var heroStartX = heroesCenterX - (slotCount - 1) * step / 2  // центрируем на 5 слотов
    for (var i = 0; i < heroCount; i++) {
        var heroSlot = heroes[i].slotIndex
        heroes[i].x = heroStartX + (slotCount - 1 - heroSlot) * step
        heroes[i].y = startY + (heroSlot mod 2 == 0 ? verticalSpacing - extraSpread : starriorsZoneHeight - verticalSpacing + extraSpread)
    }

    // Враги — по центру правой половины
    var enemyCount  = array_length(enemies)
    var enemyStartX = enemiesCenterX - (slotCount - 1) * step / 2
    for (var i = 0; i < enemyCount; i++) {
        var enemySlot = enemies[i].slotIndex
        enemies[i].x = enemyStartX + enemySlot * step
        enemies[i].y = startY + (enemySlot mod 2 == 0 ? verticalSpacing - extraSpread : starriorsZoneHeight - verticalSpacing + extraSpread)
    }
}