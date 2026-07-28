if (!open) exit

if (keyboard_check_pressed(vk_escape)) {
    closeBuilder()
    exit
}

// Держим вёрстку актуальной (напр. при ресайзе), чтобы хит-тест мыши совпадал
layoutPanels()

// Мышь (обе панели, независимо от фокуса): наведение + клик по табам/слотам
collectionPanel.stepMouse()
deckPanel.stepMouse()

// Клавиатура — только для сфокусированной панели
if (collectionPanel.focused) collectionPanel.step()
else if (deckPanel.focused) deckPanel.step()