if (global.uiModal) {                      
    path_end()
    speed = 0
    sprite_index = (last_v_dir < 0) ? sprBackIdle : sprIdle
    xPrev = x
    yPrev = y
    exit
}

var selected = (oGameController.selected_character.id == id)

if (selected) stepControlled()
else stepFollowing()

var movedX = x - xPrev, movedY = y - yPrev
var moving = (movedX != 0 || movedY != 0)
if (movedY != 0) last_v_dir = sign(movedY)
if (movedX != 0) image_xscale = sign(movedX)
sprite_index = moving ? ((last_v_dir < 0) ? sprBackWalk : sprWalk)
                      : ((last_v_dir < 0) ? sprBackIdle : sprIdle)
xPrev = x
yPrev = y
