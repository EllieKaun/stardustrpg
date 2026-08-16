enum Characters { Lana, Viv }

#macro PLAYER_SAVE_FILE "player_data.json"
#macro DECK_DEFAULT_UNLOCKED 5
#macro DECK_CAPACITY 12

// Инициализация пользователя (каждый раз на старте)
function playerDataInit() {
    // global.playerData - свойство для хранения структуры пользователя для сохранения
    if (!playerDataLoad()) global.playerData = playerDataDefault()

    // Флаг новой игры: нужен стартовому флоу (первого врага показываем сразу
    // в зоне видимости игрока). По умолчанию false — загруженная игра.
    global.isNewGame = false

    // Если пусто, значит новая игра и иницилазируем базовые карты
    if (array_length(variable_struct_get_names(global.playerData.collection)) == 0) {
        global.isNewGame = true
        playerGrantStarterCards()
        playerDataSave()
    }
}

// Начать новую игру: свежие данные, стартовые карты, флаг новой игры
function playerDataNewGame() {
    global.playerData = playerDataDefault()
    global.isNewGame = true
    playerGrantStarterCards()
    playerDataSave()
}

// Иницилазиация базовых карт и стартовых дек героев.
// На старте у каждого героя ровно 3 карты обычной редкости.
function playerGrantStarterCards() {
    var C = global.CardId;

    // Открываем базовые карты. Количество = сколько нужно на стартовые деки обоих героев.
    unlockCard(C.physicalDamageSingleTarget, CardsRarity.Default, 2)      // Вив: 2 атакующие
    unlockCard(C.magicalDamageSingleTarget)                              // Лана: магическая
    unlockCard(C.instantHealSingleTarget)                               // Лана: лечащая
    unlockCard(C.buffPhysicalDamageSingleTarget, CardsRarity.Default, 2) // Лана + Вив: усиливающая

    // Лана: 1 магическая, 1 усиливающая, 1 лечащая
    setDeckSlot(Characters.Lana, 0, C.magicalDamageSingleTarget)
    setDeckSlot(Characters.Lana, 1, C.buffPhysicalDamageSingleTarget)
    setDeckSlot(Characters.Lana, 2, C.instantHealSingleTarget)

    // Вив: 2 атакующие, 1 усиливающая
    setDeckSlot(Characters.Viv, 0, C.physicalDamageSingleTarget)
    setDeckSlot(Characters.Viv, 1, C.physicalDamageSingleTarget)
    setDeckSlot(Characters.Viv, 2, C.buffPhysicalDamageSingleTarget)
}

// Моковые данные о пользователе
function playerDataDefault() {
    return {
        version: 1,
        collection: {}, // key "id@rarity" -> { id, rarity, count }
        decks: {
            lana: { unlocked: DECK_DEFAULT_UNLOCKED, cards: [] },  // cards: [{slot,id,rarity}]
            viv:  { unlocked: DECK_DEFAULT_UNLOCKED, cards: [] }
        }
    }
}

// Сохранить данные о пользователе на устройство
function playerDataSave() {
    var stringPlayerData = json_stringify(global.playerData)
    var bufPlayerData = buffer_create(string_byte_length(stringPlayerData) + 1, buffer_fixed, 1)
    buffer_write(bufPlayerData, buffer_string, stringPlayerData)
    buffer_save(bufPlayerData, PLAYER_SAVE_FILE)
    buffer_delete(bufPlayerData)
}

// Загрузить данные о пользователе с устройства
function playerDataLoad() {
    if (!file_exists(PLAYER_SAVE_FILE)) return false
    try {
        var bufPlayerData = buffer_load(PLAYER_SAVE_FILE)
        var stringPlayerData = buffer_read(bufPlayerData, buffer_string)
        buffer_delete(bufPlayerData)
        global.playerData = json_parse(stringPlayerData)
        return true
    } catch (error) {
        show_debug_message("playerDataLoad failed: " + string(error))
        return false
    }
}

//// Вспомогательные методы для конвертации в удобный для экспорта вид

// Мапим персонажей в строку
function characterKey(character) {
    switch (character) {
        case Characters.Lana: return "lana"
        case Characters.Viv: return "viv"
        default: return "lana"
    }
}

// Нужно мапить айди карты и редкость карты в одну строку, чтобы потом восстанавливать карты как структуры 
// и не создавать дофига айдишек для каждой редкости
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
    if (!cardCanVaryRarity(cardIdentifier)) rarity = CardsRarity.Default
        
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
    for (var i = 0; i < array_length(cardKeys); i++) array_push(result, collection[$ cardKeys[i]])
    return result
}

// Массив структур кард
function getCollectionCards() {
    var references = getCollectionRefs()
    var result  = []
    for (var i = 0; i < array_length(references); i++) {
        var card = cardFromRef(references[i])
        if (card != undefined) { array_push(result, card) }
    }
    return result
}

//// Работа с деками

// Количество кард в деке персонажа
function countCardInDeck(character, cardIdentifier, rarity) {
    var cards = deckOf(character).cards
    var count = 0
    for (var i = 0; i < array_length(cards); i++)
        if (cards[i].id == cardIdentifier && cards[i].rarity == rarity) count++
    return count
}

// Карта персонажа в слоте в деке персонажа, если есть 
function deckSlotRef(character, slot) {
    var cards = deckOf(character).cards
    for (var i = 0; i < array_length(cards); i++)
        if (cards[i].slot == slot) return cards[i]
    return undefined
}

// Очистить слот в деке персонажа
function clearDeckSlot(character, slot) {
    var deck = deckOf(character)
    for (var i = 0; i < array_length(deck.cards); i++) {
        if (deck.cards[i].slot == slot) { 
            array_delete(deck.cards, i, 1)
            return 
        }
    }
}

// Добавить карту в деку персонажа
function setDeckSlot(character, slot, cardIdentifier, rarity = CardsRarity.Default) {
    if (!cardCanVaryRarity(cardIdentifier)) rarity = CardsRarity.Default

    var deck = deckOf(character)
    if (slot < 0 || slot >= deck.unlocked)
        return false
    if (!isCardOwned(cardIdentifier, rarity)) 
        return false

    var existing = deckSlotRef(character, slot)
    var alreadyHere = (existing != undefined && existing.id == cardIdentifier && existing.rarity == rarity)

    if (alreadyHere) return false

    clearDeckSlot(character, slot)
    array_push(deck.cards, { slot: slot, id: cardIdentifier, rarity: rarity })
    return true
}

// Разблокировать слот в деке персонажа
function unlockDeckSlot(character, _count = 1) {
    var deck = deckOf(character)
    deck.unlocked = min(DECK_CAPACITY, deck.unlocked + _count)
}

// Очистить деку персонажа 
function clearDeck(character) {
    deckOf(character).cards = []
}

//// Работа с UI декбилдера

// Построение слотов для панели всех карт, заполненные картой + пустые
function buildCollectionSlots(category = undefined, cols = 4) {
    var refs = getCollectionRefs()
    var entries = [] // { card, ref }
    for (var i = 0; i < array_length(refs); i++) {
        var card = cardFromRef(refs[i])
        if (card == undefined) continue
        if (category == undefined || cardCategoryOf(card) == category)
            array_push(entries, { card: card, ref: refs[i] })
    }

    var count = array_length(entries)
    var total = max(cols, ceil(count / cols) * cols)

    var slots = []
    for (var i = 0; i < total; i++) {
        if (i < count) {
            var slot = new Slot("filled", entries[i].card)
            slot.ref = entries[i].ref
            array_push(slots, slot)
        } else {
            array_push(slots, new Slot("empty"))
        }
    }
    return slots;
}

// Построение слотов для панели деки персонажа, пустые, залоченные и заполненные картой.
function buildDeckSlots(character, total = DECK_CAPACITY) {
    var deck = deckOf(character)
    var slots = []
    for (var i = 0; i < total; i++) {
        if (i >= deck.unlocked) { 
            array_push(slots, new Slot("locked"))
            continue 
        }
        var ref = deckSlotRef(character, i)
        if (ref != undefined) array_push(slots, new Slot("filled", cardFromRef(ref)))
        else array_push(slots, new Slot("empty"))
    }
    return slots
}

//// Вспомогательные методы

// Открыть количество карт
function unlockAllCards(count = 9) {
    var keys = variable_struct_get_names(global.cardRegistry)
    for (var i = 0; i < array_length(keys); i++) 
        unlockCard(keys[i], CardsRarity.Default, count)
}

// Ресет данных для теста
function playerDataResetForTesting() {
    global.playerData = playerDataDefault()
    playerDataSave()
}