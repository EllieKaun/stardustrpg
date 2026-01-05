function generateLevel(
    starriorsZoneHeight,
    screenWidth,
    spacingBetweenStarriors
) {
    initStarriors()
    initStarriorsPositions(
        starriorsZoneHeight,
        screenWidth,
        spacingBetweenStarriors
    )
    
    selectNextCharacter()
    battleState = BattleStates.CharacterPlay
}

function createStarrior(name, spr, hp, maxhp, deck, energy, maxEnergy) {
    var starrior = instance_create_depth(0, 0, depth - 1, Starrior)
    starrior.hp = hp 
    starrior.maxHp = maxhp
    starrior.deck = new Deck(deck) 
    starrior.sprite_index = spr
    starrior.energy = energy 
    starrior.maxEnergy = maxEnergy 
    return starrior
}

function Card(name, cardBaseScr, cardBorderScr, target, effects) constructor {
    self.name = name
    self.target = target
    self.cardBaseScr = cardBaseScr
    self.cardBorderScr = cardBorderScr
    self.effects = effects
}

function Deck(originalDeck) constructor {
    self.originalDeck = originalDeck
    self.shuffeledDeck = []
    self.cardsInHand = []
}

function shuffleDeckAndTake4(character) {
    var originalDeck = character.getOriginalDeck()
    var shuffeledDeck = array_shuffle(originalDeck)
    var top4Cards = take4CardsFromDeckTop(shuffeledDeck, [])
    character.deck.shuffeledDeck = shuffeledDeck
    character.deck.cardsInHand = top4Cards

}

function take4CardsFromDeckTop(shuffledDeck, cardsInHand) {
    var top4Cards = []
    for(var i = array_length(cardsInHand); 
        i < maxCardsOnDeskNumber && array_length(shuffledDeck) > 0; 
        i++) {
        array_push(top4Cards, array_shift(shuffledDeck))
    }  
    return top4Cards     
}

function selectNextCharacter() {
    if array_length(playOrder) == 0 return
    if selectedCharacterNumber == -1 {
        selectedCharacterNumber = 0
    } else {
        selectedCharacterNumber = selectedCharacterNumber + 1 >= array_length(playOrder) 
            ? 0 : selectedCharacterNumber + 1
    }
    resetSelectionToAll()
    selectedCharacter = playOrder[selectedCharacterNumber]
    selectedCharacter.isActive = true
    cards = selectedCharacter.deck
}

function resetSelectionToAll() {
    for (var i = 0; i < array_length(playOrder); i++) {
        playOrder[i].isActive = false
    }
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