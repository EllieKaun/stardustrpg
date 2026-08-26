
if (global.gamePaused) exit // на паузе спавн полностью остановлен

for (var i = ds_list_size(enemyList) - 1; i >= 0; i--) {
    if (!instance_exists(enemyList[| i])) {
        ds_list_delete(enemyList, i)
    }
} // чистка массива на случай если удалились объекты с экрана

// Стартовый флоу: на новой игре первого врага показываем сразу в зоне видимости.
// Пока он не появился — обычный спавн не запускаем.
if (!tutorialSpawnDone) {
    if (ds_list_size(enemyList) < maxEnemies && trySpawnEnemy(tutorialMinDist, tutorialMaxDist)) {
        tutorialSpawnDone = true
        global.isNewGame = false // стартовый враг показан — больше не повторяем
        spawnTimer = 0
    }
    exit
}

spawnTimer++
if (spawnTimer < spawnInterval) exit

// Если врагов уже максимум — ждём следующий интервал 
if (ds_list_size(enemyList) >= maxEnemies) {
    spawnTimer = 0
    exit
}

// Пытаемся заспавнить вне зоны видимости
if (trySpawnEnemy(visionRadius, spawnDistance)) {
    spawnTimer = 0
}
