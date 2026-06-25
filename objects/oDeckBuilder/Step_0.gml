if (!open) exit

if (keyboard_check_pressed(vk_escape)) {
    closeBuilder()
    exit
}

if (collectionPanel.focused) collectionPanel.step()
else if (deckPanel.focused) deckPanel.step()