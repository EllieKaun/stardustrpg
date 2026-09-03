
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
    }
}
