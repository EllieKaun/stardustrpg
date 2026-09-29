
if (global.gamePaused) { exit }

if (global.uiModal) { exit }
if (variable_global_exists("cutsceneActive") && global.cutsceneActive) { exit }

depth = -bbox_bottom

// Квест не активен (копьё уже украдено / квест завершён) - моб больше не носитель
if (carriesSpear && questSpearState() != QuestSpearState.Active) {
    carriesSpear = false
    image_blend = c_white
    global.spearCarrierExists = false
}

if (canCarrySpear && !carriesSpear && questSpearState() == QuestSpearState.Active && !global.spearCarrierExists) {
    carriesSpear = true
    global.spearCarrierExists = true
    if (spearSprite() == noone) { image_blend = c_yellow }
}

var leader = oGameController.selected_character
if (!instance_exists(leader)) { exit }

// логика прогулки
if (!triggered && shouldWalk) {
    var minX = homeX - patrolAmp, maxX = homeX + patrolAmp
    var minY = homeY - patrolAmp, maxY = homeY + patrolAmp
    if (instance_exists(my_spawner)) {
        minX = max(minX, my_spawner.bbox_left) 
        maxX = min(maxX, my_spawner.bbox_right)
        minY = max(minY, my_spawner.bbox_top) 
        maxY = min(maxY, my_spawner.bbox_bottom)
    }
    var moved = false
    if (patrolAxis == 0) {
        var nextX = x + patrolDir * patrolSpeed
        if (nextX < minX || nextX > maxX || place_meeting(nextX, y, oWall)) { patrolDir = -patrolDir }
        else { 
            x = nextX
            moved = true 
        }
        image_xscale = (patrolDir < 0) ?  1 : -1
    } else {
        var nextY = y + patrolDir * patrolSpeed
        if (nextY < minY || nextY > maxY || place_meeting(x, nextY, oWall)) { patrolDir = -patrolDir }
        else { 
            y = nextY
            moved = true 
        }
    }

    // Упёрлись в обе стороны оси (например, стоим у стены) - пробуем другую ось,
    // а если и там некуда идти, просто стоим, а не вертимся на месте
    if (moved) {
        patrolStuckSteps = 0
        patrolAxisSwitches = 0
    } else {
        patrolStuckSteps++
        if (patrolStuckSteps >= 2) {
            patrolStuckSteps = 0
            patrolAxis = 1 - patrolAxis
            patrolAxisSwitches++
            if (patrolAxisSwitches >= 2) { shouldWalk = false }
        }
    }
}

if (place_meeting(x, y, leader)) {
    if (!triggered) {
        triggered = true
        global.fightEnemy = id
        global.returningFromBattle = true
        global.battleNoFlee = false
        // spearCarrierExists не сбрасываем: носитель остаётся на карте, если от него убежали или проиграли.
        // Флаг сбросит кража копья (questGrantSpear) или удаление носителя (Destroy)
        if (carriesSpear) { global.battleHasSpear = true }
        global.battleSection = spawnSection
        global.battleEncounter = getEncounter()
        global.returnRoom = room
        global.returnX = leader.x
        global.returnY = leader.y
        leader.can_move = false

        // Проверка на наличие катсцены. если есть, сначала проигрываем ее
        var encounter = global.battleEncounter
        var intro = variable_struct_exists(encounter, "introSprite") ? encounter.introSprite : undefined
        var started = false
        if (intro != undefined && intro != noone && instance_exists(oGameController)) {
            started = oGameController.startBossCutscene(intro, BattleRoom)
        }
        if (!started) {
            with (oTransition) {
                target_room = BattleRoom
                state = "fade_out"
            }
        }
    }
} else {
    var distance = point_distance(x, y, leader.x, leader.y)
    if (triggered && distance > rearmDistance) { triggered = false }
    if (spawnedDynamically && distance > oSpawnerManager.spawnDistance) {
        if (carriesSpear) { global.spearCarrierExists = false }
        instance_destroy()
    }
}