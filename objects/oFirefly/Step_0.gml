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
        // Гаснет, когда герой ушёл далеко (как враги) или когда светает.
        // Освободившееся место в лимите займут новые светлячки рядом с героем
        var leader = oGameController.selected_character
        var isFarAway = instance_exists(leader)
            && point_distance(x, y, leader.x, leader.y) > FIREFLY_DESPAWN_DISTANCE
        if (isFarAway || nightValue() < fadeThreshold) {
            state = FireflyState.Fading
        }
    break
    case FireflyState.Fading:
        brightness = max(0, brightness - FIREFLY_FADE_SPEED)
        if (brightness <= 0) { 
            instance_destroy() 
        }
    break
}

// Полёт вдоль одной оси вокруг точки появления. Стены не проверяем: светлячок летает над ними
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
if (patrolAxis == 0) {
    var nextX = x + patrolDir * FIREFLY_SPEED
    if (nextX < minX || nextX > maxX) { 
        patrolDir = -patrolDir 
    } else { 
        x = nextX
    }
} else {
    var nextY = y + patrolDir * FIREFLY_SPEED
    if (nextY < minY || nextY > maxY) { 
        patrolDir = -patrolDir 
    } else { 
        y = nextY
    }
}

// Виляние: плавное смещение поперёк движения и чуть вдоль него. Две несовпадающие волны,
// чтобы траектория не повторялась. Логические x/y остаются на прямой - границы считаются по ним
var wobbleTime = current_time / 1000
var wobbleSide = sin(wobbleTime * FIREFLY_WOBBLE_SPEED + blinkPhase) * FIREFLY_WOBBLE_RANGE
    + sin(wobbleTime * FIREFLY_WOBBLE_SPEED * 2.3 + blinkPhase * 1.7) * FIREFLY_WOBBLE_RANGE * 0.4
var wobbleAlong = sin(wobbleTime * FIREFLY_WOBBLE_SPEED * 0.7 + blinkPhase * 2.1) * FIREFLY_WOBBLE_RANGE * 0.5
if (patrolAxis == 0) {
    drawX = x + wobbleAlong
    drawY = y + wobbleSide
} else {
    drawX = x + wobbleSide
    drawY = y + wobbleAlong
}

blinkValue = 0.675 + 0.325 * sin(current_time / 500 + blinkPhase)
if (light != undefined) {
    // центр пятна - центр пикселя светлячка (origin спрайта в левом верхнем углу)
    light.x = drawX + sprite_width * 0.5
    light.y = drawY + sprite_height * 0.5
    light.intensity = brightness * blinkValue
}
