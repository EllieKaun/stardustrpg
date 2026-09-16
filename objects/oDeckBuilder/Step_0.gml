if (!open) exit
layoutPanels()

if (global.deckTutStage == DeckTutStage.Steps) {
    if (!deckTutStarted) {
        deckTutorial.reset()
        deckTutStarted = true
    }
    if (deckTutorial.step()) {
        markDeckTutorialDone()
        global.deckTutStage = DeckTutStage.Done
    }
    exit
}

// Мышь: наведение, а также клик по табам/слотам
collectionPanel.stepMouse()
deckPanel.stepMouse()

// Клавиатура — только для сфокусированной панели
if (collectionPanel.focused) collectionPanel.step()
else if (deckPanel.focused) deckPanel.step()