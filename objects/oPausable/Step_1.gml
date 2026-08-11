var paused = variable_global_exists("gamePaused") && global.gamePaused
var frozen = variable_instance_exists(id, "pauseFrozen") && pauseFrozen

if (paused) {
    if (!frozen) { 
        pauseAnimSpeed = image_speed
        pauseFrozen = true 
    }
    image_speed = 0
} else if (frozen) {
    image_speed = pauseAnimSpeed
    pauseFrozen = false
}
