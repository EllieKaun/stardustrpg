selectedCard = 0 
maxCardsOnDeskNumber = 4
maxEnemiesCount = 5
spacingBetweenStarriors = 16

heroes = []
enemies = []
selectedCharacter = noone

// Расчет позиций героев и врагов

var screenWidth = camera_get_view_width(view_camera[0])
var screenHeight = camera_get_view_height(view_camera[0])
var starriorsZoneHeight = screenHeight / 3
var totalSpace = maxEnemiesCount + maxEnemiesCount * spacingBetweenStarriors
var fitSpace = totalSpace < screenWidth / 2 
if !fitSpace {
    spacingBetweenStarriors = ((screenWidth / 2) - maxEnemiesCount * 16) / maxEnemiesCount
}

generateLevel(
    starriorsZoneHeight,
    screenWidth,
    spacingBetweenStarriors
)