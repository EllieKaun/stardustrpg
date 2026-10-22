if (global.foxJoined) {
    if (mask_index != sLana) { joinParty() }
    event_inherited()
    exit
}

depth = -bbox_bottom
if (global.gamePaused || global.uiModal) { exit }

if (leaderApproached(FIRA_REARM_DIST)) { foxTalk() }
