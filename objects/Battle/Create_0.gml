cards = [0, 1, 2, 3]
selectedCard = 0 
maxCardsOnDeskNumber = 4
maxEnemiesCount = 5
spacingBetweenStarriors = 16

heroes = [
    new Starrior("Lana", sLana, 10, 10),
    new Starrior("Mage", sViv, 10, 10)
]

enemies = [
    new Starrior("Bat", sBird, 6, 6),
    new Starrior("Bat", sBird, 6, 6),
    new Starrior("Bat", sBird, 6, 6),
]

// Расчет позиций героев и врагов

var screenWidth = camera_get_view_width(view_camera[0])
var screenHeight = camera_get_view_height(view_camera[0])

var totalSpace = maxEnemiesCount + maxEnemiesCount * spacingBetweenStarriors
var fitSpace = totalSpace < screenWidth / 2 
if !fitSpace {
    spacingBetweenStarriors = ((screenWidth / 2) - maxEnemiesCount * 32) / maxEnemiesCount
}
var verticalSpacing = (screenHeight / 3 - 32 * 2) / 3
var startX = screenWidth / 2 - spacingBetweenStarriors;
var startY = screenHeight / 3
for (var i = 0; i < array_length(heroes); i++) {
    heroes[i].x = startX;
    heroes[i].y = startY + (i mod 2 == 0 ? verticalSpacing : (screenHeight / 3) - verticalSpacing)
    startX -= spacingBetweenStarriors + 16
}

startX = screenWidth / 2 + spacingBetweenStarriors
for (var i = 0; i < array_length(enemies); i++) {
    enemies[i].x = startX;
    enemies[i].y = startY + (i mod 2 == 0 ? verticalSpacing : (screenHeight / 3) - verticalSpacing)
    startX += spacingBetweenStarriors + 16
}
