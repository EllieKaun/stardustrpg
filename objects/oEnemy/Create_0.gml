triggered = false
my_spawner = noone
spawnedDynamically = false 
rearmDistance = 48 // на сколько отойти, чтобы снова можно было драться

shouldWalk = true
homeX = x
homeY = y
patrolAxis = choose(0, 1) 
patrolDir = choose(-1, 1)
patrolAmp = 24 
patrolSpeed = 0.3
show_debug_message("----- Created EnemyObject at position " + string(x) + " " + string(y))
spawnSection = Section.TopLeft
getEncounter = function() {
    return randomSectionEncounter(spawnSection)
}