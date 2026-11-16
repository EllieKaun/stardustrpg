if (!open) { exit }
if (modalIsOpen()) { exit }
guiSyncCrisp()
layoutPanels()

shopPanel.stepMouse()

if (shopPanel.focused) {
    shopPanel.step()
}