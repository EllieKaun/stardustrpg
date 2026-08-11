
if (global.gamePaused) exit // на паузе враги заморожены

if (!position_meeting(x, y, oLana)) {
    if (point_distance(x, y, oLana.x, oLana.y) > oSpawnerManager.spawnDistance) {
        instance_destroy()
    }
}