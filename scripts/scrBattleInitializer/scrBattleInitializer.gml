function generateLevel(zoneH, screenW, spacing, encounter) {
    initStarriorsFromEncounter(encounter)
    initStarriorsPositions(zoneH, screenW, spacing)
    selectNextCharacter()
    battleState = BattleStates.CharacterPlay
}

function initStarriorsFromEncounter(encounter) {
    heroes  = [createLana(), createViv()];
    enemies = [];
    var creators = encounter.enemyCreators;
    for (var i = 0; i < array_length(creators); i++) array_push(enemies, creators[i]());

    array_copy(playOrder, array_length(playOrder), heroes,  0, array_length(heroes));
    array_copy(playOrder, array_length(playOrder), enemies, 0, array_length(enemies));
    for (var i = 0; i < array_length(playOrder); i++) shuffleDeckAndTake4(playOrder[i]);
    for (var i = 0; i < array_length(enemies); i++) enemies[i].isEnemy = true;
}

function createStarrior(
    name, 
    spriteIdle, 
    spriteAttack, 
    spriteCast,
    spriteKO,
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
    deck
) {
    var starrior = instance_create_depth(0, 0, depth - 1, Starrior)
    starrior.name = name
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
    starrior.spriteActionKO = spriteKO
    starrior.sprite_index = spriteIdle
    starrior.strength = strength 
    starrior.intelligence = intelligence 
    starrior.aura = aura 
    starrior.guts = guts 
    starrior.mask_index = spriteIdle
    starrior.isPuppet = false;
    starrior.isEnemy  = false; 
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

function initStarriorsPositions(
    starriorsZoneHeight,
    screenWidth,
    spacingBetweenStarriors,
) {
    var verticalSpacing = (starriorsZoneHeight - 16 * 2) / 2
    var startY = starriorsZoneHeight
    var step   = spacingBetweenStarriors + 16          // шаг между бойцами (как раньше)

    var halfW          = screenWidth / 2
    var heroesCenterX  = halfW * 0.5                    // центр ЛЕВОЙ половины
    var enemiesCenterX = halfW + halfW * 0.5           // центр ПРАВОЙ половины

    // Герои — по центру левой половины
    var heroCount  = array_length(heroes)
    var heroStartX = heroesCenterX - (heroCount - 1) * step / 2   // центрируем группу
    for (var i = 0; i < heroCount; i++) {
        heroes[i].x = heroStartX + i * step
        heroes[i].y = startY + (i mod 2 == 0 ? verticalSpacing : starriorsZoneHeight - verticalSpacing)
    }

    // Враги — по центру правой половины
    var enemyCount  = array_length(enemies)
    var enemyStartX = enemiesCenterX - (enemyCount - 1) * step / 2
    for (var i = 0; i < enemyCount; i++) {
        enemies[i].x = enemyStartX + i * step
        enemies[i].y = startY + (i mod 2 == 0 ? verticalSpacing : starriorsZoneHeight - verticalSpacing)
    }
}