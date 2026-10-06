if (global.gamePaused) { exit }
if (variable_global_exists("introWalk") && global.introWalk) { exit }
if (variable_global_exists("deckTutorialStage") && global.deckTutorialStage != DeckTutorialStage.Inactive && global.deckTutorialStage != DeckTutorialStage.Done) { exit }
if (!isNight()) { exit }

spawnTimer++
if (spawnTimer < FIREFLY_SPAWN_INTERVAL) { exit }
spawnTimer = 0

if (instance_number(oFirefly) >= fireflyLimit()) { exit }

var point = randomSpawnerPoint(0, FIREFLY_SPAWN_DISTANCE)
if (point == undefined) { exit }

// Не спавним рядом с уже существующим светлячком
var pointX = point.x
var pointY = point.y
var tooClose = false
with (oFirefly) {
    if (point_distance(x, y, pointX, pointY) < FIREFLY_MIN_SPACING) {
        tooClose = true
        break
    }
}
if (tooClose) { exit }

var firefly = instance_create_layer(point.x, point.y, "Instances", oFirefly)
firefly.homeSpawner = point.spawner