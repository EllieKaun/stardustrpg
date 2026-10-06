function foxTalk() {
    switch (questFoxState()) {
        case QuestFoxState.Inactive:
            say(foxIntroLines())
        break
        case QuestFoxState.Active:
            say(foxWaitingLines())
        break
        case QuestFoxState.ItemsCollected:
            say(foxDoneLines(), function() { questFoxComplete() })
        break
        case QuestFoxState.Completed:
        break
    }
}

function foxIntroLines() {
    var speaker = activeSpeaker()
    return [
        activeLine(loc("dlg.fox.greet")),
        foxLine(loc("dlg.fox.q1")),
        foxLine(loc("dlg.fox.q2")),
        foxLine(loc("dlg.fox.q3")),
        dialogChoice(speaker.id, speaker.portrait, "", foxDialogChoice())
    ]
}

function foxAcceptLines() {
    return [
        foxLine(loc("dlg.fox.accept1")),
        foxLine(loc("dlg.fox.accept2")),
        foxLine(loc("dlg.fox.needCones")),
        foxLine(loc("dlg.fox.needPetunia")),
        foxLine(loc("dlg.fox.needCauldron")),
        foxLine(loc("dlg.fox.giveCard"))
    ]
}

function foxWaitingLines() {
    var lines = [foxLine(loc("dlg.fox.waitIntro"))]
    if (!questFoxItemDone(QuestFoxItem.PineCone)) {
        array_push(lines, foxLine(loc("dlg.fox.needCones")))
    }
    if (!questFoxItemDone(QuestFoxItem.Petunia))  {
        array_push(lines, foxLine(loc("dlg.fox.needPetunia")))
    }
    if (!questFoxItemDone(QuestFoxItem.Cauldron)) {
        array_push(lines, foxLine(loc("dlg.fox.needCauldron")))
    }
    return lines
}

function foxDoneLines() {
    return [
        foxLine(loc("dlg.fox.done1")),
        foxLine(loc("dlg.fox.done2")),
        activeLine(loc("dlg.fox.join")),
        foxLine(loc("dlg.fox.joinYes"))
    ]
}

function foxDialogChoice() {
    return [
        {
            text: loc("dlg.fox.optYes"), onSelect: function() {
                say(foxAcceptLines(), function() { questFoxAccept() })
            }
        },
        {
            text: loc("dlg.fox.optNo"), onSelect: function() {
                say([foxLine(loc("dlg.fox.decline"))])
            }
        }
    ]
}
