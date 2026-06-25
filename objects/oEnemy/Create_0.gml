triggered = false
my_spawner = noone
show_debug_message("----- Created EnemyObject at position " + string(x) + " " + string(y))
spawnSection = Section.TopLeft
// oEnemy (parent) Create
getEncounter = function() {
    return randomSectionEncounter(spawnSection)
}