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
    questMigrateSaveData()
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
        quests: {},
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

function chestGoldAmount() {
    return CHEST_GOLD_MIN + irandom(CHEST_GOLD_RANGE)
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
    var bobOffset = guiHeight - (sin(current_time / 200) * screenScale * guiPerScreenPixel * 2)
    var spriteHeight = sprite_get_height(LanaIcon) * iconScale
    draw_sprite_ext(LanaIcon, 0,
        margin + sprite_get_xoffset(LanaIcon) * iconScale,
       sprite_get_yoffset(LanaIcon) * iconScale + bobOffset - margin - spriteHeight,
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

// Мап персонажей в строку
