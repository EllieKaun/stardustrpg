light = oLighting.addLight({
    x: x, 
    y: y,
    radius: 64,
    color: c_orange,
    intensity: 1,
    flicker: 0.08
})

interaction = new Interactable(id, {
    interactDist: CAMPFIRE_INTERACT_DIST,
    iconOffset: CAMPFIRE_ICON_OFFSET,
    clickHeight: CAMPFIRE_ICON_CLICK_HEIGHT,
    onInteract: function() {
        var speaker = activeSpeaker()
        say([
            dialogChoice(speaker.id, speaker.portrait, loc("campfire.ask"), [
                { text: isNight() ? loc("campfire.waitMorning") : loc("campfire.waitNight"), onSelect: function() { skipTimeOfDay() } },
                { text: loc("campfire.leave"), onSelect: undefined }
            ])
        ])
    }
})