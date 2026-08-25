
if (global.gamePaused) exit

depth = -bbox_bottom 

var leader = oGameController.selected_character
if (!instance_exists(leader)) exit

// логика прогулки
if (!triggered && shouldWalk) {
    var minX = homeX - patrolAmp, maxX = homeX + patrolAmp
    var minY = homeY - patrolAmp, maxY = homeY + patrolAmp
    if (instance_exists(my_spawner)) {
        minX = max(minX, my_spawner.bbox_left) 
        maxX = min(maxX, my_spawner.bbox_right)
        minY = max(minY, my_spawner.bbox_top) 
        maxY = min(maxY, my_spawner.bbox_bottom)
    }
    if (patrolAxis == 0) {
        var nx = x + patrolDir * patrolSpeed
        if (nx < minX || nx > maxX || place_meeting(nx, y, oWall)) patrolDir = -patrolDir
        else x = nx
        image_xscale = (patrolDir < 0) ?  1 : -1
    } else {
        var ny = y + patrolDir * patrolSpeed
        if (ny < minY || ny > maxY || place_meeting(x, ny, oWall)) patrolDir = -patrolDir
        else y = ny
    }
}

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
    if (triggered && d > rearmDistance) triggered = false
    if (spawnedDynamically && d > oSpawnerManager.spawnDistance) instance_destroy()
}