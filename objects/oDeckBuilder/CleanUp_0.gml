var panels = [collectionPanel, deckPanel]
for (var panelIndex = 0; panelIndex < array_length(panels); panelIndex++) {
    if (surface_exists(panels[panelIndex].clipSurface)) { surface_free(panels[panelIndex].clipSurface) }
    panels[panelIndex].clipSurface = -1
}
