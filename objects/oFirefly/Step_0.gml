if (global.gamePaused) { exit }

if (global.uiModal) { exit }
if (variable_global_exists("cutsceneActive") && global.cutsceneActive) { exit }

depth = -bbox_bottom
    
switch (state) {
    case FireflyState.Appearing:
        brightness = min(1, brightness + FIREFLY_FADE_SPEED)
        if (brightness >= 1) { 
            state = FireflyState.Flying 
        }
    break
    case FireflyState.Flying:
        
    break
    case FireflyState.Fading:
        brightness = max(0, brightness + FIREFLY_FADE_SPEED)
        if (brightness <= 1) { 
            instance_destroy() 
        }
    break
}

// Прогулка
var minX = homeX - FIREFLY_PATROL_RANGE
var maxX = homeX + FIREFLY_PATROL_RANGE
var minY = homeY - FIREFLY_PATROL_RANGE
var maxY = homeY + FIREFLY_PATROL_RANGE
if (instance_exists(homeSpawner)) {
    minX = max(minX, homeSpawner.bbox_left) 
    maxX = min(maxX, homeSpawner.bbox_right)
    minY = max(minY, homeSpawner.bbox_top) 
    maxY = min(maxY, homeSpawner.bbox_bottom)
}
var moved = false
if (patrolAxis == 0) {
    var nextX = x + patrolDir * FIREFLY_SPEED
    if (nextX < minX || nextX > maxX || place_meeting(nextX, y, oWall)) { 
        patrolDir = -patrolDir 
    } else { 
        x = nextX
        moved = true 
    }
    image_xscale = (patrolDir < 0) ?  1 : -1
} else {
    var nextY = y + patrolDir * FIREFLY_SPEED
    if (nextY < minY || nextY > maxY || place_meeting(x, nextY, oWall)) { 
        patrolDir = -patrolDir 
    } else { 
        y = nextY
        moved = true 
    }
}

if (moved) {
    patrolStuckSteps = 0
    patrolAxisSwitches = 0
} else {
    patrolStuckSteps++
    if (patrolStuckSteps >= 2) {
        patrolStuckSteps = 0
        patrolAxis = 1 - patrolAxis
        patrolAxisSwitches++
        if (patrolAxisSwitches >= 2) { shouldWalk = false }
    }
}

if (light != undefined) {
    light.x = x 
    light.y = y
    blinkValue = 0.675 + 0.325 * sin(current_time / 500 + blinkPhase)
    light.intensity = brightness * blinkValue
}