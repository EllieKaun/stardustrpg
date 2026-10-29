if (!open) { exit }
guiSyncCrisp() 
layoutPanels()

if (global.deckTutorialStage == DeckTutorialStage.Steps) {
    if (!deckTutStarted) {
        deckTutStarted = true
        modalOpen(modalTutorial(deckTutorialSteps, function() {
            markDeckTutorialDone()
            global.deckTutorialStage = DeckTutorialStage.Done
        }))
    }
    exit
}
if (modalIsOpen()) { exit }

// Мышь: наведение, а также клик по табам/слотам
collectionPanel.stepMouse()
deckPanel.stepMouse()

// Клавиатура — только для сфокусированной панели
if (collectionPanel.focused) { collectionPanel.step() }
else if (deckPanel.focused) { deckPanel.step() }