depth = -bbox_bottom

if (global.safarJoined) exit
if (global.gamePaused || global.uiModal) exit

var leader = oGameController.selected_character
if (!instance_exists(leader)) exit

if (place_meeting(x, y, leader)) {
    if (!spoke) {
        spoke = true
        var st = questSpearState()
        if (st == QuestSpearState.Inactive) {
            say([
                dialogLine("Safar", sprSafar, "left", "You need a companion on your journey?"),
                dialogLine("Lana", placeholderLana, "right", "Help would be welcome."),
                dialogLine("Safar", sprSafar, "left", "Can't help you with that."),
                dialogLine("Viv", placeholderViv, "right", "Then why even ask?!"),
                dialogLine("Safar", sprSafar, "left", "Fine - find my spear and I'll join you."),
                dialogLine("Lana", placeholderLana, "right", "And where do we find it?"),
                dialogLine("Safar", sprSafar, "left", "A monster ran off with it while I slept. Without it I can't fight them."),
                dialogChoice("Lana", placeholderLana, "right", "", [
                    { text: "Alright, we'll find your spear", onSelect: function() { questAcceptSpear() } },
                    { text: "We're too busy right now", onSelect: undefined }
                ])
            ])
        } else if (st == QuestSpearState.Active) {
            say([
                dialogLine("Safar", sprSafar, "left", "Found my spear yet? Use a Steal card on the monster carrying it.")
            ])
        } else if (st == QuestSpearState.SpearObtained) {
            say([
                dialogLine("Safar", sprSafar, "left", ":0 ... you actually all found it."),
                dialogLine("Safar", sprSafar, "left", "You can count on my skills now.")
            ], function() { questCompleteSpear() })
        }
    }
} else {
    if (point_distance(x, y, leader.x, leader.y) > 24) spoke = false
}
