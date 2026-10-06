triggered = false
isIgnited = false
kind = worldEnemyKind(object_index)
igniteSprite = worldIgniteSprite(kind)
my_spawner = noone
spawnedDynamically = false
carriesSpear = false
canCarrySpear = true // может ли передавать копье
carriesCauldron = false
canCarryCauldron = true
rearmDistance = 48 // на сколько отойти, чтобы снова можно было драться

shouldWalk = true
homeX = x
homeY = y
patrolAxis = choose(0, 1)
patrolDir = choose(-1, 1)
patrolAmp = 24
patrolSpeed = 0.3
patrolStuckSteps = 0 // сколько шагов подряд не удалось сдвинуться
patrolAxisSwitches = 0 // сколько раз подряд меняли ось из-за застревания
show_debug_message("----- Created EnemyObject at position " + string(x) + " " + string(y))
spawnSection = Section.TopLeft
getEncounter = function() {
    return randomSectionEncounter(spawnSection)
}
