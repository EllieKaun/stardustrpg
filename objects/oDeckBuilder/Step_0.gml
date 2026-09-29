if (!open) { exit }
guiSyncCrisp() 
layoutPanels()

if (global.deckTutorialStage == DeckTutorialStage.Steps) {
    if (!deckTutStarted) {
        deckTutorial.reset()
        deckTutStarted = true
    }
    if (deckTutorial.step()) {
        markDeckTutorialDone()
        global.deckTutorialStage = DeckTutorialStage.Done
    }
    exit
}

// Мышь: наведение, а также клик по табам/слотам
collectionPanel.stepMouse()
deckPanel.stepMouse()

// Клавиатура — только для сфокусированной панели
if (collectionPanel.focused) { collectionPanel.step() }
else if (deckPanel.focused) { deckPanel.step() }