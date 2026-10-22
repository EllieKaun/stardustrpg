if (companionIsActive(Characters.Safar)) {
    if (mask_index != sLana) { joinParty() }
    returningHome = false
    event_inherited()
    exit
}

if (global.safarJoined && !isAtHome()) {
    returningHome = true
    event_inherited()
    exit
}
if (returningHome) { leaveParty() }

depth = -bbox_bottom
if (global.gamePaused || global.uiModal) { exit }

if (!leaderApproached(SAFAR_REARM_DIST)) { exit }

if (global.safarJoined) {
    companionOfferRejoin(Characters.Safar)
    exit
}

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