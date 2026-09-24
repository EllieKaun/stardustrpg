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
    var s
    if (spec.kind == "hero") {
        switch (spec.base) {
            case "Viv":   s = createViv();   break
            case "Safar": s = createSafar(); break
            default:      s = createLana();  break
        }
    } else if (spec.base != undefined) {
        s = spec.base()
    } else {
        s = createStarrior(
            "Dummy",
            sprCrackerNutIdle, sprCrackerNutHit, sprCrackerNutCast, sprCrackerNutCast, sprCrackerNutIdle, noone,
            20, 20, 0, 0, 1, 1, 0, 0, 0, 0,
            [ createPhysicalDamageSingleTargetCard() ]
        )
    }
    testUnitApply(s, spec.overrides)
    return s
}

function testUnitApply(s, o) {
    // короткие имена -> поля Starrior
    var fields = {
        name: "name", str: "strength", int: "intelligence", aura: "aura", guts: "guts",
        mana: "mana", maxMana: "maxMana", energy: "energy", maxEnergy: "maxEnergy",
        weaknesses: "weaknesses", strengths: "strengths"
    }
    var keys = variable_struct_get_names(fields)
    for (var i = 0; i < array_length(keys); i++) {
        if (variable_struct_exists(o, keys[i])) variable_instance_set(s, fields[$ keys[i]], o[$ keys[i]])
    }

    // mana/energy без max -> max подтягивается
    if (variable_struct_exists(o, "mana"))   s.maxMana   = o[$ "maxMana"]   ?? max(s.maxMana, s.mana)
    if (variable_struct_exists(o, "energy")) s.maxEnergy = o[$ "maxEnergy"] ?? max(s.maxEnergy, s.energy)

    if (variable_struct_exists(o, "maxHp")) s.maxHp = o.maxHp
    if (variable_struct_exists(o, "hp")) {
        s.hp = o.hp
        s.maxHp = o[$ "maxHp"] ?? max(s.maxHp, o.hp)
    }

    if (variable_struct_exists(o, "cards")) {
        var copy = array_create(array_length(o.cards))
        array_copy(copy, 0, o.cards, 0, array_length(o.cards))
        s.deck = new Deck(copy)
    }

    if (o[$ "ko"] ?? false) {
        s.hp = 0
        s.changeActionState(StarriorStates.KnockOut, undefined)
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
    var cfg = testBattleSetup()
    var enc = makeEncounter(testCreators(cfg.enemies), cfg[$ "reward"] ?? forestRewardPool())
    enc.raw = cfg[$ "exactStats"] ?? true
    if (variable_struct_exists(cfg, "heroes")) enc.heroCreators = testCreators(cfg.heroes)
    return enc
}
