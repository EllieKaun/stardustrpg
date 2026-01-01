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
    battleState = BattleStates.CharacterPlay
}

function Starrior(name, spr, hp, maxhp, deck) constructor {
    self.name = name
    self.spr = spr
    self.hp = hp
    self.maxhp = maxhp
    self.deck = deck
    self.x = 0
    self.y = 0
}

function Card(name, dmg) constructor {
    self.name = name
    self.dmg = dmg
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
        new Starrior("Lana", sLana, 10, 10, [new Card("strong card", 3), 
        new Card("card", 3),
        new Card("strong c", 3),
        new Card("strong carddddddd", 3)]),
        new Starrior("Mage", sViv, 10, 10, [])
    ]

    enemies = [
        new Starrior("Bird", sBird, 6, 6, []),
        new Starrior("Bird", sBird, 6, 6, []),
        new Starrior("Bird", sBird, 6, 6, []),
        new Starrior("Bird", sBird, 6, 6, []),
        new Starrior("Bird", sBird, 6, 6, [])
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