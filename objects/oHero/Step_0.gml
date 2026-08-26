var selected = (oGameController.selected_character.id == id)

if (global.uiModal || !can_move) {
    path_end()
    speed = 0
    sprite_index = sprIdle
    xPrev = x
    yPrev = y
    if (selected) updateWalkSound(false)
    exit
}

if (selected) stepControlled()
else stepFollowing()

var movedX = x - xPrev, movedY = y - yPrev
var moving = (movedX != 0 || movedY != 0)
if (selected) updateWalkSound(moving)
if (movedY != 0) last_v_dir = sign(movedY)
if (movedX != 0) image_xscale = sign(movedX)
sprite_index = moving ? (sprWalk)
                      : (sprIdle)
xPrev = x
yPrev = y
depth = -bbox_bottom