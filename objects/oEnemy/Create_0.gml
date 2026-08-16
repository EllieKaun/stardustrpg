triggered = false
my_spawner = noone
spawnedDynamically = false // true у заспавненных; ручные (из редактора) остаются false
rearmDistance = 48 // на сколько отойти, чтобы снова можно было драться
show_debug_message("----- Created EnemyObject at position " + string(x) + " " + string(y))
spawnSection = Section.TopLeft
// oEnemy (parent) Create
getEncounter = function() {
    return randomSectionEncounter(spawnSection)
}