triggered = false
isIgnited = false
nightIgniteRolled = false
kind = worldEnemyKind(object_index)
igniteSprite = worldIgniteSprite(kind)

becomeIgnited = function() {
    isIgnited = true
    if (igniteSprite != noone) {
        sprite_index = igniteSprite
        mask_index = igniteSprite
    }
}
my_spawner = noone
spawnedDynamically = false
carriedItem = noone
carryInventory = [CarryItem.Spear, CarryItem.Cauldron]
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
