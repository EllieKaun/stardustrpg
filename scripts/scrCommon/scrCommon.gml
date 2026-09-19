//// Константы и общие функции

// Золото
#macro GOLD_PER_ENEMY 6 // награда за одного врага
#macro GOLD_RUN_PENALTY 5 // штраф за побег

// Магазин
#macro SHOP_CARD_PRICE 100 // цены карты
#macro SHOP_SLOT_BASE 100 // цена слота декбилдера
#macro SHOP_SLOT_GROWTH 1.5 // во сколько раз увеличивается цена слота

// Сундуки
#macro CHEST_MAX_COUNT 5 // максимальное количество сундуков на карте
#macro CHEST_MIN_DISTANCE 180 // минимальная дистанция между сундуками
#macro CHEST_INTERACT_DIST 24 // 
#macro CHEST_GOLD_MIN 5 // минимальная награда золота из сундука
#macro CHEST_GOLD_RANGE 15 // максимальная награда золота из сундука

// Награды
#macro REWARD_DUPLICATE_FALLOFF 0.5 // падение шанса выпадения дубликата карты как награды

// Сложность врагов
#macro ENEMY_WIN_BONUS 5 // рост силы врагов
#macro ENEMY_WIN_INTERVAL 5 // сколько побед нужно чтобы сложность выросла
#macro SPEAR_BATTLE_BONUS 15  // сложность врагов с капьем

// Бой
#macro BATTLE_BACKGROUND_DIM 0.1 // затемнение фона боя

// Цвет маны
#macro MANA_COLOR make_color_rgb(77, 179, 203)

// Шрифты

#macro UI_FONT_STACK [fnUI_48, fnUI_32, fnUI_24, fnUI_16, fnUI_14, fnUI_12, fnUI_10, fnUI_9, fnUI_8, fnUI_7]
#macro UI_TAB_FONT_STACK [fnUI_48, fnUI_32, fnUI_24, fnUI_16, fnUI_14, fnUI_12, fnUI_10, fnUI_8]

//// Хелперы

// Препятсвия
function worldObstacles() {
    return [oWall, oTree1, oTree2, oTree3, oTree4, oTree5, oStump]
}

// Затемнение всего GUI
function drawScreenDim(alpha) {
    draw_set_color(c_black)
    draw_set_alpha(alpha)
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
    draw_set_alpha(1)
    draw_set_color(c_white)
}

// Проверка подтверждения enter space
function uiConfirmPressed() {
    return keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(vk_space)
        || keyboard_check_pressed(ord("E"))
}

// Масштаб GUI до размеров экрана
function guiScale() {
    return display_get_gui_width() / guiBaseWidth()
}

// Прибавить врагу бонус к урону и здоровью
function applyEnemyStatBonus(enemy, points) {
    enemy.strength += points
    enemy.intelligence += points
    enemy.hp += points
    enemy.maxHp += points
}

// Раннер анимация и действий после их проигрывания
// Шаг: { start(ctx), update(ctx) -> done }
function SequenceRunner() constructor {
    self.steps = []
    self.i = 0
    self.running = false
    self.ctx = {}

    self.startCurrent = function() {
        var s = self.steps[self.i]
        if (variable_struct_exists(s, "start") && s.start != undefined) {
            s.start(self.ctx)
        }
    }

    self.update = function() {
        var guard = 0
        while (self.running && guard < 64) {
            guard++
            var s = self.steps[self.i]
            var done = (variable_struct_exists(s, "update") && s.update != undefined) ? s.update(self.ctx) : true
            if (!done) { break }
            self.i++
            if (self.i >= array_length(self.steps)) {
                self.running = false
                break
            }
            self.startCurrent()
        }
    }

    self.play = function(_steps, _ctx = undefined) {
        self.steps = _steps
        self.ctx = (_ctx == undefined) ? {} : _ctx
        self.i = 0
        self.running = array_length(self.steps) > 0
        if (self.running) {
            self.startCurrent()
            self.update()
        }
    }

    self.isRunning = function() { 
        return self.running 
    }
}

// инициализация глобальных переменных игры
function initGameGlobals() {
    global.safarJoined = (questSpearState() == QuestSpearState.Completed)
    global.walkSound = asset_get_index("GrassWalk")

    global.returningFromBattle = false
    global.fightEnemy = noone

    global.introWalk = false
    global.introTarget = noone
    global.introPendingWalk = false

    global.deckTutorialStage = DeckTutorialStage.Inactive

    global.battleNoFlee = false
    global.spearCarrierExists = false
    global.battleHasSpear = false

    global.mpGrid = -1
    global.battleSection = 1
    global.uiModal = false
    global.gamePaused = false
    global.cutsceneActive = false

    if (!variable_global_exists("chestsGenerated")) {
        global.chestsGenerated = false
        global.chests = []
    }
}

function startTransition(targetRoom) {
    with (oTransition) {
        target_room = targetRoom
        state = "fade_out"
    }
}
