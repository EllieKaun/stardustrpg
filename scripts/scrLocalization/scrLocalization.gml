// Локализация
// Инициализация
function locEnsure() {
    if (!variable_global_exists("locStrings")) {
        locInit()
    }
}

function locInit() {
    global.locStrings = {}
    global.locLangs = ["en", "ru"]
    global.locFallback = "en"
    locDefineEn()
    locDefineRu()
    global.language = locLoadLang()
}

// Уточнение языка
function locLoadLang() {
    ini_open("settings.ini")
    var saved = ini_read_string("General", "Language", "")
    ini_close()
    if (saved == "en" || saved == "ru") { return saved }
    return (os_get_language() == "ru") ? "ru" : "en"
}

// Установка языка
function setLanguage(lang) {
    if (!array_contains(global.locLangs, lang)) { 
        return
    }
    global.language = lang
    ini_open("settings.ini")
    ini_write_string("General", "Language", lang)
    ini_close()
    locInvalidateCaches()
}

function locCycleLanguage() {
    locEnsure()
    var index = 0
    for (var i = 0; i < array_length(global.locLangs); i++) {
        if (global.locLangs[i] == global.language) { 
            index = i 
            break 
        }
    }
    var next = global.locLangs[(index + 1) mod array_length(global.locLangs)]
    setLanguage(next)
    return next
}

// Очистить сохраненные локали
function locInvalidateCaches() {
    if (variable_global_exists("cardFaceLayouts")) { global.cardFaceLayouts = {} }
}

// Достать перевод по ключу
function loc(key) {
    return locDef(key, key)
}

// Инициализация переводов
function locDef(key, fallbackValue) {
    locEnsure()
    var table = global.locStrings[$ global.language]
    if (table != undefined && variable_struct_exists(table, key)) { return table[$ key] }
    var fallback = global.locStrings[$ global.locFallback]
    if (fallback != undefined && variable_struct_exists(fallback, key)) { return fallback[$ key] }
    return fallbackValue
}

// Инициализация имен карт
function locBuildCardNameMap() {
    global.locCardNameToId = {}
    if (!variable_global_exists("cardRegistry")) { return }
    var cardKeys = variable_struct_get_names(global.cardRegistry)
    for (var i = 0; i < array_length(cardKeys); i++) {
        var cardDefinition = global.cardRegistry[$ cardKeys[i]]
        var built = cardDefinition.build(CardsRarity.Default)
        if (is_struct(built) && variable_struct_exists(built, "name")) {
            global.locCardNameToId[$ built.name] = cardKeys[i]
        }
    }
}

// Взять ID из имени
function locCardIdFromName(rawName) {
    if (!variable_global_exists("cardRegistry")) { return "" }
    if (!variable_global_exists("locCardNameToId")) { locBuildCardNameMap() }
    return variable_struct_exists(global.locCardNameToId, rawName) ? global.locCardNameToId[$ rawName] : ""
}

// Локализация ключа карты
function locKeyForCard(card) {
    if (is_struct(card) && variable_struct_exists(card, "cardId")) { return string(card.cardId) }
    if (is_struct(card) && variable_struct_exists(card, "name")) {
        var mapped = locCardIdFromName(card.name)
        if (mapped != "") { return mapped }
        return string(card.name)
    }
    return ""
}

// Имя карты
function cardDisplayName(card) {
    var fallback = (is_struct(card) && variable_struct_exists(card, "name")) ? card.name : ""
    return locDef("card.name." + locKeyForCard(card), fallback)
}

// Описание карты
function cardDisplayDesc(card) {
    var fallback = (is_struct(card) && variable_struct_exists(card, "description")) ? card.description : ""
    return cardDescFill(locDef("card.desc." + locKeyForCard(card), fallback), card)
}

//// Подстановки в описаниях карт
// В тексте описания можно писать метки, они заменяются данными самой карты:
//   {turns}    - длительность: "1 ход", "2 хода", "5 ходов"   ("... (4 хода)")
//   {turnsGen} - длительность в родительном падеже: "1 хода", "2 ходов" ("в течение 2 ходов")
// Число берётся из эффектов карты, поэтому текст не расходится с балансом и редкостью

// Длительность карты: первый её эффект, у которого есть duration. Нет таких - undefined
function cardDurationTurns(card) {
    if (!is_struct(card) || !variable_struct_exists(card, "effects")) { return undefined }
    var effects = card.effects
    for (var effectIndex = 0; effectIndex < array_length(effects); effectIndex++) {
        var effect = effects[effectIndex]
        if (is_struct(effect) && variable_struct_exists(effect, "duration") && is_real(effect.duration)) {
            return effect.duration
        }
    }
    return undefined
}

// Форма слова для числа: "one" / "few" / "many" по правилам текущего языка
function locPluralForm(count) {
    if (global.language == "ru") {
        var lastDigit = count mod 10
        var lastTwoDigits = count mod 100
        if (lastDigit == 1 && lastTwoDigits != 11) { return "one" }
        if (lastDigit >= 2 && lastDigit <= 4 && (lastTwoDigits < 12 || lastTwoDigits > 14)) { return "few" }
        return "many"
    }
    return (count == 1) ? "one" : "many"
}

// "4 хода" / "4 turns": число и слово из ключей <wordKey>.one / .few / .many
function locCountPhrase(count, wordKey) {
    return string(count) + " " + loc(wordKey + "." + locPluralForm(count))
}

// Заменить метки в описании данными карты
function cardDescFill(text, card) {
    if (string_pos("{", text) == 0) { return text } // меток нет - быстрый выход
    var turns = cardDurationTurns(card)
    if (turns == undefined) { return text }
    text = string_replace_all(text, "{turnsGen}", locCountPhrase(turns, "turnsGen"))
    text = string_replace_all(text, "{turns}", locCountPhrase(turns, "turns"))
    return text
}

// Имя игрока
function unitDisplayName(rawName) {
    return locDef("unit." + string(rawName), string(rawName))
}

// Имя спискера в диалоге
function speakerDisplayName(rawName) {
    return locDef("speaker." + string(rawName), string(rawName))
}

// Название языка
function languageNativeName(lang) {
    switch (lang) {
        case "en": return "English"
        case "ru": return "Русский"
    }
    return lang
}

