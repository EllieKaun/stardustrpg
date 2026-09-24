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
                dialogLine("Safar", portraitSafar, loc("dlg.safar.q1")),
                dialogLine("Lana", portraitLana, loc("dlg.safar.q2")),
                dialogLine("Safar", portraitSafar, loc("dlg.safar.q3")),
                dialogLine("Viv", portraitViv, loc("dlg.safar.q4")),
                dialogLine("Safar", portraitSafar, loc("dlg.safar.q5")),
                dialogLine("Lana", portraitLana, loc("dlg.safar.q6")),
                dialogLine("Safar", portraitSafar, loc("dlg.safar.q7")),
                dialogChoice("Lana", portraitLana, "", [
                    { text: loc("dlg.safar.optYes"), onSelect: function() { questAcceptSpear() } },
                    { text: loc("dlg.safar.optNo"), onSelect: undefined }
                ])
            ])
        } else if (spearState == QuestSpearState.Active) {
            say([
                dialogLine("Safar", portraitSafar, loc("dlg.safar.waiting"))
            ])
        } else if (spearState == QuestSpearState.SpearObtained) {
            say([
                dialogLine("Safar", portraitSafar, loc("dlg.safar.done1")),
                dialogLine("Safar", portraitSafar, loc("dlg.safar.done2"))
            ], function() { questCompleteSpear() })
        }
    }
} else {
    if (point_distance(x, y, leader.x, leader.y) > 24) spoke = false
}
