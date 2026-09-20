if (!open) { exit }
guiSyncCrisp() 
layoutPanels()

shopPanel.stepMouse()

if (shopPanel.focused) {
    shopPanel.step()
}