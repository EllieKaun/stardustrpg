if (companionIsActive(Characters.Fox)) {
    if (mask_index != sLana) { joinParty() }
    returningHome = false
    event_inherited()
    exit
}

if (global.foxJoined && !isAtHome()) {
    returningHome = true
    event_inherited()
    exit
}
if (returningHome) { leaveParty() }

depth = -bbox_bottom
if (global.gamePaused || global.uiModal) { exit }

if (!leaderApproached(FIRA_REARM_DIST)) { exit }

if (global.foxJoined) {
    companionOfferRejoin(Characters.Fox)
    exit
}
foxTalk()
