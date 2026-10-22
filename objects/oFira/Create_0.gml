event_inherited() 

if (!variable_global_exists("foxJoined")) { global.foxJoined = false }

sprIdle = sprFoxyIdle
image_xscale = -1
sprWalk = sprFoxyWalk

joinParty = function() {
    mask_index = sLana
}
if (global.foxJoined) { joinParty() }
