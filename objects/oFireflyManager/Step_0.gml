if (global.gamePaused) { exit }
if (variable_global_exists("introWalk") && global.introWalk) { exit }
if (variable_global_exists("deckTutorialStage") && global.deckTutorialStage != DeckTutorialStage.Inactive && global.deckTutorialStage != DeckTutorialStage.Done) { exit }
if (!isNight()) { exit }

spawnTimer++
if (spawnTimer < FIREFLY_SPAWN_INTERVAL) { exit }
spawnTimer = 0

if (instance_number(oFirefly) >= fireflyLimit()) { exit }

var point = randomSpawnerPoint(0, FIREFLY_DESPAWN_DISTANCE - 40)
if (point == undefined) { exit }

var firefly = instance_create_layer(point.x, point.y, "Instances", oFirefly)
firefly.homeSpawner = point.spawner