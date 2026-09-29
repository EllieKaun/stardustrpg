// Пауза не должна перетекать из прошлой комнаты (например, при Retry)
global.gamePaused = false
global.uiModal = false

focusArea = FocusArea.Deck

global.guiBaseW = camera_get_view_width(view_camera[0])
global.guiBaseH = camera_get_view_height(view_camera[0])
setCrispGui(global.guiBaseW, global.guiBaseH)

// Затемняем фон боя
var backgroundLayer = layer_get_id("Background")
if (backgroundLayer != -1) {
    layer_background_blend(layer_background_get_id(backgroundLayer), merge_color(c_white, c_black, BATTLE_BACKGROUND_DIM))
}
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

// Анимация розыгрыша карты (см. scrCardAnimation)
activeCardAnims = []
animatingCard = noone // карта, которая сейчас летит

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

// Можно ли танцевать при афк
allowsIdleDance = function() {
    return battleState == BattleStates.CharacterPlay && !tutorialActive
}

tutorialActive = !tutorialIsDone()
tutorialCardsRect = undefined

menuRectNamed = function(action) {
    for (var i = 0; i < array_length(menuHitRects); i++) {
        if (menuHitRects[i].action == action) { return menuHitRects[i] }
    }
    return undefined
}

// Туториал
var lana = asset_get_index("portraitLana")
tutorial = new TutorialRunner([
    {
        speaker: "Lana",
        portrait: lana,
        text: loc("dlg.tut.battle1"),
        getRect: function() {
            var highlightRect = undefined
            with (Battle) {
                highlightRect = tutorialCardsRect
            }
            return highlightRect
        }
    },
    {
        speaker: "Lana",
        portrait: lana,
        text: loc("dlg.tut.battle2"),
        getRect: function() {
            var highlightRect = undefined;
            with (Battle) {
                highlightRect = menuRectNamed(BattleMenuAction.Info)
            }
            return highlightRect
        }
    },
    {
        speaker: "Lana",
        portrait: lana,
        text: loc("dlg.tut.battle3"),
        getRect: function() {
            var highlightRect = undefined;
            with (Battle) {
                highlightRect = menuRectNamed(BattleMenuAction.Shuffle);
                return highlightRect
            }
        }
    },
    {
        speaker: "Lana",
        portrait: lana,
        text: loc("dlg.tut.battle4")
    }
])

// ДЛЯ ХРАНЕНИЯ ДАННЫХ В КОНЦЕ ИГРЫ
rewardChoices  = [] // Победные карты
rewardCursor   = 0 // Выбранная победная карта
rewardSelected = false // Выбрана ли награда
gameOverCursor = 0 // 0 = Retry, 1 = Exit

initBattleStates()

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

// новый id для группировки событий одной битвы
var _gaArea = variable_global_exists("battleSection") ? string(global.battleSection) : "overworld"
var _gaFoe  = (array_length(enemies) > 0) ? enemies[0].name : "enemy"
analyticsBattleStart(_gaArea, _gaFoe)

playMusicNamed("BattleMusic")
stopAmbient()
