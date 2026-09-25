// Золото
#macro GOLD_PER_ENEMY 6 // награда за одного врага
#macro GOLD_RUN_PENALTY 5 // штраф за побег

// Магазин
#macro SHOP_CARD_PRICE 100 // цены карты
#macro SHOP_SLOT_BASE 100 // цена слота декбилдера
#macro SHOP_SLOT_GROWTH 1.5 // во сколько раз увеличивается цена слота

// Сундуки
#macro CHEST_GOLD_MIN 5 // минимальная награда золота из сундука
#macro CHEST_GOLD_RANGE 15 // максимальная награда золота из сундука

// Награды
#macro REWARD_DUPLICATE_FALLOFF 0.5 // падение шанса выпадения дубликата карты как награды

// Сложность врагов
#macro ENEMY_WIN_BONUS 2 // рост силы врагов
#macro ENEMY_WIN_INTERVAL 5 // сколько побед нужно чтобы сложность выросла
#macro SPEAR_BATTLE_BONUS 15  // сложность врагов с капьем

// Слабые места: модификатор урона (слабость +, сила −) и бонус к шансу статуса
#macro WEAKNESS_DAMAGE_MODIFIER 0.1
#macro WEAKNESS_STATUS_CHANCE_BONUS 0.1

#macro CARD_MANA_COST_MULTIPLIER 2 // множитель цены карт за ману (здоровье не трогаем)

function cardBalance() {
    return {
        instantHeal:     [10, 20, 30, HEAL_FULL],
        overtimeHeal:    [6, 8, 12, 16],
        overtimeHealDur: [2, 2, 3, 3],
        instantMana:     [10, 20, 30, MANA_FULL],
        overtimeMana:    [6, 8, 12, 16],
        overtimeManaDur: [2, 2, 3, 3],
        buff:            [2, 4, 6, 8],
        damageMulSingle: [1, 2, 3, 4],
        damageMulGroup:  [1, 1, 2, 3],
        cost: {
            physicalSingle: [2, 3, 4, 5],
            physicalMulti:  [4, 5, 6, 7],
            magical:        [3, 4, 5, 6],
            instantHeal:    [3, 4, 5, 6],
            overtimeHeal:   [2, 3, 4, 5],
            other:          [3, 4, 5, 6]
        }
    }
}

function currentZoneId() {
    return "forest"
}

function difficultyLevel(encounter = undefined) {
    var bonus = (encounter != undefined && variable_struct_exists(encounter, "difficultyBonus")) ? encounter.difficultyBonus : 0
    return getWins() + bonus
}

function battleDifficulty(zoneId = undefined) {
    zoneId = zoneId ?? currentZoneId()
    switch (zoneId) {
        case "forest":
        default:
            return {
                statPoints: function(level) { return floor(level / ENEMY_WIN_INTERVAL) * ENEMY_WIN_BONUS },
                statWeights: { strength: 1, intelligence: 1, hp: 1, maxHp: 1 },
                affixes: [
                    {
                        id: "ignite",
                        roll: function(level) {
                            if (level >= 50) { return 1 }
                            if (level >= 25) { return 0.4 }
                            return 0
                        },
                        statMult: { strength: 10, hp: 6, maxHp: 6 },
                        mark: "isIgnited",
                        chanceField: "igniteEffectChance",
                        effectChance: 0.1,
                        sprite: undefined,
                        blend: undefined
                    }
                ],
                enemyCount: [
                    { maxLevel: 10, mn: 1, mx: 2 },
                    { maxLevel: 25, mn: 2, mx: 4 },
                    { maxLevel: 50, mn: 3, mx: 5 },
                    { maxLevel: 1000000, mn: 4, mx: 5 }
                ],
                enemyPool: [createCrackerNut, createMushroom, createFlower],
                limitedEnemy: createLeaf,
                limitedChance: 3
            }
    }
}

function enemyCountForLevel(difficulty, level) {
    var tiers = difficulty.enemyCount
    for (var i = 0; i < array_length(tiers); i++) {
        if (level < tiers[i].maxLevel) { return { mn: tiers[i].mn, mx: tiers[i].mx } }
    }
    var last = tiers[array_length(tiers) - 1]
    return { mn: last.mn, mx: last.mx }
}

function zoneContent(zoneId = undefined) {
    zoneId = zoneId ?? currentZoneId()
    var cardIds = global.CardId
    var sections = array_create(4, undefined) // индекс = enum Section
    switch (zoneId) {
        case "forest":
        default:
            sections[Section.TopLeft] = {
                compositions: [
                    [createCrackerNut, createCrackerNut],
                    [createCrackerNut, createLeaf],
                    [createCrackerNut, createLeaf, createCrackerNut],
                    [createCrackerNut, createCrackerNut, createCrackerNut]
                ],
                rewardIds: [
                    cardIds.physicalDamageSingleTarget, // атака одного врага
                    cardIds.physicalDamageMultipleTarget, // атака группы
                    cardIds.physicalDamageWeakenChanceSingleTarget, // шанс слабости
                    cardIds.magicalDamageBurnChanceSingleTarget, // атака огнём
                    cardIds.buffPhysicalDamageSingleTarget // усиление физ урона
                ]
            }
            sections[Section.TopRight] = {
                compositions: [
                    [createMushroom, createMushroom],
                    [createMushroom, createFlower],
                    [createMushroom, createLeaf, createFlower],
                    [createMushroom, createMushroom, createMushroom]
                ],
                rewardIds: [
                    cardIds.physicalDamageBleedChanceSingleTarget, // шанс кровотечения
                    cardIds.buffPhysicalProtectionSingleTarget, // усиление физ защиты
                    cardIds.debuffPhysicalDamageSingleTarget, // снижение физ атаки
                    cardIds.instantManaGainSingleTarget, // восстановление mp
                    cardIds.magicalDamageStunChanceSingleTarget // атака молнией
                ]
            }
            sections[Section.BottomRight] = {
                compositions: [
                    [createFlower, createFlower],
                    [createMushroom, createFlower],
                    [createMushroom, createLeaf, createFlower],
                    [createFlower, createFlower, createFlower]
                ],
                rewardIds: [
                    cardIds.magicalDamageFreezeChanceSingleTarget, // атака льдом
                    cardIds.weaknessMagicalDamageSingleTarget, // слабость к маг урону
                    cardIds.buffMagicalProtectionSingleTarget, // усиление маг защиты
                    cardIds.debuffMagicalDamageSingleTarget, // снижение маг атаки
                    cardIds.instantHealMultiTarget // восстановление
                ]
            }
            sections[Section.BottomLeft] = {
                compositions: [
                    [createCrackerNut, createLeaf, createFlower],
                    [createCrackerNut, createLeaf, createMushroom],
                    [createMushroom, createCrackerNut, createFlower],
                    [createLeaf, createLeaf, createFlower]
                ],
                rewardIds: [
                    cardIds.magicalDamageSingleTarget, // звёздная энергия
                    cardIds.magicalDamageStunChanceMultiTarget, // молния группе
                    cardIds.magicalDamageBurnChanceMultiTarget, // огонь группе
                    cardIds.magicalDamageFreezeChanceMultiTarget, // лёд группе
                    cardIds.overtimeHealSingleTarget, // постепенное hp
                    cardIds.overtimeManaGainSingleTarget // постепенное mp
                ]
            }
            return {
                rewardRarities: [CardsRarity.Default, CardsRarity.Unusual],
                regionEnemyTypes: [oCrakerNutSmall, oMushroomSmall, oFlowerSmall, oLeafSmall],
                sections: sections
            }
    }
}
