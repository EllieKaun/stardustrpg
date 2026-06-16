focusArea = FocusArea.Deck
selectedMenuItem = 0
menuItems = ["Shuffle", "Info", "Run"]

// Synchronize GUI size with camera view to prevent UI jumping
display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]))
selectedCard = 0 
maxCardsOnDeskNumber = 4
copyNextCard = false

maxEnemiesCount = 5
spacingBetweenStarriors = 16

cards = []
heroes = []
enemies = []
playOrder = []
selectedCharacter = noone
selectedCharacterNumber = -1

selectedTarget = noone
selectedTargetNumber = -1
targetOptions = []

battleState = BattleStates.Preparing

// ДЛЯ ХРАНЕНИЯ ДАННЫХ В КОНЦЕ ИГРЫ
rewardChoices  = [] // Победные карты
rewardCursor   = 0 // Выбранная победная карта
rewardSelected = false // Выбрана ли награда
gameOverCursor = 0 // 0 = Retry, 1 = Exit


// Расчет позиций героев и врагов
var screenWidth = camera_get_view_width(view_camera[0])
var screenHeight = camera_get_view_height(view_camera[0])
var starriorsZoneHeight = screenHeight / 3
var totalSpace = maxEnemiesCount + maxEnemiesCount * spacingBetweenStarriors
var fitSpace = totalSpace < screenWidth / 2 
if !fitSpace {
    spacingBetweenStarriors = ((screenWidth / 2) - maxEnemiesCount * 16) / maxEnemiesCount
}

// генерация уровней
generateLevel(starriorsZoneHeight, screenWidth, spacingBetweenStarriors, global.battleSection)