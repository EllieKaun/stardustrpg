focusArea = FocusArea.Deck
selectedMenuItem = 0
menuItems = ["Run", "Shuffle", "Info"]

global.guiBaseW = camera_get_view_width(view_camera[0])
global.guiBaseH = camera_get_view_height(view_camera[0])
setCrispGui(global.guiBaseW, global.guiBaseH)
selectedCard = 0
maxCardsOnDeskNumber = 4
copyNextCard = false

// Хит-боксы для управления мышью
cardHitRects = []
menuHitRects = []
rewardHitRects = [] // карты награды на экране победы
gameOverHitRects = [] // кнопки RETRY и EXIT на экране поражения
infoCloseRect = undefined
cancelHitRect = undefined
mouseLastX = -1 // для детекта движения мыши
mouseLastY = -1
idleDanceTimer = 0 // тики простоя выбранного персонажа (для танца)

// Анимация розыгрыша карты (см. scrCardAnimation)
activeCardAnims = []
animatingCard = noone // карта, которая сейчас летит (прячем её в руке)

// Очередь анимаций и действий, следующих за ними
actionsQueue = []

maxEnemiesCount = 6
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

tutorialActive = !tutorialIsDone()
tutorialCardsRect = undefined

// Размеры бейджа меню персонажа по названию 
menuRectNamed = function(nm) {
    for (var i = 0; i < array_length(menuHitRects); i++) {
        if (menuHitRects[i].name == nm) return menuHitRects[i]
    }
    return undefined
}

// Туториал
var lana = asset_get_index("placeholderLana")
tutorial = new TutorialRunner([
    { 
        speaker: "Lana",
        portrait: lana, 
        text: "These are your cards. Each one is an action you can play on your turn.",
        getRect: function() { 
            var r = undefined
            with (Battle) {
                r = tutorialCardsRect
            }
            return r 
        } 
    },
    { 
        speaker: "Lana", 
        portrait: lana, 
        text: "This is INFO - use it to inspect an enemy's stats before you act.",
        getRect: function() { 
            var r = undefined; 
            with (Battle) {
                r = menuRectNamed("Info")
            }
            return r 
        } 
    },
    { 
        speaker: "Lana", 
        portrait: lana,
        text: "This is SHUFFLE - it redraws your whole hand for this turn.",
        getRect: function() { 
            var r = undefined;
            with (Battle) {
                r = menuRectNamed("Shuffle"); 
                return r 
            }
        } 
    },
    { 
        speaker: "Lana", 
        portrait: lana, 
        text: "That's everything. Now defeat this Starrior on your own. Good luck!"
    }
])

// ДЛЯ ХРАНЕНИЯ ДАННЫХ В КОНЦЕ ИГРЫ
rewardChoices  = [] // Победные карты
rewardCursor   = 0 // Выбранная победная карта
rewardSelected = false // Выбрана ли награда
gameOverCursor = 0 // 0 = Retry, 1 = Exit

changeBattleState = function(newState) {
    if (battleState == newState) { return }
    battleState = newState

    switch (newState) {
        case BattleStates.EnemyTargetSelection:
            initTargetSelection(enemies)
        break
        case BattleStates.EnemyInfoSelection:
            initTargetSelection(enemies)
        break
        case BattleStates.EnemysTurn:
            alarm_set(ENEMYS_TURN, game_get_speed(gamespeed_fps) * 2)
        break
        case BattleStates.PuppetTurn:
            alarm_set(PUPPET_TURN, game_get_speed(gamespeed_fps) * 2)
        break
        case BattleStates.GameOver:
            addGold(-GOLD_DEFEAT_PENALTY)
            gameOverCursor = 0
        break
    }
}

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
generateLevel(
    starriorsZoneHeight, 
    screenWidth, 
    spacingBetweenStarriors, 
    global.battleEncounter
)

playMusicNamed("BattleMusic")
stopAmbient()