// Windows
#macro GA_GAME_KEY_WINDOWS   "eeb1fc90c1d9dc9ebb8e824a8ad9c567"  
#macro GA_SECRET_KEY_WINDOWS "641c05f675d979c8abfcbef843e21e96eecb0040"  
// macOS
#macro GA_GAME_KEY_MAC       "423ff3a9a15575d57ceada2777c66c7e" 
#macro GA_SECRET_KEY_MAC     "29a1cc00199b2115969e52540728c862baab46ef" 

#macro GA_BUILD_VERSION "0.1.0" 

#macro GA_DEBUG true // публиковать лог в консоль

// Отключаем отправку аналитики
#macro GA_ENABLED false

//// Инициализация
// Вызывается из Create объекта oAnalytics
function analyticsInit() {
    if (!GA_ENABLED) { return } // отправка аналитики отключена
    if (variable_global_exists("gaReady") && global.gaReady) {
        return
    }

    global.gaReady = false;
    global.gaBattleId = 0 // 0 = вне боя; +1 на каждый бой за сессию
    global.gaBattleTag = "none" // строковый тег текущего боя (b1, b2, ...)
    global.gaBattleArea = "overworld" // раздел, где идёт бой
    global.gaBattleFoe = "none" // противник текущего боя

    // Выбор ключей и метки платформы по ОС:
    var _key, _secret, _platform;
    switch (os_type) {
        case os_macosx:
            _key = GA_GAME_KEY_MAC
            _secret = GA_SECRET_KEY_MAC
            _platform = "mac"
            break
        default: 
            _key = GA_GAME_KEY_WINDOWS
            _secret = GA_SECRET_KEY_WINDOWS
            _platform = "windows"
            break
    }

    ga_configureBuild(_platform + " " + GA_BUILD_VERSION);
    ga_configureAvailableResourceCurrencies(["gold", "energy"]);
    ga_configureAvailableResourceItemTypes(["shop", "battle", "reward", "chest", "quest"]);
    ga_setEnabledInfoLog(GA_DEBUG) // GA пишет свои логи в Output
    ga_setEnabledVerboseLog(GA_DEBUG) // Логи отправки

    ga_initialize(_key, _secret)
    global.gaReady = true
    analyticsLog("initialized: platform=" + _platform)
}

function analyticsEnsure() {
    if (!GA_ENABLED) { return false } // отправка аналитики отключена
    if (!variable_global_exists("gaReady")) {
        global.gaReady = false
    }
    if (global.gaReady) { 
        return true
    }
    if (!instance_exists(oAnalytics)) {
        instance_create_depth(0, 0, 0, oAnalytics)
    }
    else { 
        analyticsInit()
    }
    return global.gaReady
}

// Хелперы
// Конверт в строку
function analyticsToken(_v) {
    var s = is_string(_v) ? _v : string(_v);
    s = string_replace_all(s, ":", "_");
    s = string_replace_all(s, " ", "_");
    if (s == "") { s = "none"; }
    return s;
}

// lowercase
function analyticsCharToken(_v) {
    return string_lower(analyticsToken(_v));
}

// Редкость в строку
function analyticsRarityName(_r) {
    if (is_string(_r)) { return string_lower(_r); }
    switch (_r) {
        case CardsRarity.Default: return "default";
        case CardsRarity.Unusual: return "unusual";
        case CardsRarity.Rare: return "rare";
        case CardsRarity.Epic: return "epic";
        default: return "r" + string(_r);
    }
}

// Лог аналитики в Output
function analyticsLog(_msg) {
    if (GA_DEBUG) { show_debug_message("[GA] " + _msg); }
}

// UI события
function analyticsDesign(_eventId, _value = undefined) {
    if (!analyticsEnsure()) { return; }
    if (is_undefined(_value)) {
        ga_addDesignEvent(_eventId);
        analyticsLog("design   " + _eventId);
    } else {
        ga_addDesignEvent(_eventId, _value);
        analyticsLog("design   " + _eventId + " = " + string(_value));
    }
}

// Событие прогрессии
function analyticsProgression(_status, _p1, _p2, _p3) {
    if (!analyticsEnsure()) { return; }
    ga_addProgressionEvent(_status, _p1, _p2, _p3);
    var _st = (_status == GA_PROGRESSIONSTATUS_START) ? "Start"
            : ((_status == GA_PROGRESSIONSTATUS_COMPLETE) ? "Complete"
            : ((_status == GA_PROGRESSIONSTATUS_FAIL) ? "Fail" : string(_status)));
    analyticsLog("progress " + _st + "  " + _p1 + ":" + _p2 + ":" + _p3);
}

// Ресурс событие 
function analyticsResource(_flow, _currency, _amount, _itemType, _itemId) {
    if (!analyticsEnsure()) { return; }
    ga_addResourceEvent(_flow, _currency, _amount, _itemType, _itemId);
    var _f = (_flow == GA_RESOURCEFLOWTYPE_SOURCE) ? "Source" : "Sink";
    analyticsLog("resource " + _f + "  " + string(_amount) + " " + _currency + "  (" + _itemType + ":" + _itemId + ")");
}

// Меню
function analyticsNewGame()  { 
    analyticsDesign("game:new_game") 
}

function analyticsContinue() { 
    analyticsDesign("game:continue")
}

// Бой
// новый id, чтобы группировать события одной битвы
function analyticsBattleStart(_area = "overworld", _foe = "enemy") {
    if (!analyticsEnsure()) { return; }
    global.gaBattleId++;
    global.gaBattleArea = analyticsToken(_area);
    global.gaBattleFoe  = analyticsToken(_foe);
    global.gaBattleTag  = "b" + string(global.gaBattleId);
    analyticsProgression(GA_PROGRESSIONSTATUS_START, global.gaBattleArea, global.gaBattleFoe, global.gaBattleTag);
    analyticsDesign("battle:start", global.gaBattleId);
}

function analyticsWin() {
    if (!analyticsEnsure()) { return; }
    analyticsProgression(GA_PROGRESSIONSTATUS_COMPLETE, global.gaBattleArea, global.gaBattleFoe, global.gaBattleTag);
    analyticsDesign("battle:win", global.gaBattleId);
}

function analyticsDefeat() {
    if (!analyticsEnsure()) { return; }
    analyticsProgression(GA_PROGRESSIONSTATUS_FAIL, global.gaBattleArea, global.gaBattleFoe, global.gaBattleTag);
    analyticsDesign("battle:defeat", global.gaBattleId);
}

function analyticsRetreat() {
    if (!analyticsEnsure()) { return; }
    analyticsDesign("battle:retreat", global.gaBattleId)
}

function analyticsShuffle() {
    if (!analyticsEnsure()) { return; }
    analyticsDesign("battle:shuffle", global.gaBattleId)
}

function analyticsPlayCard(_cardId, _rarity, _character) {
    if (!analyticsEnsure()) { return; }
    var ev = "battle:play_card:" + analyticsCharToken(_character)
           + ":" + analyticsRarityName(_rarity)
           + ":" + analyticsToken(_cardId);
    analyticsDesign(ev, global.gaBattleId);
}

// Карты
function analyticsReward(_cardId, _rarity, _source = "battle") {
    if (!analyticsEnsure()) { return; }
    var ev = "reward:" + analyticsToken(_source)
           + ":" + analyticsRarityName(_rarity)
           + ":" + analyticsToken(_cardId);
    analyticsDesign(ev, global.gaBattleId);
}

function analyticsAddToDeck(_character, _cardId, _rarity) {
    var ev = "deck:add:" + analyticsCharToken(_character)
           + ":" + analyticsRarityName(_rarity)
           + ":" + analyticsToken(_cardId);
    analyticsDesign(ev);
}

// Сундуки
function analyticsChestOpen(_kind) {
    var k;
    switch (_kind) {
        case ChestKind.Gold:  k = "gold"; break;
        case ChestKind.Card:  k = "card"; break;
        case ChestKind.Enemy: k = "trap"; break;
        default:              k = analyticsToken(_kind); break;
    }
    analyticsDesign("chest:open:" + k);
}

// Золото, выпавшее из сундука
function analyticsChestGold(_amount) {
    analyticsDesign("chest:gold", _amount);
    if (_amount > 0) { analyticsResource(GA_RESOURCEFLOWTYPE_SOURCE, "gold", _amount, "chest", "chest"); }
}

// Магазин
function analyticsPurchase(_itemId, _price = 0) {
    var _it = analyticsToken(_itemId);
    analyticsDesign("shop:purchase:" + _it, _price);
    if (_price > 0) { analyticsResource(GA_RESOURCEFLOWTYPE_SINK, "gold", _price, "shop", _it); }
}

// Квест 
function analyticsStartSafarQuest() {
    analyticsProgression(GA_PROGRESSIONSTATUS_START, "quest", "safar_spear", "");
    analyticsDesign("quest:safar:start");
}

function analyticsCompleteSafarQuest() {
    analyticsProgression(GA_PROGRESSIONSTATUS_COMPLETE, "quest", "safar_spear", "");
    analyticsDesign("quest:safar:complete");
}

