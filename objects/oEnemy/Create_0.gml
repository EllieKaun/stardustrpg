triggered = false
my_spawner = noone
show_debug_message("----- Created EnemyObject at position " + string(x) + " " + string(y))
spawnSection = 1
// oEnemy (parent) Create
getEncounter = function() {
    return randomSectionEncounter(spawnSection)
}