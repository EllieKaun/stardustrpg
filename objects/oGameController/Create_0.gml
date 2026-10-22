randomize()

gpu_set_tex_filter(false)

// Режим отображения: borderless
setDisplayMode = function(fullscreen) {
    global.displayFullscreen = fullscreen
    
    ini_open("settings.ini")
    ini_write_real("Display", "Fullscreen", fullscreen ? 1 : 0)
    var resolutionIndex = ini_read_real("Display", "ResolutionIndex", 2)
    ini_close()

    var resolutions = menuGetResolutions()
    resolutionIndex = min(resolutionIndex, array_length(resolutions) - 1)

    applyWindowMode(resolutions[resolutionIndex][0], resolutions[resolutionIndex][1], fullscreen)
}
// применяем настройки экрана
initDisplaySettings()
uiFontInit() // кэш UI-шрифта и высоты строки
initEffectRegistry() // регистрация эффектов
cardIdsInit() // инициализация карт ид
cardRegistryInit() // регистация карт
global.overworldNeedsReset = false
if (variable_global_exists("startNewGame") && global.startNewGame) {
    global.startNewGame = false
    playerDataNewGame() // новая игра
    global.chestsGenerated = false
    global.chests = []
} else {
    playerDataInit() // инициализация данных пользователя
}
if (!instance_exists(oTransition)) {
    instance_create_layer(0, 0, "Instances", oTransition)
}

initGameGlobals()

partyMembers = [oLana, oViv]
selectedIndex = 0
selected_character = partyMembers[0]

generateChests = function() {
    global.chests = []

    // Спавним сундуки внутри зон спавна (oSpawner) — как врагов: эти зоны всегда в проходимых местах
    var spawners = []
    with (oSpawner) { array_push(spawners, id) }
    if (array_length(spawners) == 0) { return }

    var kinds = [ChestKind.Gold, ChestKind.Card, ChestKind.Enemy]
    var minDist = CHEST_MIN_DISTANCE
    var made = 0
    var attempts = 0
    while (made < CHEST_MAX_COUNT && attempts < 300) {
        attempts++

        var spawner = spawners[irandom(array_length(spawners) - 1)]
        var chestX = spawner.bbox_left + random(spawner.bbox_right - spawner.bbox_left)
        var chestY = spawner.bbox_top  + random(spawner.bbox_bottom - spawner.bbox_top)

        // точка должна быть реально внутри зоны спавна
        if (!collision_point(chestX, chestY, oSpawner, false, true)) { continue }

        // и не на препятствии — иначе герой не наступит и коллизия не сработает
        if (collision_point(chestX, chestY, oWall,   false, true) != noone
         || collision_point(chestX, chestY, oTree1,  false, true) != noone
         || collision_point(chestX, chestY, oTree2,  false, true) != noone
         || collision_point(chestX, chestY, oTree3,  false, true) != noone
         || collision_point(chestX, chestY, oTree4,  false, true) != noone
         || collision_point(chestX, chestY, oTree5,  false, true) != noone
         || collision_point(chestX, chestY, oStump,  false, true) != noone) { continue }

        var tooClose = false
        for (var chestIndex = 0; chestIndex < array_length(global.chests); chestIndex++) {
            if (point_distance(chestX, chestY, global.chests[chestIndex].x, global.chests[chestIndex].y) < minDist) {
                tooClose = true
                break
            }
        }
        if (tooClose) { continue }

        array_push(global.chests, {
            x: chestX,
            y: chestY,
            kind: kinds[irandom(2)],
            opened: false
        })
        made++
    }
}

spawnChests = function() {
    with (oChest) instance_destroy()
    for (var chestIndex = 0; chestIndex < array_length(global.chests); chestIndex++) {
        var chest = global.chests[chestIndex]
        if (chest.opened) { continue }
        var chestInstance = instance_create_layer(chest.x, chest.y, "Instances", oChest)
        chestInstance.chestKind = chest.kind
        chestInstance.chestIndex = chestIndex
    }
}

startTutorialIntro = function() {
    var leader = selected_character
    if (!instance_exists(leader)) { return }
    var obstacles = worldObstacles()
    var distance = 120
    var directionAngles = [0, 90, 270, 180, 45, 315, 135, 225]
    var spawnX = leader.x + distance
    var spawnY = leader.y
    for (var dirIndex = 0; dirIndex < array_length(directionAngles); dirIndex++) {
        var candidateX = leader.x + lengthdir_x(distance, directionAngles[dirIndex])
        var candidateY = leader.y + lengthdir_y(distance, directionAngles[dirIndex])
        if (candidateX < 48 || candidateY < 48 || candidateX > room_width - 48 || candidateY > room_height - 48) { continue }
        if (collision_line(leader.x, leader.y, candidateX, candidateY, obstacles, true, true) == noone) {
            spawnX = candidateX
            spawnY = candidateY
            break
        }
    }
    var enemy = instance_create_layer(spawnX, spawnY, "Instances", oCrakerNutSmall)
    enemy.spawnedDynamically = true
    enemy.shouldWalk = false
    enemy.getEncounter = function() { return tutorialEncounter() }
    global.introTarget = enemy
    global.introWalk = true
}

// Вход в бой
battleStartSprite = function() {
    var asset = asset_get_index("BattleStart")
    return (asset >= 0 && sprite_exists(asset)) ? asset : noone
}

battleEntryState = BattleEntryState.Idle
entryAnimSprite = noone
entryAnimFrame = 0
entryIntroSprite = noone
entryTargetRoom = noone

entryAnimFramesPerStep = function(spr) {
    var spd = sprite_get_speed(spr)
    if (sprite_get_speed_type(spr) == spritespeed_framespersecond) { spd /= game_get_speed(gamespeed_fps) }
    if (spd <= 0) { spd = sprite_get_number(spr) / (1.5 * game_get_speed(gamespeed_fps)) }
    return spd
}

changeBattleEntryState = function(newState) {
    if (battleEntryState == newState) { return }
    battleEntryState = newState
    switch (battleEntryState) {
        case BattleEntryState.Intro:
            entryAnimSprite = entryIntroSprite
            entryAnimFrame = 0
            global.cutsceneActive = true
            global.uiModal = true
        break
        case BattleEntryState.Transition:
            entryAnimSprite = battleStartSprite()
            entryAnimFrame = 0
            global.cutsceneActive = true
            global.uiModal = true
        break
        case BattleEntryState.Idle:
            global.cutsceneActive = false
            global.uiModal = false
        break
    }
}

startFadeToBattle = function() {
    changeBattleEntryState(BattleEntryState.Idle)
    with (oTransition) {
        target_room = oGameController.entryTargetRoom
        state = "fade_out"
    }
}

goToBattleAfterTransition = function() {
    battleEntryState = BattleEntryState.Leaving
    room_goto(entryTargetRoom)
}

beginBattleEntry = function(introSprite, targetRoom) {
    entryIntroSprite = introSprite
    entryTargetRoom = targetRoom
    if (introSprite != noone && introSprite != undefined && sprite_exists(introSprite)) {
        changeBattleEntryState(BattleEntryState.Intro)
    } else if (battleStartSprite() != noone) {
        changeBattleEntryState(BattleEntryState.Transition)
    } else {
        startFadeToBattle()
    }
}
global.zoneConfig = { // нужно для определение секций и зон на карте
    cx: room_width / 2,
    cy: room_height / 2,
    innerHalf:  240, // ширина внутренней зоны
    middleHalf: 480  // ширина средней зоны
}

// Последовательность следования персонажей
followSequence = function() {
    var sequence = [selected_character]
    var partyNumber = array_length(partyMembers)
    for (var index = 1; index < partyNumber; index++) {
        array_push(sequence, partyMembers[(selectedIndex + index) mod partyNumber])
    }
    var companionObject = companionWorldObject(activeCompanion())
    if (companionObject != noone && instance_exists(companionObject)) {
        array_push(sequence, companionObject)
    }
    return sequence
}

followTargetOfMember = function(member) {
    var sequence = followSequence()
    for (var index = 1; index < array_length(sequence); index++) {
        if (member.object_index == sequence[index]) {
            return sequence[index - 1]
        }
    }
    return selected_character
}

switchCharacter = function() {
    if (global.uiModal) {
        return
    }
    selectedIndex = (selectedIndex + 1) % array_length(partyMembers)
    selected_character = partyMembers[selectedIndex]
}