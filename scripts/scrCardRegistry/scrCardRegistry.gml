/// scrCardRegistry
/// Maps stable string IDs <-> Card factories so cards can be saved/restored.
/// IMPORTANT: never rename an existing id once players have save files.

function cardRegistryInit() {
    global.cardRegistry = {};

    // _reg(id, canVaryRarity, buildFunc(rarity) -> Card)
    var _reg = function(_id, _canVary, _build) {
        global.cardRegistry[$ _id] = {
            id: _id,
            canVaryRarity: _canVary,
            build: _build
        };
    };

    // ---- Physical attack ----
    _reg("physicalDamageSingleTarget",            true, function(_r) { return createPhysicalDamageSingleTargetCard(_r); });
    _reg("physicalDamageMultipleTarget",          true, function(_r) { return createPhysicalDamageMultipleTargetCard(_r); });
    _reg("physicalDamageStunChanceSingleTarget",  true, function(_r) { return createPhysicalDamageStunChanseSingleTargetCard(_r); });
    _reg("physicalDamageStunChanceMultiTarget",   true, function(_r) { return createPhysicalDamageStunChanseMultipleTargetCard(_r); });
    _reg("physicalDamageBleedChanceSingleTarget", true, function(_r) { return createPhysicalDamageBleedingChanseSingleTargetCard(_r); });
    _reg("physicalDamageBleedChanceMultiTarget",  true, function(_r) { return createPhysicalDamageBleedingChanseMultipleTargetCard(_r); });
    _reg("physicalDamageBombChanceSingleTarget",  true, function(_r) { return createPhysicalDamageBombChanseSingleTargetCard(_r); });
    _reg("physicalDamageBombChanceMultiTarget",   true, function(_r) { return createPhysicalDamageBombChanseMultipleTargetCard(_r); });
    _reg("physicalDamageWeakenChanceSingleTarget",true, function(_r) { return createPhysicalDamageWeakeningChanseSingleTargetCard(_r); });
    _reg("physicalDamageWeakenChanceMultiTarget", true, function(_r) { return createPhysicalDamageWeakeningChanseMultipleTargetCard(_r); });
    _reg("physicalDamageVampChanceSingleTarget",  true, function(_r) { return createPhysicalDamageVampirismChanseSingleTargetCard(_r); });
    _reg("physicalDamageVampChanceMultiTarget",   true, function(_r) { return createPhysicalDamageVampirismChanceMultipleTargetCard(_r); });

    // ---- Magical attack ----
    _reg("magicalDamageSingleTarget",             true, function(_r) { return createMagicalDamageSingleTargetCard(_r); });
    _reg("magicalDamageMultipleTarget",           true, function(_r) { return createMagicalDamageMultipleTargetCard(_r); });
    _reg("magicalDamageStunChanceSingleTarget",   true, function(_r) { return createMagicalDamageStunChanseSingleTargetCard(_r); });
    _reg("magicalDamageStunChanceMultiTarget",    true, function(_r) { return createMagicalDamageStunChanseMultipleTargetsCard(_r); });
    _reg("magicalDamageBurnChanceSingleTarget",   true, function(_r) { return createMagicalDamageBurnChanseSingleTargetCard(_r); });
    _reg("magicalDamageBurnChanceMultiTarget",    true, function(_r) { return createMagicalDamageBurnChanseMultipleTargetCard(_r); });
    _reg("magicalDamageFreezeChanceSingleTarget", true, function(_r) { return createMagicalDamageFreezingChanceSingleTargetCard(_r); });
    _reg("magicalDamageFreezeChanceMultiTarget",  true, function(_r) { return createMagicalDamageFreezingChanceMultipleTargetCard(_r); });

    // ---- Buff / Debuff ----
    _reg("buffPhysicalDamageSingleTarget",        true, function(_r) { return createCardBuffPhysicalDamageSingleTarget(); });
    _reg("buffMagicalDamageSingleTarget",         true, function(_r) { return createCardBuffMagicalDamageSingleTarget(); });
    _reg("buffAnyDamageMultiTarget",              true, function(_r) { return createCardBuffAnyDamageMultipleTarget(); });
    _reg("buffPhysicalProtectionSingleTarget",    true, function(_r) { return createCardBuffPhysicalProtectionSingleTarget(); });
    _reg("buffMagicalProtectionSingleTarget",     true, function(_r) { return createCardBuffMagicalProtectionSingleTarget(); });
    _reg("buffAnyProtectionMultiTarget",          true, function(_r) { return createCardBuffAnyProtectionMultipleTarget(); });
    _reg("debuffPhysicalDamageSingleTarget",      true, function(_r) { return createCardDebuffPhysicalDamageSingleTarget(); });
    _reg("debuffMagicalDamageSingleTarget",       true, function(_r) { return createCardDebuffMagicalDamageSingleTarget(); });
    _reg("debuffPhysicalProtectionSingleTarget",  true, function(_r) { return createCardDebuffPhysicalProtectionSingleTarget(); });
    _reg("debuffMagicalProtectionSingleTarget",   true, function(_r) { return createCardDebuffMagicalProtectionSingleTarget(); });
    _reg("weaknessMagicalDamageSingleTarget",     true, function(_r) { return createCardCreateTemporaryWeaknessMagicalDamageSingleTarget(); });
    _reg("weaknessPhysicalDamageSingleTarget",    true, function(_r) { return createCardCreateTemporaryWeaknessPhysicalDamageSingleTarget(); });
    _reg("ignoreWeaknessSingleTarget",            true, function(_r) { return createCardIgnoreWeaknessSingleTarget(); });

    // ---- Heal ----
    _reg("instantHealSingleTarget",               true, function(_r) { return createInstantHealSingleTargetCard(); });
    _reg("instantHealMultiTarget",                true, function(_r) { return createInstantMultipleTargetsHealCard(); });
    _reg("overtimeHealSingleTarget",              true, function(_r) { return createOvertimeHealSingleTargetCard(); });
    _reg("instantManaGainSingleTarget",           true, function(_r) { return createInstantManaGainSingleTargetCard(); });
    _reg("instantManaGainMultiTarget",            true, function(_r) { return createInstantMultipleTargetsManaGainCard(); });
    _reg("overtimeManaGainSingleTarget",          true, function(_r) { return createOvertimeManaGainSingleTargetCard(); });

    // ---- Unique (fixed rarity) ----
    _reg("copyNextPlayedCard", false, function(_r) { return createCopyNextPlayedCardCard(); });
    _reg("addEnergy",          false, function(_r) { return createAddEnergyCard(); });
    _reg("shuffleDeck",        false, function(_r) { return createShuffleDeckCard(); });
    _reg("removeShock",        false, function(_r) { return createRemoveStatusShockSingleTargetCard(); });
    _reg("removeBurn",         false, function(_r) { return createRemoveStatusBurnSingleTargetCard(); });
    _reg("removeFreeze",       false, function(_r) { return createRemoveStatusFreezeSingleTargetCard(); });
    _reg("removeBleeding",     false, function(_r) { return createRemoveStatusBleedingSingleTargetCard(); });
    _reg("removeStun",         false, function(_r) { return createRemoveStatusStunSingleTargetCard(); });
    _reg("resurrection",       false, function(_r) { return createResurrectionCard(); });
}

/// @function cardExists(id)
function cardExists(_id) {
    return variable_struct_exists(global.cardRegistry, _id);
}

/// @function cardBuild(id, rarity) -> Card | undefined
/// Builds a live Card and tags it with its id so it can be re-saved later.
function cardBuild(_id, _rarity = CardsRarity.Default) {
    if (!cardExists(_id)) {
        show_debug_message("cardBuild: unknown id '" + string(_id) + "'");
        return undefined;
    }
    var _def  = global.cardRegistry[$ _id];
    var _r    = _def.canVaryRarity ? _rarity : CardsRarity.Default;
    var _card = _def.build(_r);
    _card.cardId = _id;            // stamp the id onto the instance
    return _card;                  // _card.rarity is set by the factory
}

/// @function cardToRef(card) -> { id, rarity }
function cardToRef(_card) {
    return { id: _card.cardId, rarity: _card.rarity };
}

/// @function cardFromRef(ref) -> Card | undefined
function cardFromRef(_ref) {
    return cardBuild(_ref.id, _ref.rarity);
}

/// @function cardCanVaryRarity(id)
function cardCanVaryRarity(_id) {
    return cardExists(_id) ? global.cardRegistry[$ _id].canVaryRarity : false;
}