event_inherited() 

if (!variable_global_exists("safarJoined")) { global.safarJoined = false }

sprIdle = sprSafar
image_xscale = -1
sprWalk = sprSafarWalk

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

if (companionIsActive(Characters.Safar)) { joinParty() }
