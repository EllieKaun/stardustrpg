//// ===== Тюн-значения геймплея (в одном месте) =====

// Экономика
#macro GOLD_PER_ENEMY 6
#macro GOLD_DEFEAT_PENALTY 10
#macro GOLD_RUN_PENALTY 5

// Магазин
#macro SHOP_CARD_PRICE 100
#macro SHOP_SLOT_BASE 100
#macro SHOP_SLOT_GROWTH 1.5

// Сундуки
#macro CHEST_MAX_COUNT 5
#macro CHEST_MIN_DISTANCE 180
#macro CHEST_INTERACT_DIST 24
#macro CHEST_GOLD_MIN 5
#macro CHEST_GOLD_RANGE 15

// Награды
#macro REWARD_DUP_FALLOFF 0.5

// Сложность врагов
#macro ENEMY_WIN_BONUS 5
#macro ENEMY_WIN_INTERVAL 5
#macro SPEAR_BATTLE_BONUS 15

//// ===== Лесенки шрифтов =====

#macro UI_FONT_STACK [fnUI_48, fnUI_32, fnUI_24, fnUI_16, fnUI_14, fnUI_12, fnUI_10, fnUI_9, fnUI_8, fnUI_7]
#macro UI_TAB_FONT_STACK [fnUI_48, fnUI_32, fnUI_24, fnUI_16, fnUI_14, fnUI_12, fnUI_10, fnUI_8]

//// ===== Общие хелперы =====

// Статичные препятствия оверворлда для движения/коллизий
function worldObstacles() {
    return [oWall, oTree1, oTree2, oTree3, oTree4, oTree5, oStump]
}

// Затемнение всего GUI (модальные окна/оверлеи)
function drawScreenDim(alpha) {
    draw_set_color(c_black)
    draw_set_alpha(alpha)
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
    draw_set_alpha(1)
    draw_set_color(c_white)
}

// Единая проверка подтверждения в UI
function uiConfirmPressed() {
    return keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(vk_space)
        || keyboard_check_pressed(ord("E"))
}

// Масштаб GUI относительно логической базы
function guiScale() {
    return display_get_gui_width() / guiBaseWidth()
}

// Прибавить врагу бонус к урону и здоровью
function applyEnemyStatBonus(e, n) {
    e.strength += n
    e.intelligence += n
    e.hp += n
    e.maxHp += n
}

// Раннер последовательностей "анимация -> действие".
// Шаг: { start(ctx), update(ctx) -> done }. Мгновенные шаги (нет update
// или update вернул true) доигрываются в тот же кадр.
// Добавить стадию = вставить элемент в массив шагов.
function SequenceRunner() constructor {
    self.steps = []
    self.i = 0
    self.running = false
    self.ctx = {}

    self.startCurrent = function() {
        var s = self.steps[self.i]
        if (variable_struct_exists(s, "start") && s.start != undefined) s.start(self.ctx)
    }

    self.update = function() {
        var guard = 0
        while (self.running && guard < 64) {
            guard++
            var s = self.steps[self.i]
            var done = (variable_struct_exists(s, "update") && s.update != undefined) ? s.update(self.ctx) : true
            if (!done) break
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

    self.isRunning = function() { return self.running }
}

// Централизованная инициализация глобальных флагов игры
function initGameGlobals() {
    global.safarJoined = (questSpearState() == QuestSpearState.Completed)
    global.walkSound = asset_get_index("GrassWalk")

    global.returningFromBattle = false
    global.fightEnemy = noone

    global.introWalk = false
    global.introTarget = noone
    global.introPendingWalk = false

    global.deckTutStage = DeckTutStage.Inactive

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
