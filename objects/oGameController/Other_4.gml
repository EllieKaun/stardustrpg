guiSyncCrisp()

// Инициализация сетки MP
var cell = 16
var cols = ceil(room_width  / cell)
var rows = ceil(room_height / cell)

if (global.mpGrid != -1) {
    mp_grid_destroy(global.mpGrid)
}
global.mpGrid = mp_grid_create(0, 0, cols, rows, cell, cell)
var obstacles = [oWall, oTree1, oTree2, oTree3, oTree4, oTree5, oBush, oStump]
for (var i = 0; i < array_length(obstacles); i++) {
    mp_grid_add_instances(global.mpGrid, obstacles[i], false)
}

playMusicNamed("ForestDayMusic")
playAmbientNamed("ForestAmbience")

// Возврат из боя
if (global.returningFromBattle) {
    global.returningFromBattle = false
    global.introWalk = false
    if (instance_exists(selected_character)) {
        selected_character.can_move = true
        selected_character.x = global.returnX
        selected_character.y = global.returnY
    }
    if (instance_exists(global.fightEnemy) && global.fightEnemy.spawnedDynamically) {
        instance_destroy(global.fightEnemy)
    }
    global.fightEnemy = noone
}

if (global.isNewGame && !tutorialIsDone()) {
    global.isNewGame = false
    with (oSpawnerManager) tutorialSpawnDone = true
    global.introPendingWalk = true
    if (instance_exists(oDialogManager)) {
        say(tutorialOverworldLines())
    }
}

if (tutorialIsDone() && !deckTutorialIsDone() && global.deckTutorialStage == DeckTutorialStage.Inactive) {
    global.deckTutorialStage = DeckTutorialStage.Dialog
    if (instance_exists(oDialogManager)) {
        say(deckTutorialIntroLines())
    }
}

if (!global.chestsGenerated) {
    generateChests()
    global.chestsGenerated = true
}
spawnChests()