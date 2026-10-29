function isCompanion(character) {
    return character == Characters.Safar || character == Characters.Fox
}

function companionUnlocked(character) {
    switch (character) {
        case Characters.Safar: return questState(QuestId.Safar) == QuestState.Completed
        case Characters.Fox: return questState(QuestId.Fox) == QuestState.Completed
        default: return false
    }
}

function activeCompanion() {
    if (!variable_struct_exists(global.playerData, "activeCompanion")) {
        if (companionUnlocked(Characters.Fox)) {
            global.playerData.activeCompanion = Characters.Fox
        } else if (companionUnlocked(Characters.Safar)) {
            global.playerData.activeCompanion = Characters.Safar
        } else {
            global.playerData.activeCompanion = COMPANION_NONE
        }
    }
    return global.playerData.activeCompanion
}

function companionIsActive(character) {
    return activeCompanion() == character
}

function companionJoin(character) {
    var previous = activeCompanion()
    if (previous == character) { return }
    if (previous != COMPANION_NONE && variable_struct_exists(global.playerData.decks, characterKey(previous))) {
        clearDeck(previous)
    }
    global.playerData.activeCompanion = character
    companionEnsureDeck(character)
    playerDataSave()
}

function companionWorldObject(character) {
    switch (character) {
        case Characters.Safar: return oSafar
        case Characters.Fox: return oFira
        default: return noone
    }
}

function createCompanionStarrior(character) {
    switch (character) {
        case Characters.Safar: return createSafar()
        case Characters.Fox: return createFox()
        default: return noone
    }
}

function companionFixedRefs(character) {
    var cardIds = global.CardId
    switch (character) {
        case Characters.Safar: return [
            { id: cardIds.physicalDamageSingleTarget, rarity: CardsRarity.Default },
            { id: cardIds.physicalDamageSingleTarget, rarity: CardsRarity.Default },
            { id: cardIds.magicalDamageSingleTarget, rarity: CardsRarity.Default },
            { id: cardIds.instantHealSingleTarget, rarity: CardsRarity.Default }
        ]
        case Characters.Fox: return [
            { id: cardIds.forestGather, rarity: CardsRarity.Default },
            { id: cardIds.forestFlask, rarity: CardsRarity.Default },
            { id: cardIds.forestProvoke, rarity: CardsRarity.Default },
            { id: cardIds.instantHealSingleTarget, rarity: CardsRarity.Default }
        ]
        default: return []
    }
}

function companionStarterRefs(character) {
    var cardIds = global.CardId
    switch (character) {
        case Characters.Safar: return [
            { id: cardIds.buffPhysicalDamageSingleTarget, rarity: CardsRarity.Default },
            { id: cardIds.physicalDamageStunChanceSingleTarget, rarity: CardsRarity.Default }
        ]
        default: return []
    }
}

function deckFixedSlots(character) {
    return array_length(companionFixedRefs(character))
}

function deckDefaultUnlocked(character) {
    if (!isCompanion(character)) { return DECK_DEFAULT_UNLOCKED }
    return deckFixedSlots(character) + array_length(companionStarterRefs(character))
}

function companionEnsureDeck(character) {
    if (!isCompanion(character)) { return }
    var decks = global.playerData.decks
    var key = characterKey(character)
    if (variable_struct_exists(decks, key)) { return }

    decks[$ key] = { unlocked: deckDefaultUnlocked(character), cards: [] }

    var starter = companionStarterRefs(character)
    var firstSlot = deckFixedSlots(character)
    for (var i = 0; i < array_length(starter); i++) {
        unlockCard(starter[i].id, starter[i].rarity, 1)
        setDeckSlot(character, firstSlot + i, starter[i].id, starter[i].rarity)
    }
    playerDataSave()
}

function companionSpeaker(character) {
    switch (character) {
        case Characters.Safar: return { id: "Safar", portrait: portraitSafar }
        case Characters.Fox:
            var portrait = asset_get_index("portraitFira")
            return { id: "Fox", portrait: sprite_exists(portrait) ? portrait : noone }
        default: return { id: "", portrait: noone }
    }
}

function companionOfferRejoin(character) {
    var speaker = companionSpeaker(character)
    say([
        dialogChoice(speaker.id, speaker.portrait, loc("companion.rejoinAsk"), [
            { text: loc("companion.rejoinYes"), onSelect: method({ character: character }, function() { companionJoin(character) }) },
            { text: loc("companion.rejoinNo"), onSelect: undefined }
        ])
    ])
}
