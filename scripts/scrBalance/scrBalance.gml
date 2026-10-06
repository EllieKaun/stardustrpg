// Золото
#macro GOLD_PER_ENEMY 6 // награда за одного врага
#macro GOLD_RUN_PENALTY 5 // штраф за побег

// Ночные бои / ignite 
#macro NIGHT_GOLD_MULT 1.5 // ×золото за победу и ×штраф за побег в ночном бою
#macro IGNITE_CHASE_RADIUS 40 // с какого расстояния ignite-враг начинает погоню ночью
#macro IGNITE_CHASE_SPEED 0.68 // скорость погони 

// Магазин
#macro SHOP_CARD_PRICE 100 // цены карты
#macro SHOP_SLOT_BASE 100 // цена слота декбилдера
#macro SHOP_SLOT_GROWTH 1.5 // во сколько раз увеличивается цена слота

// Сундуки
#macro CHEST_GOLD_MIN 5 // минимальная награда золота из сундука
#macro CHEST_GOLD_RANGE 15 // максимальная награда золота из сундука

// Награды
#macro REWARD_DUPLICATE_FALLOFF 0.5 // падение шанса выпадения дубликата карты как награды
#macro REWARD_DEFAULT_RARITY_ONLY true // в наградах только обычная редкость

// Сложность врагов
#macro ENEMY_WIN_BONUS 2 // рост силы врагов
#macro ENEMY_WIN_INTERVAL 5 // сколько побед нужно чтобы сложность выросла
#macro SPEAR_BATTLE_BONUS 15  // сложность врагов с капьем

// Слабые места: модификатор урона (слабость +, сила −) и бонус к шансу статуса
#macro WEAKNESS_DAMAGE_MODIFIER 0.1
#macro WEAKNESS_STATUS_CHANCE_BONUS 0.1

#macro CARD_MANA_COST_MULTIPLIER 2 // множитель цены карт за ману

// Константы светлячков
#macro HERO_TORCH_RADIUS 36 // радиус света вокруг выделенного героя ночью
#macro HERO_TORCH_INTENSITY 0.7 // яркость света героя (0..1)
#macro FIREFLY_MAX 12 // максимальное количество светлячков
#macro FIREFLY_SPAWN_INTERVAL 20 // кадров между попытками спавна
#macro FIREFLY_SPEED 0.15 // скорость 
#macro FIREFLY_PATROL_RANGE 20 // как далеко улетает от точки появления
#macro FIREFLY_LIGHT_RADIUS 8 // радиус пятна света
#macro FIREFLY_MIN_SPACING 64 // минимальное расстояние между светлячками при появлении
#macro FIREFLY_WOBBLE_RANGE 3 // размах виляния в пикселях
#macro FIREFLY_WOBBLE_SPEED 1.6 // скорость виляния
#macro FIREFLY_FADE_SPEED 0.04 // скорость разгорания и угасания
#macro FIREFLY_SPAWN_DISTANCE 240 // светлячки появляются не дальше этого расстояния от героя
#macro FIREFLY_DESPAWN_DISTANCE 300 // дальше этого расстояния от героя светлячок гаснет


function cardBalance() {
    return {
        instantHeal: [10, 20, 30, HEAL_FULL],
        overtimeHeal: [6, 8, 12, 16],
        overtimeHealDur: [2, 2, 3, 3],
        instantMana: [10, 20, 30, MANA_FULL],
        overtimeMana: [6, 8, 12, 16],
        overtimeManaDur: [2, 2, 3, 3],
        buff: [2, 4, 6, 8],
        damageMulSingle: [1, 2, 3, 4],
        damageMulGroup: [1, 1, 2, 3],
        cost: {
            physicalSingle: [2, 3, 4, 5],
            physicalMulti: [4, 5, 6, 7],
            magical: [3, 4, 5, 6],
            instantHeal: [3, 4, 5, 6],
            overtimeHeal: [2, 3, 4, 5],
            other: [3, 4, 5, 6]
        }
    }
}

function currentZoneId() {
    return ZoneId.Forest
}

function difficultyLevel(encounter = undefined) {
    var bonus = (encounter != undefined && variable_struct_exists(encounter, "difficultyBonus")) ? encounter.difficultyBonus : 0
    return getWins() + bonus
}

// Вернуть спрайт по имени ассета
function affixSpriteSlot(assetName) {
    var asset = asset_get_index(assetName)
    return (asset >= 0 && sprite_exists(asset)) ? asset : undefined
}

// Собрать набор анимаций из имён ассетов
function affixSpriteSet(idle, attack, cast, spell, dance, ko) {
    var set = {}
    var value
    value = affixSpriteSlot(idle)
    if (value != undefined) { 
        set.idle = value 
    }
    
    value = affixSpriteSlot(attack)
    if (value != undefined) { 
        set.attack = value 
    }
    
    value = affixSpriteSlot(cast)
    if (value != undefined) { 
        set.cast = value 
    }
    
    value = affixSpriteSlot(spell)
    if (value != undefined) { 
        set.spell = value 
    }
    
    value = affixSpriteSlot(dance)
    if (value != undefined) { 
        set.dance = value 
    }
    
    value = affixSpriteSlot(ko)
    if (value != undefined) { 
        set.ko = value 
    }
    return set
}

// Игнайт-спрайты под конкретный вид врага
function igniteSpritesForKind(kind) {
    switch (kind) {
        case EnemyKind.CrackerNut:
            return affixSpriteSet(
                "sprCrackerNutIgniteIdle", 
                "sprCrackerNutIgniteHit",
                "sprCrackerNutIgniteCast", 
                "sprCrackerNutIgniteCast", 
                "", 
                ""
            )
        case EnemyKind.Mushroom:
            return affixSpriteSet(
                "sprMushroomIgniteIdle", 
                "sprMushroomIgniteHit", 
                "sprMushroomIgniteCast", 
                "sprMushroomIgniteCast", 
                "", 
                ""
            )
        case EnemyKind.Flower:
            return affixSpriteSet(
                "sprPowerFlowerIgniteIdle", 
                "sprPowerFlowerIgniteHit", 
                "sprPowerFlowerIgniteSpell", 
                "sprPowerFlowerIgniteCast", 
                "", 
                ""
            )
        case EnemyKind.Leaf:
            return affixSpriteSet(
                "sprLeafIgniteIdle", 
                "sprLeafIgniteHit", 
                "sprLeafIgniteCast", 
                "", 
                "", 
                ""
            )
        default:
            return undefined
    }
}

function battleDifficulty(zoneId = undefined) {
    zoneId = zoneId ?? currentZoneId()
    switch (zoneId) {
        case ZoneId.Forest:
        default:
            return {
                statPoints: function(level) { return floor(level / ENEMY_WIN_INTERVAL) * ENEMY_WIN_BONUS },
                statWeights: { strength: 1, intelligence: 1, hp: 1, maxHp: 1 },
                affixes: [
                    {
                        id: "ignite",
                        roll: function(level) {
                            var base = (level >= 50) ? 1 : ((level >= 25) ? 0.4 : 0)
                            return clamp(base + nightValue() * 0.2, 0, 1)
                        },
                        statMult: { strength: 10, hp: 6, maxHp: 6 },
                        mark: "isIgnited",
                        chanceField: "igniteEffectChance",
                        effectChance: 0.1,
                        sprites: undefined,
                        spritesForKind: igniteSpritesForKind,
                        blend: undefined
                    }
                ],
                enemyCount: [
                    { maxLevel: 10, mn: 1, mx: 2 },
                    { maxLevel: 25, mn: 2, mx: 4 },
                    { maxLevel: 50, mn: 3, mx: 5 },
                    { maxLevel: 1000000, mn: 4, mx: 5 }
                ],
                enemyPool: [createCrackerNut, createMushroom, createFlower, createLeaf],
                limitedEnemy: undefined,
                limitedChance: 3
            }
    }
}

function enemyCountForLevel(difficulty, level) {
    var tiers = difficulty.enemyCount
    for (var index = 0; index < array_length(tiers); index++) {
        if (level < tiers[index].maxLevel) { return { mn: tiers[index].mn, mx: tiers[index].mx } }
    }
    var last = tiers[array_length(tiers) - 1]
    return { mn: last.mn, mx: last.mx }
}

function zoneContent(zoneId = undefined) {
    zoneId = zoneId ?? currentZoneId()
    var cardIds = global.CardId
    var sections = array_create(4, undefined) // индекс = enum Section
    switch (zoneId) {
        case ZoneId.Forest:
        default:
            sections[Section.TopLeft] = {
                compositions: [
                    [createCrackerNut, createCrackerNut],
                    [createCrackerNut, createLeaf],
                    [createCrackerNut, createLeaf, createCrackerNut],
                    [createCrackerNut, createCrackerNut, createCrackerNut]
                ]
            }
            sections[Section.TopRight] = {
                compositions: [
                    [createMushroom, createMushroom],
                    [createMushroom, createFlower],
                    [createMushroom, createLeaf, createFlower],
                    [createMushroom, createMushroom, createMushroom]
                ]
            }
            sections[Section.BottomRight] = {
                compositions: [
                    [createFlower, createFlower],
                    [createMushroom, createFlower],
                    [createMushroom, createLeaf, createFlower],
                    [createFlower, createFlower, createFlower]
                ]
            }
            sections[Section.BottomLeft] = {
                compositions: [
                    [createCrackerNut, createLeaf, createFlower],
                    [createCrackerNut, createLeaf, createMushroom],
                    [createMushroom, createCrackerNut, createFlower],
                    [createLeaf, createLeaf, createFlower]
                ]
            }
            return {
                // Карты-награды (бой и сундуки). Итоговый пул собирает forestRewardPool():
                // всегда + ночные (если ночь) + после босса (если босс побеждён)
                rewardAlways: [
                    cardIds.physicalDamageSingleTarget, // атака одного врага
                    cardIds.physicalDamageStunChanceSingleTarget, // атака с шансом оглушения
                    cardIds.physicalDamageBleedChanceSingleTarget, // атака с шансом кровотечения
                    cardIds.physicalDamageWeakenChanceSingleTarget, // атака с шансом слабости
                    cardIds.instantHealSingleTarget, // восстановление hp
                    cardIds.instantManaGainSingleTarget, // восстановление mp
                    cardIds.buffPhysicalDamageSingleTarget, // усиление физ урона
                    cardIds.buffMagicalDamageSingleTarget, // усиление маг урона
                    cardIds.buffPhysicalProtectionSingleTarget, // усиление физ защиты
                    cardIds.buffMagicalProtectionSingleTarget, // усиление маг защиты
                    cardIds.magicalDamageBurnChanceSingleTarget, // атака огнём
                    cardIds.magicalDamageSingleTarget // атака звёздной энергией
                ],
                rewardNightOnly: [
                    cardIds.physicalDamageBombChanceSingleTarget, // атака с шансом взрыва
                    cardIds.physicalDamageVampChanceSingleTarget, // атака с шансом вампиризма
                    cardIds.overtimeHealSingleTarget, // постепенное восстановление hp
                    cardIds.overtimeManaGainSingleTarget, // постепенное восстановление mp
                    cardIds.debuffPhysicalDamageSingleTarget, // снижение физ атаки врага
                    cardIds.debuffMagicalDamageSingleTarget, // снижение маг атаки врага
                    cardIds.debuffPhysicalProtectionSingleTarget, // снижение физ защиты врага
                    cardIds.debuffMagicalProtectionSingleTarget, // снижение маг защиты врага
                    cardIds.magicalDamageStunChanceSingleTarget, // атака молнией
                    cardIds.magicalDamageFreezeChanceSingleTarget // атака льдом
                ],
                rewardAfterBoss: [
                    cardIds.summonAttackPuppet,
                    cardIds.summonMagicPuppet,
                    cardIds.summonHealPuppet,
                    cardIds.summonBuffPuppet
                ],
                // Карты, которые продаются в магазине всегда и не выпадают в наградах
                shopCards: [
                    { id: cardIds.shuffleDeck, price: 600 }, // перемешивает колоду
                    { id: cardIds.resurrection, price: 1000 }, // воскрешение павшего союзника
                    { id: cardIds.copyNextPlayedCard, price: 1000 } // усиление следующей разыгранной карты
                ],
                rewardRarities: [CardsRarity.Default, CardsRarity.Unusual],
                regionEnemyTypes: [oCrakerNutSmall, oMushroomSmall, oFlowerSmall, oLeafSmall],
                sections: sections
            }
    }
}
