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

function Starrior(name, spr, hp, maxhp, deck, energy, maxEnergy) constructor {
    self.name = name
    self.spr = spr
    self.hp = hp
    self.maxhp = maxhp
    self.deck = deck
    self.energy = energy
    self.maxEnergy = maxEnergy
    self.x = 0
    self.y = 0
}

function Card(name, cardBaseScr, cardBorderScr, target, effects) constructor {
    self.name = name
    self.target = target
    self.cardBaseScr = cardBaseScr
    self.cardBorderScr = cardBorderScr
    self.effects = effects
}

function selectNextCharacter() {
    if selectedCharacter == noone {
        selectedCharacter = heroes[0]
        cards = selectedCharacter.deck
    } else {
        selectedCharacter = heroes[1]
    }
}

function initStarriors() {
    heroes = [
        new Starrior("Lana",    
            sprLanaBattleIdle, 
            10, 
            10, 
            [createPhysicalDamageCardDefault() ],
            1,
            1),
        new Starrior("Mage", sprVivBatlleIdle, 10, 10, [], 1, 1)
    ]

    enemies = [
        new Starrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1),
        new Starrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1),
        new Starrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1),
        new Starrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1),
        new Starrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1)
    ]
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