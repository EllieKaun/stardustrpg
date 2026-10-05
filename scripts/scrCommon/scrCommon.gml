//// Константы и общие функции

// Сундуки
#macro CHEST_MAX_COUNT 5 // максимальное количество сундуков на карте
#macro CHEST_MIN_DISTANCE 180 // минимальная дистанция между сундуками
#macro CHEST_INTERACT_DIST 24 //

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
function applyEnemyStatBonus(enemy, points, weights = undefined) {
    var w = weights ?? { strength: 1, intelligence: 1, hp: 1, maxHp: 1 }
    enemy.strength += points * w.strength
    enemy.intelligence += points * w.intelligence
    enemy.hp += points * w.hp
    enemy.maxHp += points * w.maxHp
}

// Раннер анимация и действий после их проигрывания
// Шаг: { start(ctx), update(ctx) -> done }
function SequenceRunner() constructor {
    self.steps = []
    self.i = 0
    self.running = false
    self.ctx = {}

    self.startCurrent = function() {
        var step = self.steps[self.i]
        if (variable_struct_exists(step, "start") && step.start != undefined) {
            step.start(self.ctx)
        }
    }

    self.update = function() {
        var guard = 0
        while (self.running && guard < 64) {
            guard++
            var step = self.steps[self.i]
            var done = (variable_struct_exists(step, "update") && step.update != undefined) ? step.update(self.ctx) : true
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

// Билдеры шагов для SequenceRunner. Каждый возвращает { start(ctx), update(ctx) -> done }.
// Шаг без update завершается сразу; с update — держится, пока update не вернёт true.

// Выполнить действие и сразу продолжить.
function stepDo(action) {
    return { start: action }
}

// Проиграть анимацию актёра и продолжить, когда она завершится.
function stepActorAnim(actor, state, spriteOverride = noone) {
    return {
        actor: actor,
        state: state,
        spr: spriteOverride,
        done: false,
        start: function(ctx) {
            self.done = false
            self.actor.changeActionState(self.state, method(self, function() { self.done = true }), self.spr)
        },
        update: function(ctx) { return self.done }
    }
}

// Пауза на N кадров.
function stepWait(frames) {
    return {
        frames: frames,
        left: 0,
        start: function(ctx) { self.left = self.frames },
        update: function(ctx) { self.left -= 1; return self.left <= 0 }
    }
}

// Сколько кадров играет спрайт один раз (при image_speed = 1)
function spritePlayFrames(spr) {
    if (spr == noone || !sprite_exists(spr)) { return 0 }
    var frames = sprite_get_number(spr)
    var spd = sprite_get_speed(spr)
    if (sprite_get_speed_type(spr) == spritespeed_framespersecond) {
        spd = spd / game_get_speed(gamespeed_fps)
    }
    if (spd <= 0) { spd = 1 }
    return ceil(frames / spd)
}

// Ждать, пока полоски хп/маны целей доиграют (длительность определяется сама)
function stepWaitBars(targets) {
    return {
        targets: targets,
        elapsed: 0,
        start: function(ctx) { self.elapsed = 0 },
        update: function(ctx) {
            self.elapsed += 1
            if (self.elapsed > 120) { return true } // предохранитель от зависания
            var list = is_array(self.targets) ? self.targets : [self.targets]
            for (var i = 0; i < array_length(list); i++) {
                var t = list[i]
                if (!instance_exists(t)) { continue }
                if (abs(t.displayHp - t.hp) >= 0.5) { return false }
                if (abs(t.displayMana - t.mana) >= 0.5) { return false }
            }
            return true
        }
    }
}

// инициализация глобальных переменных игры
function initGameGlobals() {
    global.safarJoined = (questSpearState() == QuestSpearState.Completed) 
    global.safarJoined = (questFoxState() == QuestFoxState.Completed)
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
    global.battleIsNight = false // снимается на входе в бой
    global.battleIsIgnited = false // ставит ignite-враг на триггере боя
    global.battleEnemyFirst = false // враги ходят первыми

    global.mpGrid = -1
    global.battleSection = 1
    global.uiModal = false
    global.gamePaused = false
    global.cutsceneActive = false
    global.suppressEffectVisual = false

    if (!variable_global_exists("chestsGenerated")) {
        global.chestsGenerated = false
        global.chests = []
    }
    
    global.timeOfDay = 0.5 // Полдень
    global.timeSpeed = 1 / 360 // Скорость  движения времени
    global.timePaused = false // Можно остановить изменение времени
    
     if (!instance_exists(oLighting)) { instance_create_depth(0, 0, -100000, oLighting) }
}

function startTransition(targetRoom) {
    with (oTransition) {
        target_room = targetRoom
        state = "fade_out"
    }
}
