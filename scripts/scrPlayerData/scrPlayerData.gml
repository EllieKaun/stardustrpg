enum Characters { Lana, Viv }

#macro PLAYER_SAVE_FILE "player_data.json"
#macro DECK_DEFAULT_UNLOCKED 4 // слотов деки открыто с начала игры
#macro DECK_CAPACITY 12 // максимум слотов деки
#macro ZONE_DECK_SLOT_LIMITS [6] // сколько слотов деки можно открыть максимум в зоне

// Инициализация пользователя (каждый раз на старте)
function playerDataInit() {
    // global.playerData - свойство для хранения структуры пользователя для сохранения
    if (!playerDataLoad()) { global.playerData = playerDataDefault() }

    // Флаг новой игры
    global.isNewGame = false

    // Если пусто, значит новая игра и иницилазируем базовые карты
    if (array_length(variable_struct_get_names(global.playerData.collection)) == 0) {
        global.isNewGame = true
        playerGrantStarterCards()
        playerDataSave()
    }

    if (!variable_struct_exists(global.playerData, "tutorialDone")) {
        global.playerData.tutorialDone = !global.isNewGame
    }
    if (!variable_struct_exists(global.playerData, "deckTutorialDone")) {
        global.playerData.deckTutorialDone = !global.isNewGame
    }
    if (!variable_struct_exists(global.playerData, "wins")) {
        global.playerData.wins = 0
    }
    if (!variable_struct_exists(global.playerData, "questSafarSpear")) {
        var joined = variable_global_exists("safarJoined") && global.safarJoined
        global.playerData.questSafarSpear = joined ? QuestSpearState.Completed : QuestSpearState.Inactive
    }
    // Миграция старых строковых сейвов в enum
    if (is_string(global.playerData.questSafarSpear)) {
        var questRaw = global.playerData.questSafarSpear
        var mapped = QuestSpearState.Inactive
        if (questRaw == "active") { mapped = QuestSpearState.Active }
        else if (questRaw == "spearObtained") { mapped = QuestSpearState.SpearObtained }
        else if (questRaw == "completed") { mapped = QuestSpearState.Completed }
        global.playerData.questSafarSpear = mapped
    }
}

// Начать новую игру: свежие данные, стартовые карты, флаг новой игры
function playerDataNewGame() {
    global.playerData = playerDataDefault()
    global.isNewGame = true
    playerGrantStarterCards()
    playerDataSave()
}

// Иницилазиация базовых карт и стартовых дек героев
function playerGrantStarterCards() {
    var cardIds = global.CardId;

    // Открываем базовые карты
    unlockCard(cardIds.physicalDamageSingleTarget, CardsRarity.Default, 2) // Вив: 2 атакующие
    unlockCard(cardIds.instantManaGainSingleTarget, CardsRarity.Default, 1) // Мана
    unlockCard(cardIds.magicalDamageSingleTarget) // Лана: магическая
    unlockCard(cardIds.instantHealSingleTarget) // Лана: лечащая
    unlockCard(cardIds.buffPhysicalDamageSingleTarget, CardsRarity.Default, 2) // Лана и Вив усиливающая

    setDeckSlot(Characters.Lana, 0, cardIds.magicalDamageSingleTarget)
    setDeckSlot(Characters.Lana, 1, cardIds.buffPhysicalDamageSingleTarget)
    setDeckSlot(Characters.Lana, 2, cardIds.instantHealSingleTarget)

    setDeckSlot(Characters.Viv, 0, cardIds.physicalDamageSingleTarget)
    setDeckSlot(Characters.Viv, 1, cardIds.physicalDamageSingleTarget)
    setDeckSlot(Characters.Viv, 2, cardIds.buffPhysicalDamageSingleTarget)
}

// Моковые данные о пользователе
function playerDataDefault() {
    return {
        version: 1,
        gold: 0, // золото
        tutorialDone: false,
        deckTutorialDone: false,
        questSafarSpear: QuestSpearState.Inactive,
        wins: 0,
        collection: {}, // key "id@rarity" -> { id, rarity, count }
        decks: {
            lana: { unlocked: DECK_DEFAULT_UNLOCKED, cards: [] },  // cards: [{slot,id,rarity}]
            viv:  { unlocked: DECK_DEFAULT_UNLOCKED, cards: [] }
        }
    }
}

//// Золото 

// Текущий баланс 
function getGold() {
    if (!variable_struct_exists(global.playerData, "gold")) { global.playerData.gold = 0 }
    return global.playerData.gold
}

// Отнять все деньги
function loseAllGold() {
    global.playerData.gold = 0
    playerDataSave()
}

// Изменить баланс на amount
function addGold(amount) {
    global.playerData.gold = max(0, getGold() + amount)
    playerDataSave()
    return global.playerData.gold
}

// Списать amount, если хватает
function spendGold(amount) {
    if (getGold() < amount) { return false }
    global.playerData.gold = getGold() - amount
    playerDataSave()
    return true
}

function getWins() {
    if (!variable_struct_exists(global.playerData, "wins")) { global.playerData.wins = 0 }
    return global.playerData.wins
}

function addWin() {
    global.playerData.wins = getWins() + 1
    playerDataSave()
    return global.playerData.wins
}

function enemyStatBonus() {
    return floor(getWins() / ENEMY_WIN_INTERVAL) * ENEMY_WIN_BONUS
}

function chestGoldAmount() {
    return CHEST_GOLD_MIN + irandom(CHEST_GOLD_RANGE)
}

function spearSprite() {
    var sprite = asset_get_index("spear")
    return sprite_exists(sprite) ? sprite : noone
}

function spearBattleSprite() {
    var sprite = asset_get_index("bigSpear")
    return sprite_exists(sprite) ? sprite : noone
}

function spearBattleBonus() {
    return SPEAR_BATTLE_BONUS
}

function questSpearState() {
    if (!variable_struct_exists(global.playerData, "questSafarSpear")) { global.playerData.questSafarSpear = QuestSpearState.Inactive }
    return global.playerData.questSafarSpear
}

function questSetSpearState(state) {
    global.playerData.questSafarSpear = state
    playerDataSave()
}

function questAcceptSpear() {
    questSetSpearState(QuestSpearState.Active)
    analyticsStartSafarQuest() // аналитика: начат квест Safar
    unlockCard(global.CardId.stealCard, CardsRarity.Default, 1)
    var slot = firstFreeDeckSlot(Characters.Lana)
    if (slot >= 0) { setDeckSlot(Characters.Lana, slot, global.CardId.stealCard, CardsRarity.Default) }
    playerDataSave()
    var rewardCard = cardFromRef({ id: global.CardId.stealCard, rarity: CardsRarity.Default })
    showCardReward(rewardCard, loc("ui.newCard") + " " + cardDisplayName(rewardCard))
}

function questGrantSpear() {
    if (questSpearState() == QuestSpearState.Active) {
        questSetSpearState(QuestSpearState.SpearObtained)
    }
    if (variable_global_exists("spearCarrierExists")) { global.spearCarrierExists = false }
    if (variable_global_exists("battleHasSpear")) { global.battleHasSpear = false }
}

function questCompleteSpear() {
    questSetSpearState(QuestSpearState.Completed)
    global.safarJoined = true
    analyticsCompleteSafarQuest() // аналитика
    playerDataSave()
}

function tutorialIsDone() {
    if (!variable_struct_exists(global.playerData, "tutorialDone")) { return true }
    return global.playerData.tutorialDone
}

function markTutorialDone() {
    global.playerData.tutorialDone = true
    playerDataSave()
}

function deckTutorialIsDone() {
    if (!variable_struct_exists(global.playerData, "deckTutorialDone")) { return true }
    return global.playerData.deckTutorialDone
}

function markDeckTutorialDone() {
    global.playerData.deckTutorialDone = true
    playerDataSave()
}

// Сохранить данные о пользователе на устройство
function playerDataSave() {
    var stringPlayerData = json_stringify(global.playerData)
    var bufPlayerData = buffer_create(string_byte_length(stringPlayerData) + 1, buffer_fixed, 1)
    buffer_write(bufPlayerData, buffer_string, stringPlayerData)
    buffer_save(bufPlayerData, PLAYER_SAVE_FILE)
    buffer_delete(bufPlayerData)
}

//// Автосохранение

#macro AUTOSAVE_INTERVAL_SECONDS 180 // раз в 3 минуты игры
#macro AUTOSAVE_ICON_SECONDS 2.5 // сколько показывать иконку Ланы

// Вызывать каждый шаг в комнатах, где идёт игра
function autosaveUpdate() {
    if (!variable_global_exists("playerData")) { return }
    if (!variable_global_exists("autosavePlayTime")) {
        global.autosavePlayTime = 0
        global.autosaveIconStart = -1
    }
    global.autosavePlayTime += min(delta_time, 100000) / 1000000
    if (global.autosavePlayTime < AUTOSAVE_INTERVAL_SECONDS) { return }

    global.autosavePlayTime = 0
    playerDataSave()
    global.autosaveIconStart = current_time
}

function autosaveDrawIcon() {
    if (!variable_global_exists("autosaveIconStart") || global.autosaveIconStart < 0) { return }
    var elapsedSeconds = (current_time - global.autosaveIconStart) / 1000
    if (elapsedSeconds >= AUTOSAVE_ICON_SECONDS) { return }

    var fadeInSeconds = 0.3
    var fadeOutSeconds = 0.6
    var alpha = min(1, elapsedSeconds / fadeInSeconds, (AUTOSAVE_ICON_SECONDS - elapsedSeconds) / fadeOutSeconds)

    var guiHeight = display_get_gui_height()
    var guiPerScreenPixel = guiHeight / window_get_height()
    var screenScale = max(1, round(window_get_height() * 0.09 / sprite_get_height(LanaIcon)))
    var iconScale = screenScale * guiPerScreenPixel
    var margin = guiHeight * 0.03
    var bobOffset = sin(current_time / 200) * screenScale * guiPerScreenPixel * 2

    draw_sprite_ext(LanaIcon, 0,
        margin + sprite_get_xoffset(LanaIcon) * iconScale,
        margin + sprite_get_yoffset(LanaIcon) * iconScale + bobOffset,
        iconScale, iconScale, 0, c_white, alpha)
}

// Загрузить данные о пользователе с устройства
function playerDataLoad() {
    if (!file_exists(PLAYER_SAVE_FILE)) { return false }
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

// Мап персонажей в строку
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
        if (cardRef != undefined) { array_push(slots, new Slot("filled", cardFromRef(cardRef))) }
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