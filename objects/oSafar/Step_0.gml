depth = -bbox_bottom

if (global.safarJoined) exit
if (global.gamePaused || global.uiModal) exit

var leader = oGameController.selected_character
if (!instance_exists(leader)) exit

if (place_meeting(x, y, leader)) {
    if (!spoke) {
        spoke = true
        var spearState = questSpearState()
        if (spearState == QuestSpearState.Inactive) {
            say([
                dialogLine("Safar", portraitSafar, "You need a companion on your journey?"),
                dialogLine("Lana", portraitLana, "Help would be welcome."),
                dialogLine("Safar", portraitSafar, "Can't help you with that."),
                dialogLine("Viv", portraitViv, "Then why even ask?!"),
                dialogLine("Safar", portraitSafar, "Fine - find my spear and I'll join you."),
                dialogLine("Lana", portraitLana, "And where do we find it?"),
                dialogLine("Safar", portraitSafar, "A monster ran off with it while I slept. Without it I can't fight them."),
                dialogChoice("Lana", portraitLana, "", [
                    { text: "Alright, we'll find your spear", onSelect: function() { questAcceptSpear() } },
                    { text: "We're too busy right now", onSelect: undefined }
                ])
            ])
        } else if (spearState == QuestSpearState.Active) {
            say([
                dialogLine("Safar", portraitSafar, "Found my spear yet? Use a Steal card on the monster carrying it.")
            ])
        } else if (spearState == QuestSpearState.SpearObtained) {
            say([
                dialogLine("Safar", portraitSafar, ":0 ... you actually all found it."),
                dialogLine("Safar", portraitSafar, "You can count on my skills now.")
            ], function() { questCompleteSpear() })
        }
    }
} else {
    if (point_distance(x, y, leader.x, leader.y) > 24) spoke = false
}
