enum Zone { Inner, Middle, Outer }
enum Section { TopRight, TopLeft, BottomLeft, BottomRight }

// Определение зоны
function zoneAt(posX, posY) {
    var config = global.zoneConfig
    var chebyshevDist = max(abs(posX - config.cx), abs(posY - config.cy))
    if (chebyshevDist <= config.innerHalf) { return Zone.Inner }
    if (chebyshevDist <= config.middleHalf) { return Zone.Middle }
    return Zone.Outer
}

// Определение секции
function sectionAt(posX, posY) {
    var config  = global.zoneConfig
    var offsetX = posX - config.cx
    var offsetY = posY - config.cy
    if (offsetY < 0) { return (offsetX >= 0) ? Section.TopRight : Section.TopLeft }
    else { return (offsetX >= 0) ? Section.BottomRight : Section.BottomLeft }
}

// Типы мини врагов для секции
function enemyTypesForRegion(zone, section) {
    return zoneContent().regionEnemyTypes
}

// Генерация врагов по секции для внешней зоны (для битвы)
function sectionCompositions(section) {
    var s = zoneContent().sections[section]
    return (s != undefined) ? s.compositions : [[createCrackerNut]]
}

// создание композиции врагов для битвы для секции для внешней зоны
function createEncounterForSection(section) {
    var compositions = sectionCompositions(section);
    var composition  = compositions[irandom(array_length(compositions) - 1)]
    var result = []
    for (var creatorIndex = 0; creatorIndex < array_length(composition); creatorIndex++) {
        array_push(result, composition[creatorIndex]())
    }
    return result
}

// Пул наград секции. Сейчас у всех секций пул общий - см. forestRewardPool()
function rewardPoolForSection(section) {
    return forestRewardPool()
}

// Добавить в список только существующие карты, без повторов
function appendRewardIds(targetIds, sourceIds) {
    for (var idIndex = 0; idIndex < array_length(sourceIds); idIndex++) {
        var cardId = sourceIds[idIndex]
        if (cardExists(cardId) && !array_contains(targetIds, cardId)) { array_push(targetIds, cardId) }
    }
}

// Пул наград леса (бой и сундуки) на текущий момент:
// дневные карты всегда, ночные - только ночью, карты марионеток - после победы над боссом
function forestRewardPool() {
    var content = zoneContent()
    var ids = []
    appendRewardIds(ids, content.rewardAlways)
    if (isNight()) { appendRewardIds(ids, content.rewardNightOnly) }
    if (isBossDefeated()) { appendRewardIds(ids, content.rewardAfterBoss) }
    return { ids: ids, rarities: content.rewardRarities }
}

// итоговое создание битвы из фабрик
// introSprite — спрайт катсцены появления босса
function makeEncounter(enemyCreators, reward, introSprite = undefined) {
    return { enemyCreators: enemyCreators, reward: reward, introSprite: introSprite }
}

// Единый пул композиций врагов в лесу
function forestCompositions() {
    var content = zoneContent()
    var allCompositions = []
    for (var sectionIndex = 0; sectionIndex < array_length(content.sections); sectionIndex++) {
        var s = content.sections[sectionIndex]
        if (s == undefined) { continue }
        for (var compositionIndex = 0; compositionIndex < array_length(s.compositions); compositionIndex++) {
            array_push(allCompositions, s.compositions[compositionIndex])
        }
    }
    return allCompositions
}

function worldIgniteChance() {

    var difficulty = battleDifficulty()
    var affix = findAffixById(difficulty, "ignite")
    if (affix == undefined) { return 0 }
    return affix.roll(difficultyLevel())
}

// Вид мирового мини-врага по его объекту
function worldEnemyKind(obj) {
    switch (obj) {
        case oCrakerNutSmall: return EnemyKind.CrackerNut
        case oMushroomSmall: return EnemyKind.Mushroom
        case oFlowerSmall: return EnemyKind.Flower
        case oLeafSmall: return EnemyKind.Leaf
        default: return EnemyKind.None
    }
}

// Игнайт-спрайт для открытого мира по виду врага
function worldIgniteSprite(kind) {
    var spriteName = ""
    switch (kind) {
        case EnemyKind.CrackerNut: 
            spriteName = "sprCrackerNutIgnite"
        break
        case EnemyKind.Mushroom: 
            spriteName = "sprIgniteMashroom"
        break
        case EnemyKind.Flower: 
            spriteName = "sprIgniteFlower"
        break
        case EnemyKind.Leaf: 
            spriteName = "sprIgniteLeaf"
        break
    }
    var asset = asset_get_index(spriteName)
    return (asset >= 0 && sprite_exists(asset)) ? asset : noone
}

function winScaledComposition() {
    var difficulty = battleDifficulty()
    var range = enemyCountForLevel(difficulty, difficultyLevel())
    var enemyCount = range.mn + irandom(range.mx - range.mn)
    var composition = []
    var leafUsed = false
    for (var enemyIndex = 0; enemyIndex < enemyCount; enemyIndex++) {
        if (!leafUsed && difficulty.limitedEnemy != undefined && irandom(difficulty.limitedChance) == 0) {
            array_push(composition, difficulty.limitedEnemy)
            leafUsed = true
        } else {
            array_push(composition, difficulty.enemyPool[irandom(array_length(difficulty.enemyPool) - 1)])
        }
    }
    return composition
}

// создание битвы для рандомного врага
function randomSectionEncounter(section) {
    return makeEncounter(winScaledComposition(), forestRewardPool())
}

function tutorialEncounter() {
    return makeEncounter([createLeaf], forestRewardPool())
}

// создание битвы для босса Марионетки
function puppetMasterEncounter() {
    var cardIds = global.CardId;
    var encounter = makeEncounter(
        [createPuppetMaster],
        { ids: [cardIds.summonAttackPuppet, cardIds.buffMagicalDamageSingleTarget, cardIds.magicalDamageStunChanceSingleTarget],
          rarities: [CardsRarity.Rare, CardsRarity.Epic] },
        PuppetMasterCutScene
    )
    encounter.raw = true
    encounter.isBoss = true
    return encounter
}

function randomSpawnerPoint(minDist, maxDist, maxAttempts = 30) {
    var leader = oGameController.selected_character
    if (!instance_exists(leader)) { return undefined }
    var zoneCount = instance_number(oSpawner)
    if (zoneCount == 0) { return undefined }
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
        var zone = instance_find(oSpawner, irandom(zoneCount - 1))
        var pointX = zone.bbox_left + random(zone.bbox_right - zone.bbox_left)
        var pointY = zone.bbox_top + random(zone.bbox_bottom - zone.bbox_top)
        if (!collision_point(pointX, pointY, oSpawner, false, true)) { continue }
        var dist = point_distance(leader.x, leader.y, pointX, pointY)
        if (dist < minDist || dist > maxDist) { continue }
        return { x: pointX, y: pointY, spawner: zone }
    }
    return undefined
}

function fireflyLimit() {
    return round(FIREFLY_MAX * nightValue())
}

// Зацикленный звук ходьбы по траве выделенного персонажа.
function updateWalkSound(active) {
    if (!variable_global_exists("walkSound") || global.walkSound < 0) { return }
    if (active) {
        if (!audio_is_playing(global.walkSound)) { playSfx(global.walkSound, 1, true) }
    } else {
        if (audio_is_playing(global.walkSound)) { audio_stop_sound(global.walkSound) }
    }
}
