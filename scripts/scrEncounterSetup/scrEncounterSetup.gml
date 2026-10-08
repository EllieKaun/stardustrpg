function generateLevel(zoneH, screenW, spacing, encounter) {
    initStarriorsFromEncounter(encounter)
    initStarriorsPositions(zoneH, screenW, spacing)
    
    if (variable_global_exists("battleEnemyFirst") && global.battleEnemyFirst) {
        orderEnemiesFirst()
    }
    selectNextCharacter()
    startTurnFor(selectedCharacter)
}

function orderEnemiesFirst() {
    array_resize(playOrder, 0)
    for (var i = 0; i < array_length(enemies); i++) { 
        array_push(playOrder, enemies[i]) 
    }
    for (var i = 0; i < array_length(heroes);  i++) { 
        array_push(playOrder, heroes[i]) 
    }
    selectedCharacterNumber = -1
}

function initStarriorsFromEncounter(encounter) {
    if (TEST_BATTLE_ENABLED) {
        encounter = testBattleEncounter()
        global.battleEncounter = encounter
    }
    if (variable_struct_exists(encounter, "heroCreators")) {
        heroes = []
        for (var i = 0; i < array_length(encounter.heroCreators); i++) {
            array_push(heroes, encounter.heroCreators[i]())
        }
    } else {
        heroes = [createLana(), createViv()]
        if (variable_global_exists("safarJoined") && global.safarJoined) {
            array_push(heroes, createSafar())
        }
        if (variable_global_exists("foxJoined") && global.foxJoined) {
            array_push(heroes, createFox())
        }
    }
    enemies = []
    var creators = encounter.enemyCreators
    for (var i = 0; i < array_length(creators); i++) {
        array_push(enemies, creators[i]())
    }

    array_copy(playOrder, array_length(playOrder), heroes,  0, array_length(heroes))
    array_copy(playOrder, array_length(playOrder), enemies, 0, array_length(enemies))
    for (var i = 0; i < array_length(playOrder); i++) {
        shuffleDeckAndTake4(playOrder[i])
    }
    
    var isRaw = variable_struct_exists(encounter, "raw") && encounter.raw
    var difficulty = battleDifficulty()
    var level = difficultyLevel(encounter)
    var statPoints = difficulty.statPoints(level)
    
    var igniteBattle = (variable_global_exists("battleIsIgnited") && global.battleIsIgnited)
    var igniteAffix = igniteBattle ? findAffixById(difficulty, "ignite") : undefined
    var igniteFlags = array_create(array_length(enemies), false)
    if (igniteAffix != undefined && !isRaw && array_length(enemies) > 0) {
        var anyIgnited = false
        for (var i = 0; i < array_length(enemies); i++) {
            if (random(1) < igniteAffix.roll(level)) { igniteFlags[i] = true; anyIgnited = true }
        }
        if (!anyIgnited) { igniteFlags[irandom(array_length(enemies) - 1)] = true } // хотя бы один
    }
    for (var i = 0; i < array_length(enemies); i++) {
        var enemy = enemies[i]
        enemy.isEnemy = true
        enemy.hasSpear = false
        enemy.hasCauldron = false
        if (isRaw) {
            continue
        }
        if (igniteFlags[i]) {
            applyEnemyAffix(enemy, igniteAffix)
        } else if (igniteAffix != undefined) {
            applyEnemyStatBonus(enemy, statPoints, difficulty.statWeights)
        } else {
            var affix = rollEnemyAffix(difficulty, level)
            if (affix != undefined) {
                applyEnemyAffix(enemy, affix)
            } else {
                applyEnemyStatBonus(enemy, statPoints, difficulty.statWeights)
            }
        }
    }

    // Копьё в бою только пока квест активен
    var spearQuestActive = (questSpearState() == QuestSpearState.Active)
    if (variable_global_exists("battleHasSpear") && global.battleHasSpear && !spearQuestActive) {
        global.battleHasSpear = false
    }

    if (!isRaw
        && variable_global_exists("battleHasSpear")
        && global.battleHasSpear
        && array_length(enemies) > 0) {
        var spearIdx = irandom(array_length(enemies) - 1)
        enemies[spearIdx].hasSpear = true
        if (spearBattleSprite() == noone) { enemies[spearIdx].image_blend = c_yellow }

        var damageBonus = spearBattleBonus()
        for (var i = 0; i < array_length(enemies); i++) {
            applyEnemyStatBonus(enemies[i], damageBonus)
        }
        global.battleHasSpear = false
    }

    if (!isRaw
        && variable_struct_exists(encounter, "hasCauldron")
        && encounter.hasCauldron
        && array_length(enemies) > 0) {
        var cauldronIdx = irandom(array_length(enemies) - 1)
        enemies[cauldronIdx].hasCauldron = true
    }
}

function rollEnemyAffix(difficulty, level) {
    var affixes = difficulty.affixes
    for (var i = 0; i < array_length(affixes); i++) {
        var affix = affixes[i]
        if (random(1) < affix.roll(level)) { return affix }
    }
    return undefined
}

function findAffixById(difficulty, affixId) {
    var affixes = difficulty.affixes
    for (var i = 0; i < array_length(affixes); i++) {
        if (affixes[i].id == affixId) { return affixes[i] }
    }
    return undefined
}

function applyEnemyAffix(enemy, affix) {
    var mult = affix.statMult
    var stats = variable_struct_get_names(mult)
    for (var i = 0; i < array_length(stats); i++) {
        var stat = stats[i]
        variable_instance_set(enemy, stat, variable_instance_get(enemy, stat) * mult[$ stat])
    }
    if (affix.mark != undefined) { variable_instance_set(enemy, affix.mark, true) }
    if (affix.chanceField != undefined) { variable_instance_set(enemy, affix.chanceField, affix.effectChance) }

    var affixSprites = affix[$ "sprites"]
    var spritesForKind = affix[$ "spritesForKind"]
    if (spritesForKind != undefined && variable_instance_exists(enemy, "kind")) {
        var kindSet = spritesForKind(enemy.kind)
        if (kindSet != undefined) { affixSprites = kindSet }
    }
    if (affixSprites != undefined) {
        if (affixSprites[$ "idle"] != undefined) {
            enemy.spriteActionIdle = affixSprites.idle
            enemy.sprite_index = affixSprites.idle
            enemy.mask_index = affixSprites.idle
        }
        if (affixSprites[$ "attack"] != undefined) { enemy.spriteActionAttack = affixSprites.attack }
        if (affixSprites[$ "cast"]   != undefined) { enemy.spriteActionCast   = affixSprites.cast }
        if (affixSprites[$ "spell"]  != undefined) { enemy.spriteActionSpell  = affixSprites.spell }
        if (affixSprites[$ "dance"]  != undefined) { enemy.spriteActionDance  = affixSprites.dance }
        if (affixSprites[$ "ko"]     != undefined) { enemy.spriteActionKO     = affixSprites.ko }
    } else if (affix[$ "sprite"] != undefined) {
     
        enemy.spriteActionIdle = affix.sprite
        enemy.sprite_index = affix.sprite
        enemy.mask_index = affix.sprite
    }

    if (affix.blend != undefined) { enemy.image_blend = affix.blend }
}

