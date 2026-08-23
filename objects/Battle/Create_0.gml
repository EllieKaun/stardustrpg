focusArea = FocusArea.Deck
selectedMenuItem = 0
menuItems = ["Run", "Shuffle", "Info"]

global.guiBaseW = camera_get_view_width(view_camera[0])
global.guiBaseH = camera_get_view_height(view_camera[0])
display_set_gui_size(max(window_get_width(), global.guiBaseW), max(window_get_height(), global.guiBaseH))
selectedCard = 0
maxCardsOnDeskNumber = 4
copyNextCard = false

// Хит-боксы для управления мышью (заполняются в Draw GUI, читаются в Step)
cardHitRects = []
menuHitRects = []
rewardHitRects = [] // карты награды на экране победы
gameOverHitRects = [] // кнопки RETRY/EXIT на экране поражения
infoCloseRect = undefined
mouseLastX = -1 // для детекта движения мыши
mouseLastY = -1
idleDanceTimer = 0 // тики простоя выбранного персонажа (для танца)

// Анимация розыгрыша карты (см. scrCardAnimation)
activeCardAnims = []
animatingCard = noone // карта, которая сейчас летит (прячем её в руке)
animPendingCard = noone
animPendingCaster = noone
animPendingTargets = noone
drawPendingCard = noone
playPendingCaster = noone

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
posZoneHeight = starriorsZoneHeight
posScreenWidth = screenWidth
posSpacing = spacingBetweenStarriors

// генерация уровня
generateLevel(starriorsZoneHeight, screenWidth, spacingBetweenStarriors, global.battleEncounter)