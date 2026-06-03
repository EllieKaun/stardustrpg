if (!open) exit

if (keyboard_check_pressed(vk_escape)) {
    closeBuilder()
    exit
}

collectionPanel.step()
deckPanel.step()