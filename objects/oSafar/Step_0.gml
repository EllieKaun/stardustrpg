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
                dialogLine("Safar", sprSafar, "You need a companion on your journey?"),
                dialogLine("Lana", placeholderLana, "Help would be welcome."),
                dialogLine("Safar", sprSafar, "Can't help you with that."),
                dialogLine("Viv", placeholderViv, "Then why even ask?!"),
                dialogLine("Safar", sprSafar, "Fine - find my spear and I'll join you."),
                dialogLine("Lana", placeholderLana, "And where do we find it?"),
                dialogLine("Safar", sprSafar, "A monster ran off with it while I slept. Without it I can't fight them."),
                dialogChoice("Lana", placeholderLana, "", [
                    { text: "Alright, we'll find your spear", onSelect: function() { questAcceptSpear() } },
                    { text: "We're too busy right now", onSelect: undefined }
                ])
            ])
        } else if (spearState == QuestSpearState.Active) {
            say([
                dialogLine("Safar", sprSafar, "Found my spear yet? Use a Steal card on the monster carrying it.")
            ])
        } else if (spearState == QuestSpearState.SpearObtained) {
            say([
                dialogLine("Safar", sprSafar, ":0 ... you actually all found it."),
                dialogLine("Safar", sprSafar, "You can count on my skills now.")
            ], function() { questCompleteSpear() })
        }
    }
} else {
    if (point_distance(x, y, leader.x, leader.y) > 24) spoke = false
}
