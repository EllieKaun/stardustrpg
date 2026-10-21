var selected = (oGameController.selected_character.id == id)

if (torchLight == undefined && instance_exists(oLighting)) {
    torchLight = oLighting.addLight({
        x: x,
        y: y,
        radius: HERO_TORCH_RADIUS,
        color: make_color_rgb(255, 170, 70),
        intensity: 0,
        flicker: 0.08
    })
}
if (torchLight != undefined) {
    torchLight.x = x
    torchLight.y = (bbox_top + bbox_bottom) / 2
    torchLight.intensity = selected ? nightValue() * HERO_TORCH_INTENSITY : 0
}

if (global.uiModal || !can_move) {
    path_end()
    speed = 0
    sprite_index = sprIdle
    xPrev = x
    yPrev = y
    if (selected) { updateWalkSound(false) }
    exit
}

if (selected) {
    if (global.introWalk) { stepScriptedApproach() }
    else { stepControlled() }
} else { 
    stepFollowing()
} 
var movedX = x - xPrev, movedY = y - yPrev
var moving = (movedX != 0 || movedY != 0)
if (selected) { updateWalkSound(moving) }
if (movedY != 0) { last_v_dir = sign(movedY) }
if (movedX != 0) { image_xscale = sign(movedX) }
sprite_index = moving ? (sprWalk)
                      : (sprIdle)
xPrev = x
yPrev = y
depth = -bbox_bottom