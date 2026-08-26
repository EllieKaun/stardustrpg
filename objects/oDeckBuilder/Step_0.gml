if (!open) exit
layoutPanels()

// Мышь: наведение + клик по табам/слотам
collectionPanel.stepMouse()
deckPanel.stepMouse()

// Клавиатура — только для сфокусированной панели
if (collectionPanel.focused) collectionPanel.step()
else if (deckPanel.focused) deckPanel.step()