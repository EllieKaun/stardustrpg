function generateLevel(zoneH, screenW, spacing, section) {
    initStarriorsForSection(section);
    initStarriorsPositions(zoneH, screenW, spacing);
    selectNextCharacter();
    battleState = BattleStates.CharacterPlay;
}

function initStarriorsForSection(section) {
    heroes  = [createLana(), createViv()]
    enemies = createEncounterForSection(section)
    array_copy(playOrder, array_length(playOrder), heroes,  0, array_length(heroes))
    array_copy(playOrder, array_length(playOrder), enemies, 0, array_length(enemies))
    for (var i = 0; i < array_length(playOrder); i++) shuffleDeckAndTake4(playOrder[i])
}


function initStarriorsFromFactory(encounterFactory) {
    heroes = [createLana(), createViv()];
    enemies = (encounterFactory != undefined) ? encounterFactory() : createEnemiesLevel1();

    array_copy(playOrder, array_length(playOrder), heroes,  0, array_length(heroes));
    array_copy(playOrder, array_length(playOrder), enemies, 0, array_length(enemies));
    for (var i = 0; i < array_length(playOrder); i++) shuffleDeckAndTake4(playOrder[i]);
}

function createStarrior(name, 
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
deck) {
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

function initStarriors() {
    heroes = [
        createLana(),
        createViv()
    ]

    enemies = createEnemiesLevel1()
    
    array_copy(playOrder, array_length(playOrder), heroes, 0, array_length(heroes))
    array_copy(playOrder, array_length(playOrder), enemies, 0, array_length(enemies))
    for(var i = 0; i < array_length(playOrder); i++) {
        shuffleDeckAndTake4(playOrder[i])
    }
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
    var startX = screenWidth / 2 - spacingBetweenStarriors;
    var startY = starriorsZoneHeight
    for (var i = 0; i < array_length(heroes); i++) {
        heroes[i].x = startX;
        heroes[i].y = startY + (i mod 2 == 0 ? verticalSpacing : starriorsZoneHeight - verticalSpacing)
        startX -= spacingBetweenStarriors + 16
    }

    startX = screenWidth / 2 + spacingBetweenStarriors
    for (var i = 0; i < array_length(enemies); i++) {
        enemies[i].x = startX;
        enemies[i].y = startY + (i mod 2 == 0 ? verticalSpacing : starriorsZoneHeight - verticalSpacing)
        startX += spacingBetweenStarriors + 16
    }
}