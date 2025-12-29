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

/// position heroes

var screenWidth = camera_get_view_width(view_camera[0])
var screenHeight = camera_get_view_height(view_camera[0])

var totalSpace = maxEnemiesCount + maxEnemiesCount * spacingBetweenStarriors
var fitSpace = totalSpace < screenWidth / 2 
if !fitSpace {
    spacingBetweenStarriors = ((screenWidth / 2) - maxEnemiesCount * 32) / maxEnemiesCount
}
var verticalSpacing = (screenHeight / 3 - 32 * 2) / 3
var startX = screenWidth - spacingBetweenStarriors;
var startY = screenHeight / 3
for (var i = 0; i < array_length(heroes); i++) {
    heroes[i].x = startX;
    heroes[i].y = startY + (i mod 2 == 0 ? verticalSpacing : (screenHeight / 3) - verticalSpacing)
}

/// position enemies (grid style)
var cols = 3;
var enemySpacingX = 40;
var enemySpacingY = 26;

for (var i = 0; i < array_length(enemies); i++) {
    enemies[i].x = 200 + (i mod cols) * enemySpacingX;
    enemies[i].y = 80  + (i div cols) * enemySpacingY;
}
