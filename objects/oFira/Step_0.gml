if (global.foxJoined) {
    if (mask_index != sLana) { joinParty() }
    event_inherited()
    exit
}

depth = -bbox_bottom
if (global.gamePaused || global.uiModal) { exit }

var leader = oGameController.selected_character
if (!instance_exists(leader)) { exit }

if (place_meeting(x, y, leader)) {
    if (!spoke) {
        spoke = true
        foxTalk()
    }
} else if (point_distance(x, y, leader.x, leader.y) > 24) { 
    spoke = false 
}


