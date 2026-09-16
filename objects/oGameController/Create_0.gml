randomize()

gpu_set_tex_filter(false)

// Режим отображения: borderless
setDisplayMode = function(fullscreen) {
    global.displayFullscreen = fullscreen
    
    ini_open("settings.ini")
    ini_write_real("Display", "Fullscreen", fullscreen ? 1 : 0)
    var resInd = ini_read_real("Display", "ResolutionIndex", 2)
    ini_close()

    var res = menuGetResolutions()
    resInd = min(resInd, array_length(res) - 1)

    applyWindowMode(res[resInd][0], res[resInd][1], fullscreen)
    display_set_gui_size(res[resInd][0], res[resInd][1])
}
// применяем настройки экрана
initDisplaySettings()
uiFontInit() // кэш UI-шрифта и высоты строки
initEffectRegistry() // регистрация эффектов
cardIdsInit() // инициализация карт ид
cardRegistryInit() // регистация карт  
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
    var trees = []
    with (oTree1) array_push(trees, id)
    with (oTree2) array_push(trees, id)
    with (oTree3) array_push(trees, id)
    with (oTree4) array_push(trees, id)
    with (oTree5) array_push(trees, id)

    var kinds = [ChestKind.Gold, ChestKind.Card, ChestKind.Enemy]
    var minDist = CHEST_MIN_DISTANCE
    var made = 0
    var attempts = 0
    while (made < CHEST_MAX_COUNT && attempts < 300) {
        attempts++
        var cx, cy
        if (array_length(trees) > 0 && irandom(1) == 0) {
            var t = trees[irandom(array_length(trees) - 1)]
            if (!instance_exists(t)) continue
            cx = t.x
            cy = t.bbox_bottom + 8 // у основания дерева, на проходимой земле
        } else {
            cx = 96 + random(room_width - 192)
            cy = 96 + random(room_height - 192)
        }
        if (cx < 48 || cy < 48 || cx > room_width - 48 || cy > room_height - 48) continue

        // Позиция должна быть проходимой — иначе герой не наступит и коллизия не сработает
        if (collision_point(cx, cy, oWall,   false, true) != noone
         || collision_point(cx, cy, oTree1,  false, true) != noone
         || collision_point(cx, cy, oTree2,  false, true) != noone
         || collision_point(cx, cy, oTree3,  false, true) != noone
         || collision_point(cx, cy, oTree4,  false, true) != noone
         || collision_point(cx, cy, oTree5,  false, true) != noone
         || collision_point(cx, cy, oStump,  false, true) != noone) continue

        var tooClose = false
        for (var i = 0; i < array_length(global.chests); i++) {
            if (point_distance(cx, cy, global.chests[i].x, global.chests[i].y) < minDist) {
                tooClose = true
                break
            }
        }
        if (tooClose) continue

        array_push(global.chests, {
            x: cx,
            y: cy,
            kind: kinds[irandom(2)],
            opened: false
        })
        made++
    }
}

spawnChests = function() {
    with (oChest) instance_destroy()
    for (var i = 0; i < array_length(global.chests); i++) {
        var ch = global.chests[i]
        if (ch.opened) continue
        var c = instance_create_layer(ch.x, ch.y, "Instances", oChest)
        c.chestKind = ch.kind
        c.chestIndex = i
    }
}

startTutorialIntro = function() {
    var leader = selected_character
    if (!instance_exists(leader)) return
    var obstacles = worldObstacles()
    var dist = 120
    var dirs = [0, 90, 270, 180, 45, 315, 135, 225]
    var tx = leader.x + dist
    var ty = leader.y
    for (var i = 0; i < array_length(dirs); i++) {
        var cx = leader.x + lengthdir_x(dist, dirs[i])
        var cy = leader.y + lengthdir_y(dist, dirs[i])
        if (cx < 48 || cy < 48 || cx > room_width - 48 || cy > room_height - 48) continue
        if (collision_line(leader.x, leader.y, cx, cy, obstacles, true, true) == noone) {
            tx = cx
            ty = cy
            break
        }
    }
    var e = instance_create_layer(tx, ty, "Instances", oCrakerNutSmall)
    e.spawnedDynamically = true
    e.shouldWalk = false
    e.getEncounter = function() { return tutorialEncounter() }
    global.introTarget = e
    global.introWalk = true
}

// Катсцена появления босса
cutsceneSprite = noone
cutsceneFrame = 0
cutsceneTargetRoom = noone

// Запустить катсцену. Возвращает true, если катсцена запущена
startBossCutscene = function(spr, targetRoom) {
    if (spr == noone || spr == undefined || !sprite_exists(spr)) return false
    cutsceneSprite = spr
    cutsceneFrame = 0
    cutsceneTargetRoom = targetRoom
    global.cutsceneActive = true
    global.uiModal = true // блокируем открытие меню/деки/паузы
    return true
}
global.zoneConfig = { // нужно для определение секций и зон на карте
    cx: room_width / 2,
    cy: room_height / 2,
    innerHalf:  240, // ширина внутренней зоны
    middleHalf: 480  // ширина средней зоны
}
switchCharacter = function() {
    if (global.uiModal) {
        return
    }
    selectedIndex = (selectedIndex + 1) % array_length(partyMembers)
    selected_character = partyMembers[selectedIndex]
}