/// scrPlayerData
/// Collection of opened cards + per-character decks, saved to a JSON file.

enum Characters { Lana, Viv }

#macro PLAYER_SAVE_FILE "player_data.json"
#macro DECK_DEFAULT_UNLOCKED 4
#macro DECK_CAPACITY         12

function playerDataInit() {
    if (!playerDataLoad()) global.playerData = playerDataDefault();

    // Empty collection == brand new player -> hand out starter cards.
    if (array_length(variable_struct_get_names(global.playerData.collection)) == 0) {
        playerGrantStarterCards();
        playerDataSave();
    }
}

function playerGrantStarterCards() {
    unlockCard("physicalDamageSingleTarget");   // one per category so all tabs have something
    unlockCard("magicalDamageSingleTarget");
    unlockCard("instantHealSingleTarget");
    unlockCard("buffPhysicalDamageSingleTarget");
}

function playerDataDefault() {
    return {
        version: 1,
        collection: {},   // key "id@rarity" -> { id, rarity, count }
        decks: {
            lana: { unlocked: DECK_DEFAULT_UNLOCKED, cards: [] },  // cards: [{slot,id,rarity}]
            viv:  { unlocked: DECK_DEFAULT_UNLOCKED, cards: [] }
        }
    };
}

function playerDataSave() {
    var _str = json_stringify(global.playerData);
    var _buf = buffer_create(string_byte_length(_str) + 1, buffer_fixed, 1);
    buffer_write(_buf, buffer_string, _str);
    buffer_save(_buf, PLAYER_SAVE_FILE);
    buffer_delete(_buf);
}

function playerDataLoad() {
    if (!file_exists(PLAYER_SAVE_FILE)) return false;
    try {
        var _buf = buffer_load(PLAYER_SAVE_FILE);
        var _str = buffer_read(_buf, buffer_string);
        buffer_delete(_buf);
        global.playerData = json_parse(_str);
        return true;
    } catch (_e) {
        show_debug_message("playerDataLoad failed: " + string(_e));
        return false;
    }
}

/// ---------- Keys / helpers ----------

function characterKey(_character) {
    switch (_character) {
        case Characters.Lana: return "lana";
        case Characters.Viv:  return "viv";
        default:              return "lana";
    }
}

function collectionKey(_id, _rarity) {
    return _id + "@" + string(_rarity);
}

function deckOf(_character) {
    return global.playerData.decks[$ characterKey(_character)];
}

/// ---------- Collection (opened cards) ----------

function unlockCard(_id, _rarity = CardsRarity.Default, _count = 1) {
    if (!cardExists(_id)) { show_debug_message("unlockCard: unknown id " + string(_id)); return; }
    if (!cardCanVaryRarity(_id)) _rarity = CardsRarity.Default;

    var _key = collectionKey(_id, _rarity);
    var _col = global.playerData.collection;
    if (variable_struct_exists(_col, _key)) {
        _col[$ _key].count += _count;
    } else {
        _col[$ _key] = { id: _id, rarity: _rarity, count: _count };
    }
}

function isCardOwned(_id, _rarity = CardsRarity.Default) {
    return getOwnedCount(_id, _rarity) > 0;
}

function getOwnedCount(_id, _rarity = CardsRarity.Default) {
    var _key = collectionKey(_id, _rarity);
    var _col = global.playerData.collection;
    return variable_struct_exists(_col, _key) ? _col[$ _key].count : 0;
}

/// Returns array of refs: [{ id, rarity, count }]
function getCollectionRefs() {
    var _out  = [];
    var _col  = global.playerData.collection;
    var _keys = variable_struct_get_names(_col);
    for (var i = 0; i < array_length(_keys); i++) array_push(_out, _col[$ _keys[i]]);
    return _out;
}

/// Returns array of live Card structs (count copied onto each as ._owned).
function getCollectionCards() {
    var _refs = getCollectionRefs();
    var _out  = [];
    for (var i = 0; i < array_length(_refs); i++) {
        var _c = cardFromRef(_refs[i]);
        if (_c != undefined) { _c._owned = _refs[i].count; array_push(_out, _c); }
    }
    return _out;
}

/// ---------- Decks (slot-based) ----------

function countCardInDeck(_character, _id, _rarity) {
    var _cards = deckOf(_character).cards;
    var _n = 0;
    for (var i = 0; i < array_length(_cards); i++)
        if (_cards[i].id == _id && _cards[i].rarity == _rarity) _n++;
    return _n;
}

function deckSlotRef(_character, _slot) {
    var _cards = deckOf(_character).cards;
    for (var i = 0; i < array_length(_cards); i++)
        if (_cards[i].slot == _slot) return _cards[i];
    return undefined;
}

function clearDeckSlot(_character, _slot) {
    var _deck = deckOf(_character);
    for (var i = 0; i < array_length(_deck.cards); i++) {
        if (_deck.cards[i].slot == _slot) { array_delete(_deck.cards, i, 1); return; }
    }
}

/// Place a card into a deck slot. Returns true on success.
function setDeckSlot(_character, _slot, _id, _rarity = CardsRarity.Default) {
    if (!cardCanVaryRarity(_id)) _rarity = CardsRarity.Default;

    var _deck = deckOf(_character);
    if (_slot < 0 || _slot >= _deck.unlocked)        return false;  // slot not unlocked
    if (!isCardOwned(_id, _rarity))                  return false;  // don't own it

    var _existing = deckSlotRef(_character, _slot);
    var _alreadyHere = (_existing != undefined && _existing.id == _id && _existing.rarity == _rarity);

    // Can't use more copies than owned (existing card in THIS slot doesn't count against itself).
    var _used = countCardInDeck(_character, _id, _rarity) - (_alreadyHere ? 1 : 0);
    if (_used >= getOwnedCount(_id, _rarity))        return false;

    clearDeckSlot(_character, _slot);
    array_push(_deck.cards, { slot: _slot, id: _id, rarity: _rarity });
    return true;
}

function unlockDeckSlot(_character, _count = 1) {
    var _deck = deckOf(_character);
    _deck.unlocked = min(DECK_CAPACITY, _deck.unlocked + _count);
}

function clearDeck(_character) {
    deckOf(_character).cards = [];
}

/// ---------- UI builders (return Slot[] for your Panel) ----------

/// Choose panel: one "filled" slot per owned card, padded with "locked" up to totalSlots.
function buildCollectionSlots(_category = undefined, _cols = 4) {
    var _all   = getCollectionCards();
    var _cards = [];
    for (var i = 0; i < array_length(_all); i++) {
        if (_category == undefined || cardCategoryOf(_all[i]) == _category)
            array_push(_cards, _all[i]);
    }

    var _n     = array_length(_cards);
    var _total = max(_cols, ceil(_n / _cols) * _cols);   // fill the row; at least one row

    var _slots = [];
    for (var i = 0; i < _total; i++) {
        if (i < _n) array_push(_slots, new Slot("filled", _cards[i]));
        else        array_push(_slots, new Slot("empty"));   // never "locked" here
    }
    return _slots;
}

/// Place panel: deck slots — "filled"/"empty" while unlocked, "locked" beyond.
function buildDeckSlots(_character, _total = DECK_CAPACITY) {
    var _deck  = deckOf(_character);
    var _slots = [];
    for (var i = 0; i < _total; i++) {
        if (i >= _deck.unlocked) { array_push(_slots, new Slot("locked")); continue; }
        var _ref = deckSlotRef(_character, i);
        if (_ref != undefined) array_push(_slots, new Slot("filled", cardBuildRef(_ref)));
        else                   array_push(_slots, new Slot("empty"));
    }
    return _slots;
}

/// ---------- Dev helpers ----------

function unlockAllCards(_count = 9) {
    var _keys = variable_struct_get_names(global.cardRegistry);
    for (var i = 0; i < array_length(_keys); i++) unlockCard(_keys[i], CardsRarity.Default, _count);
}

function playerDataResetForTesting() {
    global.playerData = playerDataDefault();
    playerDataSave();
}