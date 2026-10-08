function characterKey(character) {
    switch (character) {
        case Characters.Lana: return "lana"
        case Characters.Viv: return "viv"
        default: return "lana"
    }
}

// Нужно мапить айди карты и редкость карты в одну строку, чтобы потом восстанавливать карты как структуры 
// и не создавать много айдишек для каждой редкости
function collectionKey(cardIdentifier, rarity) {
    return cardIdentifier + "@" + string(rarity)
}

// Достать деку по персонажу
function deckOf(character) {
    return global.playerData.decks[$ characterKey(character)]
}

//// Работа с картами

// Открыть карту для пользователя 
function unlockCard(cardIdentifier, rarity = CardsRarity.Default, count = 1) {
    if (!cardExists(cardIdentifier)) { 
        show_debug_message("unlockCard: unknown id " + string(cardIdentifier))
        return 
    }
    if (!cardCanVaryRarity(cardIdentifier)) { rarity = CardsRarity.Default }
        
    var keyOfCard = collectionKey(cardIdentifier, rarity)
    var collection = global.playerData.collection
    if (variable_struct_exists(collection, keyOfCard)) {
        collection[$ keyOfCard].count += count
    } else {
        collection[$ keyOfCard] = { id: cardIdentifier, rarity: rarity, count: count }
    }
}

// Проверка, есть ли карта с ид
function isCardOwned(cardIdentifier, rarity = CardsRarity.Default) {
    return getOwnedCount(cardIdentifier, rarity) > 0
}

// Количество карт по ид
function getOwnedCount(cardIdentifier, rarity = CardsRarity.Default) {
    var keyOfCard = collectionKey(cardIdentifier, rarity)
    var collection = global.playerData.collection
    return variable_struct_exists(collection, keyOfCard) ? collection[$ keyOfCard].count : 0
}

// Массив ссылок на карты (разница в том, что тут не целые структуры картб, а ид) [{ id, rarity, count }]
function getCollectionRefs() {
    var result  = []
    var collection  = global.playerData.collection
    var cardKeys = variable_struct_get_names(collection);
    for (var keyIndex = 0; keyIndex < array_length(cardKeys); keyIndex++) array_push(result, collection[$ cardKeys[keyIndex]])
    return result
}

// Массив структур кард
function getCollectionCards() {
    var references = getCollectionRefs()
    var result  = []
    for (var refIndex = 0; refIndex < array_length(references); refIndex++) {
        var card = cardFromRef(references[refIndex])
        if (card != undefined) { array_push(result, card) }
    }
    return result
}

//// Работа с деками

// Количество кард в деке персонажа
function countCardInDeck(character, cardIdentifier, rarity) {
    var cards = deckOf(character).cards
    var count = 0
    for (var cardIndex = 0; cardIndex < array_length(cards); cardIndex++)
        if (cards[cardIndex].id == cardIdentifier && cards[cardIndex].rarity == rarity) { count++ }
    return count
}

// Карта персонажа в слоте в деке персонажа, если есть 
function deckSlotRef(character, slot) {
    var cards = deckOf(character).cards
    for (var cardIndex = 0; cardIndex < array_length(cards); cardIndex++)
        if (cards[cardIndex].slot == slot) { return cards[cardIndex] }
    return undefined
}

// Очистить слот в деке персонажа
function clearDeckSlot(character, slot) {
    var deck = deckOf(character)
    for (var cardIndex = 0; cardIndex < array_length(deck.cards); cardIndex++) {
        if (deck.cards[cardIndex].slot == slot) { 
            array_delete(deck.cards, cardIndex, 1)
            return 
        }
    }
}

// Не занятые ни одной декой копии карты
function freeCopies(cardIdentifier, rarity = CardsRarity.Default) {
    var used = countCardInDeck(Characters.Lana, cardIdentifier, rarity)
             + countCardInDeck(Characters.Viv,  cardIdentifier, rarity)
    return getOwnedCount(cardIdentifier, rarity) - used
}

// Добавить карту в деку персонажа
function setDeckSlot(character, slot, cardIdentifier, rarity = CardsRarity.Default) {
    if (!cardCanVaryRarity(cardIdentifier)) { rarity = CardsRarity.Default }

    var deck = deckOf(character)
    if (slot < 0 || slot >= deck.unlocked) {
        return false
    }
    if (!isCardOwned(cardIdentifier, rarity)) {
        return false
    }
    if (freeCopies(cardIdentifier, rarity) <= 0) {
        return false
    }
    var existing = deckSlotRef(character, slot)
    var alreadyHere = (existing != undefined && existing.id == cardIdentifier && existing.rarity == rarity)

    if (alreadyHere) {
        return false
    }
    clearDeckSlot(character, slot)
    array_push(deck.cards, { slot: slot, id: cardIdentifier, rarity: rarity })
    return true
}

// Первый разблокированный и пустой слот деки, иначе -1
function firstFreeDeckSlot(character) {
    var deck = deckOf(character)
    for (var slotIndex = 0; slotIndex < deck.unlocked; slotIndex++) {
        if (deckSlotRef(character, slotIndex) == undefined) { return slotIndex }
    }
    return -1
}

// Разблокировать слот в деке персонажа
function unlockDeckSlot(character, _count = 1) {
    var deck = deckOf(character)
    deck.unlocked = min(deckSlotLimit(), deck.unlocked + _count)
}

// Индекс текущей зоны. Пока в игре одна зона
function currentZoneIndex() {
    return 0
}

// Максимум слотов деки, которые можно открыть в текущей зоне
function deckSlotLimit() {
    var limits = ZONE_DECK_SLOT_LIMITS
    return min(DECK_CAPACITY, limits[min(currentZoneIndex(), array_length(limits) - 1)])
}

// Очистить деку персонажа 
function clearDeck(character) {
    deckOf(character).cards = []
}

//// Работа с UI декбилдера

// Иконка персонажа
function characterIcon(character) {
    switch (character) {
        case Characters.Lana: return LanaIcon
        case Characters.Viv:  return VivIcon
        default: return noone
    }
}

// Другой персонаж 
function otherCharacter(character) {
    return (character == Characters.Lana) ? Characters.Viv : Characters.Lana
}

function deckPutCard(character, slot, ref) {
    var isDeckSlotSet = setDeckSlot(character, slot, ref.id, ref.rarity)
    if (isDeckSlotSet) {
        analyticsAddToDeck(characterKey(character), ref.id, ref.rarity)
    }
    return isDeckSlotSet
}

function deckMoveCard(character, slotA, slotB) {
    if (slotA == slotB) { return false }
    var refA = deckSlotRef(character, slotA)
    var refB = deckSlotRef(character, slotB)
    if (refA == undefined) { return false }
        
    clearDeckSlot(character, slotA)
    clearDeckSlot(character, slotB)
    var isDeckSlotSet = setDeckSlot(character, slotB, refA.id, refA.rarity)
    if (refB != undefined) {
        isDeckSlotSet = isDeckSlotSet && setDeckSlot(character, slotA, refB.id, refB.rarity)
    }
    if (!isDeckSlotSet) {
        setDeckSlot(character, slotA, refA.id, refA.rarity)
        setDeckSlot(character, slotB, refB.id, refB.rarity)
    }
    return isDeckSlotSet
}

function deckRemoveCard(charcter, slot) {
    if (deckSlotRef(charcter, slot) == undefined) { return false }

    clearDeckSlot(charcter, slot)
    return true
}

// Построение слотов панели всех карт.
// Одинаковые карты (id+редкость) группируются в один слот с числом.
// Если часть копий занята деками — они выделяются в отдельные слоты:
// свободные, занятые текущей декой, занятые чужой декой.
// currentCharacter — чья дека сейчас открыта.
function buildCollectionSlots(category = undefined, cols = 4, currentCharacter = Characters.Lana) {
    var refs = getCollectionRefs()
    var otherChar = otherCharacter(currentCharacter)
    var slots = []

    for (var refIndex = 0; refIndex < array_length(refs); refIndex++) {
        var cardRef = refs[refIndex]
        var card = cardFromRef(cardRef)
        if (card == undefined) { continue }
        if (category != undefined && cardCategoryOf(card) != category) { continue }

        var total = cardRef.count
        var inCurrent = countCardInDeck(currentCharacter, cardRef.id, cardRef.rarity)
        var inOther = countCardInDeck(otherChar, cardRef.id, cardRef.rarity)
        var freeCount = max(0, total - inCurrent - inOther)

        // свободные копии — обычный слот с числом, можно добавлять
        if (freeCount > 0) {
            var newSlot = new Slot("filled", card)
            newSlot.ref = { id: cardRef.id, rarity: cardRef.rarity }
            newSlot.count = freeCount
            newSlot.addable = true
            array_push(slots, newSlot)
        }
        // копии в текущей деке — иконка владельца, добавлять нельзя
        if (inCurrent > 0) {
            var newSlot = new Slot("filled", card)
            newSlot.ref = { id: cardRef.id, rarity: cardRef.rarity }
            newSlot.count = inCurrent
            newSlot.ownerIcon = characterIcon(currentCharacter)
            newSlot.addable = false
            array_push(slots, newSlot)
        }
        // копии в чужой деке — затемнены, добавлять нельзя
        if (inOther > 0) {
            var newSlot = new Slot("filled", card)
            newSlot.ref = { id: cardRef.id, rarity: cardRef.rarity }
            newSlot.count = inOther
            newSlot.dimmed = true
            newSlot.ownerIcon = characterIcon(otherChar)
            newSlot.addable = false
            array_push(slots, newSlot)
        }
    }

    // добить пустыми до минимум 20 слотов
    var count = array_length(slots)
    var totalSlots = max(20, ceil(count / cols) * cols)
    repeat (totalSlots - count) array_push(slots, new Slot("empty"))

    return slots
}

// Построение слотов для панели деки персонажа, пустые, залоченные и заполненные картой
function buildDeckSlots(character, total = DECK_CAPACITY) {
    var deck = deckOf(character)
    var slots = []
    for (var slotIndex = 0; slotIndex < total; slotIndex++) {
        if (slotIndex >= deck.unlocked) { 
            array_push(slots, new Slot("locked"))
            continue 
        }
        var cardRef = deckSlotRef(character, slotIndex)
        if (cardRef != undefined) { 
            var newSlot = new Slot("filled", cardFromRef(cardRef))
            newSlot.ref = { id: cardRef.id, rarity: cardRef.rarity }
            array_push(slots, newSlot) 
        }
        else { array_push(slots, new Slot("empty")) }
    }
    return slots
}

//// Вспомогательные методы

// Открыть количество карт
function unlockAllCards(count = 9) {
    var keys = variable_struct_get_names(global.cardRegistry)
    for (var keyIndex = 0; keyIndex < array_length(keys); keyIndex++) 
        unlockCard(keys[keyIndex], CardsRarity.Default, count)
}

// Ресет данных для теста
function playerDataResetForTesting() {
    global.playerData = playerDataDefault()
    playerDataSave()
}

// Побеждён ли босс 
function isBossDefeated() {
    if (!variable_struct_exists(global.playerData, "bossDefeated")) { global.playerData.bossDefeated = false }
    return global.playerData.bossDefeated
}

function markBossDefeated() {
    global.playerData.bossDefeated = true
    playerDataSave()
}
