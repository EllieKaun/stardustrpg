// Пауза не должна перетекать из прошлой комнаты (например, при Retry)
global.gamePaused = false
global.uiModal = false

focusArea = FocusArea.Deck
selectedMenuItem = 0
menuItems = ["Run", "Shuffle", "Info"]

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

// Размеры бейджа меню персонажа по названию 
menuRectNamed = function(menuName) {
    for (var i = 0; i < array_length(menuHitRects); i++) {
        if (menuHitRects[i].name == menuName) { return menuHitRects[i] }
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
                highlightRect = menuRectNamed("Info")
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
                highlightRect = menuRectNamed("Shuffle"); 
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

changeBattleState = function(newState) {
    var startsTimedTurn = (newState == BattleStates.EnemysTurn
        || newState == BattleStates.PuppetTurn
        || newState == BattleStates.StunnedTurn)
    if (battleState == newState && !startsTimedTurn) { return }
    battleState = newState
    show_debug_message("battle state " + string(newState))

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
        case BattleStates.StunnedTurn:
            alarm_set(STUN_TURN, game_get_speed(gamespeed_fps) * STUN_TURN_SECONDS)
            with (selectedCharacter) drawDamageNumber((bbox_left + bbox_right) * 0.5, bbox_top - 20, loc("battle.stunned"), c_yellow)
        break
        case BattleStates.GameOver:
            loseAllGold()
            gameOverCursor = 0
            analyticsDefeat() // аналитика: поражение в бою
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

// новый id для группировки событий одной битвы
var _gaArea = variable_global_exists("battleSection") ? string(global.battleSection) : "overworld"
var _gaFoe  = (array_length(enemies) > 0) ? enemies[0].name : "enemy"
analyticsBattleStart(_gaArea, _gaFoe)

playMusicNamed("BattleMusic")
stopAmbient()