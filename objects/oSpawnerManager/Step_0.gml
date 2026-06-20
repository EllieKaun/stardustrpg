
for (var i = ds_list_size(enemyList) - 1; i >= 0; i--) {
    if (!instance_exists(enemyList[| i])) {
        ds_list_delete(enemyList, i)
    }
} // чистка массива на случай если удалились объекты с экрана

spawnTimer++
if (spawnTimer < spawnInterval) exit
spawnTimer = 0
if (ds_list_size(enemyList) >= maxEnemies) exit // если уже максимальное количество врагов останавливаемся
if (!instance_exists(oLana)) exit // Сейчас спавн идет от ланы, надо сделать универсально
var px = oLana.x
var py = oLana.y

var spawners = ds_list_create() // спавнеры на карте
with (oSpawner) {
    ds_list_add(spawners, id)
}
if (ds_list_size(spawners) == 0) {
    ds_list_destroy(spawners)
    exit
}

// Процесс спавна врага
for (var attempt = 0; attempt < maxSpawnAttempts; attempt++) {

    var seg = spawners[| irandom(ds_list_size(spawners) - 1)] // берем случайный спавнер

    var sx = seg.bbox_left + random(seg.bbox_right - seg.bbox_left) // случайные коордианты на спавнере
    var sy = seg.bbox_top  + random(seg.bbox_bottom - seg.bbox_top)

    if (!collision_point(sx, sy, oSpawner, false, true)) { // если в этих координатах нет спавнера - ошибка
        show_debug_message("CREATING ENEMY ERROR: POINT IS NOT IN SPAWNER ZONE" + string(sx) + " " + string(sy))
        continue
    }
    
    var dist = point_distance(px, py, sx, sy) 
    if (dist > spawnDistance) { // если дальше дистанции спавна - ошибка
        show_debug_message("CREATING ENEMY ERROR: POINT IS NOT IN SPAWN DISTANCE")
        continue
    }

    if (dist < visionRadius) { // если в рамках видимости - ошибка
        show_debug_message("CREATING ENEMY ERROR: POINT IS IN VISION")
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
        show_debug_message("CREATING ENEMY ERROR: POINT IS IN OTHER ENEMY DISTANCE")
        continue
    }

    var zone = zoneAt(sx, sy) // определяем в какой зоне (внешняя, cредняя или внутренняя)
    var section = sectionAt(sx, sy) // определяем секцию (верх-право верх-лево и тд)
    var types = enemyTypesForRegion(zone, section) // определяем каких мини врагов можем там спавнить
    var chosenType = types[irandom(array_length(types) - 1)] // случайным образом из доступных
    show_debug_message("CREATING ENEMY ZONE: " + string(zone)) 
    show_debug_message("CREATING ENEMY SECTION: " + string(section))
    show_debug_message("CREATING ENEMY MONSTER TYPE: " + string(chosenType))
    var enemy = instance_create_layer(sx, sy, "Instances", chosenType) // создаем мини врага
    enemy.spawnSection = sectionAt(sx, sy) // определение секции 
    ds_list_add(enemyList, enemy)
    show_debug_message("CREATING ENEMY SUCCESS") 
    ds_list_destroy(spawners)
    exit
}
ds_list_destroy(spawners)