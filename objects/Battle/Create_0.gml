focusArea = FocusArea.Deck
selectedMenuItem = 0
menuItems = ["Shuffle", "Info", "Run"]

// High-res GUI: draw the low-res battle UI scaled up so that text overlaid on
// the cards can be rendered at full GUI resolution and stay readable (see the
// Draw GUI event). guiBaseW/H are the "logical" battle coordinates.
// The GUI is matched to the WINDOW size: a GUI bigger than the window would be
// downscaled by the OS and make the crisp text look ragged.
global.guiBaseW = camera_get_view_width(view_camera[0])
global.guiBaseH = camera_get_view_height(view_camera[0])
display_set_gui_size(max(window_get_width(), global.guiBaseW), max(window_get_height(), global.guiBaseH))
selectedCard = 0
maxCardsOnDeskNumber = 4
copyNextCard = false

// Хит-боксы для управления мышью (заполняются в Draw GUI, читаются в Step)
cardHitRects  = []
menuHitRects  = []
infoCloseRect = undefined
mouseLastX    = -1   // для детекта движения мыши (чтобы не перебивать клавиатуру в покое)
mouseLastY    = -1

// Анимация розыгрыша карты (см. scrCardAnimation)
activeCardAnims = []
animatingCard = noone // карта, которая сейчас летит (прячем её в руке)
animPendingCard = noone
animPendingCaster = noone
animPendingTargets = noone

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