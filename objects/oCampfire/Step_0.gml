if (global.gamePaused || global.uiModal) { exit }
if (variable_global_exists("cutsceneActive") && global.cutsceneActive) { exit }

if (!leaderApproached(CAMPFIRE_INTERACT_DIST, CAMPFIRE_INTERACT_DIST)) { exit }

var speaker = activeSpeaker()
say([
    dialogChoice(speaker.id, speaker.portrait, loc("campfire.ask"), [
        { text: isNight() ? loc("campfire.waitMorning") : loc("campfire.waitNight"), onSelect: function() { skipTimeOfDay() } },
        { text: loc("campfire.leave"), onSelect: undefined }
    ])
])
