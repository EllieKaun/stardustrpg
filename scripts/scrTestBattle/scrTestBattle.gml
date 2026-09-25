// ТЕСТОВЫЙ БОЙ
// Включи TEST_BATTLE_ENABLED и правь только testBattleSetup() - любой бой станет тестовым.
//
// Юнит = hero(...) / mob(...):
//   hero("Lana"|"Viv"|"Safar", { ... })   - настоящий герой с оверрайдами
//   mob(createMushroom, { ... })          - настоящий моб с оверрайдами
//   mob(undefined, { ... })               - пустой манекен (по умолчанию 20 hp, 1 энергия)
//   times(5, mob(...))                    - N одинаковых юнитов
//
// Оверрайды (все необязательны):
//   name, hp, maxHp, mana, maxMana, energy, maxEnergy,
//   str, int, aura, guts, weaknesses, strengths,
//   cards - массив карт (заменяет колоду), ko - начать бой нокаутированным

#macro TEST_BATTLE_ENABLED false

function testBattleSetup() {
    return {
        exactStats: true, // true - без бонусов за победы, поджига и копья
        reward: forestRewardPool(),
        heroes: [
            hero("Lana", { hp: 5, cards: [
                createResurrectionCard(),
                createMagicalDamageSingleTargetCard(),
                createInstantHealSingleTargetCard()
            ] }),
            hero("Viv", { ko: true, cards: [
                createPhysicalDamageVampirismChanceMultipleTargetCard()
            ] })
        ],
        enemies: times(5, mob(undefined, { name: "Foe", hp: 3, str: 1 }))
    }
}

// ---- конструкторы описаний ----

function hero(base, overrides = {}) {
    return { kind: "hero", base: base, overrides: overrides, count: 1 }
}

function mob(base, overrides = {}) {
    return { kind: "mob", base: base, overrides: overrides, count: 1 }
}

function times(n, spec) {
    spec.count = n
    return spec
}

// ---- сборка ----

function testUnitCreate(spec) {
    var unit
    if (spec.kind == "hero") {
        switch (spec.base) {
            case "Viv":   unit = createViv();   break
            case "Safar": unit = createSafar(); break
            default:      unit = createLana();  break
        }
    } else if (spec.base != undefined) {
        unit = spec.base()
    } else {
        unit = createStarrior(
            "Dummy",
            sprCrackerNutIdle, sprCrackerNutHit, sprCrackerNutCast, sprCrackerNutCast, sprCrackerNutIdle, noone,
            20, 20, 0, 0, 1, 1, 0, 0, 0, 0,
            [ createPhysicalDamageSingleTargetCard() ]
        )
    }
    testUnitApply(unit, spec.overrides)
    return unit
}

function testUnitApply(unit, overrides) {
    // короткие имена -> поля Starrior
    var fields = {
        name: "name", str: "strength", int: "intelligence", aura: "aura", guts: "guts",
        mana: "mana", maxMana: "maxMana", energy: "energy", maxEnergy: "maxEnergy",
        weaknesses: "weaknesses", strengths: "strengths"
    }
    var keys = variable_struct_get_names(fields)
    for (var i = 0; i < array_length(keys); i++) {
        if (variable_struct_exists(overrides, keys[i])) { variable_instance_set(unit, fields[$ keys[i]], overrides[$ keys[i]]) }
    }

    // mana/energy без max -> max подтягивается
    if (variable_struct_exists(overrides, "mana")) {   unit.maxMana   = overrides[$ "maxMana"]   ?? max(unit.maxMana, unit.mana) }
    if (variable_struct_exists(overrides, "energy")) { unit.maxEnergy = overrides[$ "maxEnergy"] ?? max(unit.maxEnergy, unit.energy) }

    if (variable_struct_exists(overrides, "maxHp")) { unit.maxHp = overrides.maxHp }
    if (variable_struct_exists(overrides, "hp")) {
        unit.hp = overrides.hp
        unit.maxHp = overrides[$ "maxHp"] ?? max(unit.maxHp, overrides.hp)
    }

    if (variable_struct_exists(overrides, "cards")) {
        var copy = array_create(array_length(overrides.cards))
        array_copy(copy, 0, overrides.cards, 0, array_length(overrides.cards))
        unit.deck = new Deck(copy)
    }

    if (overrides[$ "ko"] ?? false) {
        unit.hp = 0
        unit.changeActionState(StarriorStates.KnockOut, undefined)
    }
}

// Создатели юнитов (вызываются в начале боя): spec.count раз на описание
function testCreators(specs) {
    var creators = []
    for (var i = 0; i < array_length(specs); i++) {
        for (var n = 0; n < specs[i].count; n++) {
            array_push(creators, method({ spec: specs[i] }, function() {
                return testUnitCreate(spec)
            }))
        }
    }
    return creators
}

function testBattleEncounter() {
    var config = testBattleSetup()
    var encounter = makeEncounter(testCreators(config.enemies), config[$ "reward"] ?? forestRewardPool())
    encounter.raw = config[$ "exactStats"] ?? true
    if (variable_struct_exists(config, "heroes")) { encounter.heroCreators = testCreators(config.heroes) }
    return encounter
}
