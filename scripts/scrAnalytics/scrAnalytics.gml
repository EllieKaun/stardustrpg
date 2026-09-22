// scrAnalytics — единый слой событий GameAnalytics для игры.
// Игровой код вызывает функции analytics*(), а НЕ ga_*() напрямую.
// Ключи бери в GameAnalytics: страница игры → Settings (шестерёнка) → Game information.

// Ключи GameAnalytics — своя игра (и свои ключи) на каждую платформу.
// Windows / прочий десктоп:
#macro GA_GAME_KEY_WINDOWS   "eeb1fc90c1d9dc9ebb8e824a8ad9c567"     // <-- Game Key игры Windows
#macro GA_SECRET_KEY_WINDOWS "641c05f675d979c8abfcbef843e21e96eecb0040"   // <-- Secret Key игры Windows
// macOS:
#macro GA_GAME_KEY_MAC       "423ff3a9a15575d57ceada2777c66c7e"     // <-- Game Key игры macOS
#macro GA_SECRET_KEY_MAC     "29a1cc00199b2115969e52540728c862baab46ef"   // <-- Secret Key игры macOS

#macro GA_BUILD_VERSION "0.1.0" // версия сборки; меняй при релизах (платформа подставится сама)

#macro GA_DEBUG true // печатать события в Output (show_debug_message) + включить лог самого GA. На релиз — false.

// ==================== ИНИЦИАЛИЗАЦИЯ ====================
// Вызывается из Create объекта oAnalytics один раз за запуск.
function analyticsInit() {
    if (variable_global_exists("gaReady") && global.gaReady) return; // уже готово

    global.gaReady      = false;
    global.gaBattleId   = 0;           // 0 = вне боя; +1 на каждый бой за сессию
    global.gaBattleTag  = "none";      // строковый тег текущего боя (b1, b2, ...)
    global.gaBattleArea = "overworld"; // раздел, где идёт бой
    global.gaBattleFoe  = "none";      // противник текущего боя

    // Выбор ключей и метки платформы по ОС:
    var _key, _secret, _platform;
    switch (os_type) {
        case os_macosx:
            _key = GA_GAME_KEY_MAC;     _secret = GA_SECRET_KEY_MAC;     _platform = "mac";     break;
        default: // os_windows и любой прочий десктоп
            _key = GA_GAME_KEY_WINDOWS; _secret = GA_SECRET_KEY_WINDOWS; _platform = "windows"; break;
    }

    // Конфигурация строго ДО ga_initialize (после — игнорируется):
    ga_configureBuild(_platform + " " + GA_BUILD_VERSION);
    ga_configureAvailableResourceCurrencies(["gold", "energy"]);
    ga_configureAvailableResourceItemTypes(["shop", "battle", "reward", "chest", "quest"]);
    ga_setEnabledInfoLog(GA_DEBUG);    // GA пишет свои логи в Output
    ga_setEnabledVerboseLog(GA_DEBUG); // + подробные логи отправки (HTTP-запросы/ответы)

    ga_initialize(_key, _secret);
    global.gaReady = true;
    analyticsLog("initialized: platform=" + _platform + ", gameKey=" + string_copy(_key, 1, 6) + "…");
}

// Гарантирует инициализацию (создаёт oAnalytics, если его ещё нет).
function analyticsEnsure() {
    if (!variable_global_exists("gaReady")) global.gaReady = false;
    if (global.gaReady) return true;
    if (!instance_exists(oAnalytics)) instance_create_depth(0, 0, 0, oAnalytics); // Create → analyticsInit()
    else analyticsInit();
    return global.gaReady;
}

// ==================== ВСПОМОГАТЕЛЬНЫЕ ====================
// Приводит значение к безопасной строке для id события GA (без ":" и пробелов).
// Регистр сохраняем — id карт (camelCase) читаемее в дашборде.
function analyticsToken(_v) {
    var s = is_string(_v) ? _v : string(_v);
    s = string_replace_all(s, ":", "_");
    s = string_replace_all(s, " ", "_");
    if (s == "") s = "none";
    return s;
}

// Ключ персонажа в нижнем регистре — чтобы "Lana" (из боя) и "lana"
// (из characterKey) не превращались в разные значения.
function analyticsCharToken(_v) {
    return string_lower(analyticsToken(_v));
}

// CardsRarity → строка. Принимает enum (0..3) или готовую строку.
function analyticsRarityName(_r) {
    if (is_string(_r)) return string_lower(_r);
    switch (_r) {
        case CardsRarity.Default: return "default";
        case CardsRarity.Unusual: return "unusual";
        case CardsRarity.Rare:    return "rare";
        case CardsRarity.Epic:    return "epic";
        default:                  return "r" + string(_r);
    }
}

// Лог аналитики в Output (при GA_DEBUG).
function analyticsLog(_msg) {
    if (GA_DEBUG) show_debug_message("[GA] " + _msg);
}

// Дизайн-событие с необязательным числовым значением.
function analyticsDesign(_eventId, _value = undefined) {
    if (!analyticsEnsure()) return;
    if (is_undefined(_value)) {
        ga_addDesignEvent(_eventId);
        analyticsLog("design   " + _eventId);
    } else {
        ga_addDesignEvent(_eventId, _value);
        analyticsLog("design   " + _eventId + " = " + string(_value));
    }
}

// Progression-событие (Start/Complete/Fail) с логом.
function analyticsProgression(_status, _p1, _p2, _p3) {
    if (!analyticsEnsure()) return;
    ga_addProgressionEvent(_status, _p1, _p2, _p3);
    var _st = (_status == GA_PROGRESSIONSTATUS_START) ? "Start"
            : ((_status == GA_PROGRESSIONSTATUS_COMPLETE) ? "Complete"
            : ((_status == GA_PROGRESSIONSTATUS_FAIL) ? "Fail" : string(_status)));
    analyticsLog("progress " + _st + "  " + _p1 + ":" + _p2 + ":" + _p3);
}

// Resource-событие (Source/Sink) с логом.
function analyticsResource(_flow, _currency, _amount, _itemType, _itemId) {
    if (!analyticsEnsure()) return;
    ga_addResourceEvent(_flow, _currency, _amount, _itemType, _itemId);
    var _f = (_flow == GA_RESOURCEFLOWTYPE_SOURCE) ? "Source" : "Sink";
    analyticsLog("resource " + _f + "  " + string(_amount) + " " + _currency + "  (" + _itemType + ":" + _itemId + ")");
}

// ==================== МЕТА / МЕНЮ ====================
function analyticsNewGame()  { analyticsDesign("game:new_game"); }
function analyticsContinue() { analyticsDesign("game:continue"); }

// ==================== БОЙ ====================
// Открывает «сессию боя» — новый id, чтобы группировать события одной битвы.
function analyticsBattleStart(_area = "overworld", _foe = "enemy") {
    if (!analyticsEnsure()) return;
    global.gaBattleId++;
    global.gaBattleArea = analyticsToken(_area);
    global.gaBattleFoe  = analyticsToken(_foe);
    global.gaBattleTag  = "b" + string(global.gaBattleId);
    analyticsProgression(GA_PROGRESSIONSTATUS_START, global.gaBattleArea, global.gaBattleFoe, global.gaBattleTag);
    analyticsDesign("battle:start", global.gaBattleId);
}

function analyticsWin() {
    analyticsProgression(GA_PROGRESSIONSTATUS_COMPLETE, global.gaBattleArea, global.gaBattleFoe, global.gaBattleTag);
    analyticsDesign("battle:win", global.gaBattleId);
}

function analyticsDefeat() {
    analyticsProgression(GA_PROGRESSIONSTATUS_FAIL, global.gaBattleArea, global.gaBattleFoe, global.gaBattleTag);
    analyticsDesign("battle:defeat", global.gaBattleId);
}

function analyticsRetreat() { analyticsDesign("battle:retreat", global.gaBattleId); }
function analyticsShuffle() { analyticsDesign("battle:shuffle", global.gaBattleId); }

// character — строка ("lana"/"viv"/имя бойца); rarity — enum CardsRarity или строка.
function analyticsPlayCard(_cardId, _rarity, _character) {
    var ev = "battle:play_card:" + analyticsCharToken(_character)
           + ":" + analyticsRarityName(_rarity)
           + ":" + analyticsToken(_cardId);
    analyticsDesign(ev, global.gaBattleId);
}

// ==================== КАРТЫ / КОЛОДА ====================
// source: "battle" (награда за победу) или "chest".
function analyticsReward(_cardId, _rarity, _source = "battle") {
    var ev = "reward:" + analyticsToken(_source)
           + ":" + analyticsRarityName(_rarity)
           + ":" + analyticsToken(_cardId);
    analyticsDesign(ev, global.gaBattleId);
}

// character — строка (characterKey(...)); cardId — строка; rarity — enum/строка.
function analyticsAddToDeck(_character, _cardId, _rarity) {
    var ev = "deck:add:" + analyticsCharToken(_character)
           + ":" + analyticsRarityName(_rarity)
           + ":" + analyticsToken(_cardId);
    analyticsDesign(ev);
}

// ==================== СУНДУКИ ====================
// _kind — enum ChestKind (Gold/Card/Enemy). Фиксирует факт открытия и вид дропа.
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

// Золото, выпавшее из сундука: дизайн-событие + приход ресурса (gold source).
function analyticsChestGold(_amount) {
    analyticsDesign("chest:gold", _amount);
    if (_amount > 0) analyticsResource(GA_RESOURCEFLOWTYPE_SOURCE, "gold", _amount, "chest", "chest");
}

// ==================== МАГАЗИН ====================
// itemId — строка (id карты или "deck_slot"); price — цена в золоте.
function analyticsPurchase(_itemId, _price = 0) {
    var _it = analyticsToken(_itemId);
    analyticsDesign("shop:purchase:" + _it, _price);
    if (_price > 0) analyticsResource(GA_RESOURCEFLOWTYPE_SINK, "gold", _price, "shop", _it);
}

// ==================== КВЕСТ SAFAR ====================
function analyticsStartSafarQuest() {
    analyticsProgression(GA_PROGRESSIONSTATUS_START, "quest", "safar_spear", "");
    analyticsDesign("quest:safar:start");
}

function analyticsCompleteSafarQuest() {
    analyticsProgression(GA_PROGRESSIONSTATUS_COMPLETE, "quest", "safar_spear", "");
    analyticsDesign("quest:safar:complete");
}

