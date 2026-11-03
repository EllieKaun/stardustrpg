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
    var baseDim = merge_color(c_white, c_black, BATTLE_BACKGROUND_DIM)
    var battleTint = merge_color(baseDim, make_color_rgb(45, 55, 95), nightValue() * 0.8)
    layer_background_blend(layer_background_get_id(backgroundLayer), battleTint)
}

global.battleIsNight = isNight()
global.battleCauldronStolen = false
selectedCard = 0
maxCardsOnDeskNumber = MAX_CARDS_IN_HAND
copyNextCard = false

// Хит-боксы для управления мышью
cardHitRects = []
menuHitRects = []
cancelHitRect = undefined
mouseLastX = -1 // для детекта движения мыши
mouseLastY = -1

// Анимация розыгрыша карты (см. scrCardAnimation)
activeCardAnims = []
animatingCard = noone // карта, которая сейчас летит

// Очередь анимаций и действий, следующих за ними
actionsQueue = []

// Реакция на попадание в слабое место

// спрайт проигрывания при попадании
weakSpotImpactSprite = noone
// альфа спрайта
weakSpotImpactAlpha = 0
// фрейм спрайта
weakSpotImpactFrame = 0
// блокировка на анимацию
weakSpotImpactBlocking = false

startWeakSpotImpact = function(sprite) {
    if (sprite == noone || !sprite_exists(sprite)) { return }
    weakSpotImpactSprite = sprite
    weakSpotImpactAlpha = 0
    weakSpotImpactFrame = 0
    weakSpotImpactBlocking = true

    var frameCount = sprite_get_number(sprite)
    var playFrames = (frameCount > 1) ? spritePlayFrames(sprite) : WEAK_SPOT_IMPACT_HOLD

    var runner = new SequenceRunner()
    runner.play([
        stepTween(WEAK_SPOT_IMPACT_FADE_IN, function(k) { with (Battle) { weakSpotImpactAlpha = k } }),
        stepTween(playFrames, function(k) {
            with (Battle) {
                weakSpotImpactAlpha = 1
                weakSpotImpactFrame = k * (sprite_get_number(weakSpotImpactSprite) - 1)
            }
        }),
        stepDo(function() { with (Battle) { weakSpotImpactBlocking = false } }),
        stepTween(WEAK_SPOT_IMPACT_FADE_OUT, function(k) { with (Battle) { weakSpotImpactAlpha = 1 - k } }),
        stepDo(
            function() { 
                with (Battle) { 
                    weakSpotImpactSprite = noone 
                    weakSpotImpactAlpha = 0 
                    weakSpotImpactFrame = 0 
                } 
            }
        )
    ])
    array_push(actionsQueue, runner)
}

drawWeakSpotImpact = function(screenW, screenH) {
    if (weakSpotImpactSprite == noone || weakSpotImpactAlpha <= 0 || !sprite_exists(weakSpotImpactSprite)) { return }

    var alpha = clamp(weakSpotImpactAlpha, 0, 1)

    drawScreenDim(alpha * WEAK_SPOT_IMPACT_DIM)

    var spW = sprite_get_width(weakSpotImpactSprite)
    var spH = sprite_get_height(weakSpotImpactSprite)
    var coverScale = max(screenW / spW, screenH / spH)
    var drawX = screenW / 2 - spW * coverScale / 2 + sprite_get_xoffset(weakSpotImpactSprite) * coverScale
    var drawY = screenH / 2 - spH * coverScale / 2 + sprite_get_yoffset(weakSpotImpactSprite) * coverScale
    draw_sprite_ext(weakSpotImpactSprite, floor(weakSpotImpactFrame), drawX, drawY, coverScale, coverScale, 0, c_white, alpha)
}

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
tutorialSteps = [
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
]

// ДЛЯ ХРАНЕНИЯ ДАННЫХ В КОНЦЕ ИГРЫ
rewardChoices  = [] // Победные карты

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
