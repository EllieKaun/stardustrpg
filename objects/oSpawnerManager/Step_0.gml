
if (global.gamePaused) { exit } // на паузе спавн полностью остановлен
if (variable_global_exists("introWalk") && global.introWalk) { exit }
if (variable_global_exists("deckTutorialStage") && global.deckTutorialStage != DeckTutorialStage.Inactive && global.deckTutorialStage != DeckTutorialStage.Done) { exit }

for (var i = ds_list_size(enemyList) - 1; i >= 0; i--) {
    if (!instance_exists(enemyList[| i])) {
        ds_list_delete(enemyList, i)
    }
} // чистка массива на случай если удалились объекты с экрана

for (var i = ds_list_size(pineconeList) - 1; i >= 0; i--) {
    if (!instance_exists(pineconeList[| i])) { ds_list_delete(pineconeList, i) }
}
if (questFoxState() == QuestFoxState.Active && !questFoxItemDone(QuestFoxItem.PineCone)) {
    var wantCones = FOX_PINE_CONES_IN_WORLD
    if (ds_list_size(pineconeList) < wantCones) {
        pineconeSpawnTimer++
        if (pineconeSpawnTimer >= pineconeSpawnInterval) {
            if (trySpawnPinecone(visionRadius, spawnDistance)) { pineconeSpawnTimer = 0 }
        }
    }
} else {
    for (var i = ds_list_size(pineconeList) - 1; i >= 0; i--) {
        if (instance_exists(pineconeList[| i])) { instance_destroy(pineconeList[| i]) }
        ds_list_delete(pineconeList, i)
    }
}

// Стартовый флоу: на новой игре первого врага показываем сразу в зоне видимости
if (!tutorialSpawnDone) {
    if (ds_list_size(enemyList) < maxEnemies && trySpawnEnemy(tutorialMinDist, tutorialMaxDist)) {
        tutorialSpawnDone = true
        global.isNewGame = false // стартовый враг показан — больше не повторяем
        spawnTimer = 0
    }
    exit
}

spawnTimer++
if (spawnTimer < spawnInterval) { exit }

// Если врагов уже максимум — ждём следующий интервал 
if (ds_list_size(enemyList) >= maxEnemies) {
    spawnTimer = 0
    exit
}

// Пытаемся заспавнить вне зоны видимости
if (trySpawnEnemy(visionRadius, spawnDistance)) {
    spawnTimer = 0
}
