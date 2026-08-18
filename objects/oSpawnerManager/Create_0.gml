maxEnemies = 12
spawnInterval = 90 // Задержка между спавном врагов
minEnemySpacing = 96 // Минимальное расстояние между врагами
visionRadius = 200 // Размер области видимости игрока (не уверен точно какое значение)
spawnDistance = 500 // Расстояние от игрока в котором можно спавнить врагов
maxSpawnAttempts = 30

spawnTimer = 0
enemyList = ds_list_create() // Список заспавненных врагов

// Логи спавна
spawnDebug = false

// Стартовый флоу: на новой игре первого врага показываем сразу и в зоне
// видимости игрока , чтобы он появился на экране за первые секунды.
// В обычной игре стартового спавна нет — сразу считаем его выполненным.
tutorialSpawnDone = !(variable_global_exists("isNewGame") && global.isNewGame)
tutorialMinDist = 64  // не вплотную к игроку
tutorialMaxDist = 140 // в пределах экрана (полу-ширина вида = 160)

// Попытка заспавнить врага в кольце [minDist, maxDist] от игрока.
// Возвращает true при успешном спавне.
trySpawnEnemy = function(minDist, maxDist) {
    var leader = oGameController.selected_character
    if (!instance_exists(leader)) return false
    var px = leader.x
    var py = leader.y

    var spawners = ds_list_create() // спавнеры на карте
    with (oSpawner) {
        ds_list_add(spawners, id)
    }
    if (ds_list_size(spawners) == 0) {
        ds_list_destroy(spawners)
        return false
    }

    var spawned = false

    // Процесс спавна врага
    for (var attempt = 0; attempt < maxSpawnAttempts; attempt++) {

        var seg = spawners[| irandom(ds_list_size(spawners) - 1)] // берем случайный спавнер

        var sx = seg.bbox_left + random(seg.bbox_right - seg.bbox_left) // случайные коордианты на спавнере
        var sy = seg.bbox_top  + random(seg.bbox_bottom - seg.bbox_top)

        if (!collision_point(sx, sy, oSpawner, false, true)) { // если в этих координатах нет спавнера - ошибка
            if (spawnDebug) show_debug_message("CREATING ENEMY ERROR: POINT IS NOT IN SPAWNER ZONE" + string(sx) + " " + string(sy))
            continue
        }

        var dist = point_distance(px, py, sx, sy)
        if (dist > maxDist) { // если дальше допустимой дистанции - ошибка
            if (spawnDebug) show_debug_message("CREATING ENEMY ERROR: POINT IS NOT IN SPAWN DISTANCE")
            continue
        }

        if (dist < minDist) { // если ближе допустимой дистанции - ошибка
            if (spawnDebug) show_debug_message("CREATING ENEMY ERROR: POINT IS TOO CLOSE")
            continue
        }

        var tooClose = false
        for (var i = 0; i < ds_list_size(enemyList); i++) {
            var _other = enemyList[| i]
            if (instance_exists(_other)) {
                if (point_distance(sx, sy, _other.x, _other.y) < minEnemySpacing) {
                    tooClose = true
                    break
                }
            }
        }

        if (tooClose) { // если слишком близко к существующему врагу - ошибка
            if (spawnDebug) show_debug_message("CREATING ENEMY ERROR: POINT IS IN OTHER ENEMY DISTANCE")
            continue
        }

        var zone = zoneAt(sx, sy) // определяем в какой зоне (внешняя, cредняя или внутренняя)
        var section = sectionAt(sx, sy) // определяем секцию (верх-право верх-лево и тд)
        var types = enemyTypesForRegion(zone, section) // определяем каких мини врагов можем там спавнить
        var chosenType = types[irandom(array_length(types) - 1)] // случайным образом из доступных
        if (spawnDebug) {
            show_debug_message("CREATING ENEMY ZONE: " + string(zone))
            show_debug_message("CREATING ENEMY SECTION: " + string(section))
            show_debug_message("CREATING ENEMY MONSTER TYPE: " + string(chosenType))
        }
        var enemy = instance_create_layer(sx, sy, "Instances", chosenType) // создаем мини врага
        enemy.spawnSection = sectionAt(sx, sy) // определение секции
        enemy.spawnedDynamically = true // заспавненный (не из редактора) -> удаляется после боя
        ds_list_add(enemyList, enemy)
        if (spawnDebug) show_debug_message("CREATING ENEMY SUCCESS")
        spawned = true
        break
    }

    ds_list_destroy(spawners)
    return spawned
}
