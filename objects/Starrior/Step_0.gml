// Пауза боя: замораживаем анимацию и таймеры
if (global.gamePaused) {
    if (!pauseFrozen) {
        pauseAnimSpeed = image_speed
        pauseFrozen = true
    }
    image_speed = 0
    exit
} else if (pauseFrozen) {
    image_speed = pauseAnimSpeed
    pauseFrozen = false
}

if (disappearing) {
    var spriteSpeed = sprite_get_speed(disappearMaskSpr)
    spriteSpeed /= game_get_speed(gamespeed_fps)
    disappearTimer += spriteSpeed
    if (disappearTimer >= sprite_get_number(disappearMaskSpr)) {
        disappearing = false
        gone = true
        if (surface_exists(disappearSurf)) { 
            surface_free(disappearSurf)
            disappearSurf = -1
        }
        if (destroyWhenGone) {
            instance_destroy()
            exit
        }
    }
}

// Танец при афк
var mayDance = (isActive && spriteActionDance != noone && instance_exists(Battle) && Battle.allowsIdleDance())
if (mayDance) {
    if (mouse_check_button_pressed(mb_left) || keyboard_check_pressed(vk_anykey)) {
        idleDanceTimer = 0
        if (actionState == StarriorStates.Dance) { changeActionState(StarriorStates.Idle, undefined) }
    } else {
        idleDanceTimer += 1
        if (idleDanceTimer >= IDLE_DANCE_SECONDS * game_get_speed(gamespeed_fps) && actionState == StarriorStates.Idle) {
            changeActionState(StarriorStates.Dance, undefined)
        }
    }
} else {
    idleDanceTimer = 0
    if (actionState == StarriorStates.Dance) { changeActionState(StarriorStates.Idle, undefined) }
}
