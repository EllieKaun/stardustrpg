
if (global.gamePaused) exit 

var leader = oGameController.selected_character
if (!instance_exists(leader)) exit
if (place_meeting(x, y, leader)) {
    if (!triggered) {
        triggered = true
        global.fightEnemy = id
        global.returningFromBattle = true
        global.battleSection = spawnSection
        global.battleEncounter = getEncounter()
        global.returnRoom = room
        global.returnX = leader.x
        global.returnY = leader.y
        leader.can_move = false
        with (oTransition) {
            target_room = BattleRoom
            state = "fade_out"
        }
    }
} else {
    var d = point_distance(x, y, leader.x, leader.y)
    if (triggered && d > rearmDistance) triggered = false // отошёл -> снова можно драться
    if (spawnedDynamically && d > oSpawnerManager.spawnDistance) instance_destroy()
}