 foxTalk = function() {
        switch (questFoxState()) {
            case QuestFoxState.Inactive: 
                say(foxIntroLines())    
            break
            case QuestFoxState.Active: 
                say(foxWaitingLines())
            break
            case QuestFoxState.ItemsCollected: 
                say(
                    foxDoneLines(), 
                    function() { 
                        questFoxComplete() 
                    }
                )
            break
            case QuestFoxState.Completed: 
            break
        }
    }

function foxIntroLines() {
    return []
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
    return []
}

function foxDialogChoice() {
    return [
        { 
            text: loc("dlg.fox.optYes"), onSelect: function() { 
                questFoxAccept() 
            } 
        },
        { 
            text: loc("dlg.fox.optNo"), onSelect: function() { 
                say([foxLine(loc("dlg.fox.decline"))]) 
            } 
        }
    ]
}