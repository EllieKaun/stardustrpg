event_inherited() 

if (!variable_global_exists("foxJoined")) { global.foxJoined = false }

sprIdle = sprFoxyIdle
image_xscale = -1
sprWalk = sprFoxyWalk

homeMask = mask_index

joinParty = function() {
    mask_index = sLana
}

leaveParty = function() {
    returningHome = false
    mask_index = homeMask
    image_xscale = -1
    sprite_index = sprIdle
}

if (companionIsActive(Characters.Fox)) { joinParty() }
