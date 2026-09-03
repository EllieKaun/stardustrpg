depth = -bbox_bottom

if (global.gamePaused) exit

var leader = oGameController.selected_character
if (!instance_exists(leader)) exit

if (place_meeting(x, y, leader)) {
    if (!triggered) {
        triggered = true
        if (instance_exists(oShop) && !oShop.open && !global.uiModal) {
            oShop.openShop()
        }
    }
} else {
    if (triggered && point_distance(x, y, leader.x, leader.y) > rearmDistance) {
        triggered = false
    }
}
