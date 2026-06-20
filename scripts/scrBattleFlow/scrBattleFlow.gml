function afterPlayChecks() {
    // End Of Turn эффекты
    executeEndOfTurn(selectedCharacter)
    updateOvertime(selectedCharacter)
    selectedCard = 0
    removeDeadPuppets()
      if (!instance_exists(selectedCharacter)) {
        selectNextCharacter()
        beginTurnFor(selectedCharacter)
        selectedTarget = noone
        return;
    }
    
    // Проверка на поражение
    if checkIfAllDead(heroes) {
        gameOverCursor = 0
        battleState = BattleStates.GameOver
        return
    }
    // Проверка на победу
    if checkIfAllDead(enemies) {
        grantBattleRewards()
        return
    }
    if selectedCharacter.energy > 0 {
        // если сыграл карту, а энергия еще осталась, играем еще
        show_debug_message("selectedCharacter.energy > 0 " + selectedCharacter.name)
        beginTurnFor(selectedCharacter)
    } else { 
        // иначе ходит следубщий по порядку
        selectNextCharacter()
        beginTurnFor(selectedCharacter)
    }
    selectedTarget = noone
}

function beginTurnFor(character) {
    if (!character.isPuppet && checkIfHasEffectType(character, EffectTypes.Stun)) { // если стан - пропускаем ход
        skipTurn()
        return
    }

    if (character.isPuppet) { // Ход куклы
        battleState = BattleStates.PuppetTurn
        alarm_set(PUPPET_TURN, game_get_speed(gamespeed_fps) * 2)
    } else if (character.isEnemy) { // Ход врага
        battleState = BattleStates.EnemysTurn
        alarm_set(ENEMYS_TURN, game_get_speed(gamespeed_fps) * 2)
    } else { // Ход героя
        battleState = BattleStates.CharacterPlay
    }
}

// Проверка: есть ли на персонаже наложенный эффект типа effectType
function checkIfHasEffectType(character, effectType) {
    var effects = character.effects 
    for(var i = 0; i < array_length(effects); i++) {
        if effects[i].type == effectType return true
    }
    return false
}

// Проверка: есть ли на персонаже бафф определенного модификатор 
function checkIfHasBuff(character, effectType, modifierToBuff) {
    var effects = character.effects 
    for(var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        if effect.type == effectType && effect.buffType == modifierToBuff return effect
    }
    return undefined
}

// Обновление данных овертайм эффектов 
function updateOvertime(character) {
    var effects = character.effects
    for (var i = array_length(effects) - 1; i >= 0; i--) {
        if (effects[i].timing == Timing.Overtime) {
            effects[i].duration -= 1
            if (effects[i].duration <= 0) array_delete(effects, i, 1)
        }
    }
}

// Пропуск хода
function skipTurn() {
    selectedCharacter.energy = 0
    battleState = BattleStates.AfterPlayChecks
    afterPlayChecks()
}

// Убрать карту из руки 
function removeCardFromHand(caster, card) {
    var cardsInHand = caster.getCardsInHand()
    for(var i = 0; i < array_length(cardsInHand); i++) {
        if cardsInHand[i] == card {
            array_delete(cardsInHand, i, 1)
            return
        }   
    }
}

// Проверить, мертвы ли все в массиве
function checkIfAllDead(array) {
    for(var i = 0; i < array_length(array); i ++) {
        if array[i].hp > 0 return false
    }
    return true
}

// Проверка на ход противника
function isEnemysTurn() {
    return array_contains(enemies, selectedCharacter)
}

// Выбор следующего персонажа
function selectNextCharacter() {
    var count = array_length(playOrder)
    if (count == 0) return; // если игроков нет - выход 
    
    var startIndex = (selectedCharacterNumber + 1) % count;
    
    for (var i = 0; i < count; i++) {
        var currentIndex = (startIndex + i) % count
        var candidate = playOrder[currentIndex]
        
        if (!candidate.isKO()) { // если персонаж не в ауте, выбираем
            unselectionToAll()
            selectedCharacterNumber = currentIndex
            selectedCharacter = candidate
            selectedCharacter.isActive = true
            cards = selectedCharacter.getCardsInHand()
            
            show_debug_message("new selectNextCharacter " + selectedCharacter.name)
            return
        }
    }
    
    show_debug_message("No alive characters found")
}

// Снять активность с персонажей
function unselectionToAll() {
    for (var i = 0; i < array_length(playOrder); i++) {
        playOrder[i].isActive = false
    }
}

// Восстановить всех игроков как активных
function restoreSelection() {
    for (var i = 0; i < array_length(playOrder); i++) {
        if selectedCharacterNumber == i {
            playOrder[i].isActive = true
            return
        }
    }
}

// Инициализация выборки - отбор персонажей для выбора (исключение ko)
function initTargetSelection(targets) {
    unselectionToAll()
    var aliveTargets = []
    for(var i = 0; i < array_length(targets); i++) {
        if !targets[i].isKO() array_push(aliveTargets, targets[i])
    }
    targetOptions = aliveTargets
    selectedTargetNumber = -1
    selectNextTarget()
}

// Выбор целей для игровки
function selectNextTarget() {
    if array_length(targetOptions) == 0 return
    if selectedTargetNumber == -1 {
        selectedTargetNumber = 0
    } else {
        selectedTargetNumber = selectedTargetNumber + 1 >= array_length(targetOptions) 
            ? 0 : selectedTargetNumber + 1
    }
    unselectTargets()
    selectedTarget = targetOptions[selectedTargetNumber]
    selectedTarget.isTarget = true
}

// Выбор целей для игровки
function selectPreviousTarget() {
    if array_length(targetOptions) == 0 return
    if selectedTargetNumber == -1 {
        selectedTargetNumber = array_length(targetOptions) - 1
    } else {
        selectedTargetNumber = selectedTargetNumber - 1 < 0
            ? array_length(targetOptions) - 1 : selectedTargetNumber - 1
    }
    unselectTargets()
    selectedTarget = targetOptions[selectedTargetNumber]
    selectedTarget.isTarget = true
}

// Снять выбор целей
function unselectTargets() {
    for (var i = 0; i < array_length(targetOptions); i++) {
        targetOptions[i].isTarget = false
    }
}

// Фильтр колбэк
function filterCriteria(element, index) {
    return !element.isKO()
}

// Фильтрация целей не в ауте
function filterNotKO(targets) {
    return array_filter(targets, filterCriteria)
}

// Возвращение в мир
function returnToOverworld() {
    with (oTransition) { 
        target_room = global.returnRoom
        state = "fade_out"
    }
}

// Начать заново
function retryBattle() {
    with (oTransition) { 
        target_room = BattleRoom
        state = "fade_out"
    }
}

// Удалить из массива
function removeFromArray(arr, item) {
    for (var i = array_length(arr) - 1; i >= 0; i--)
        if (arr[i] == item) { 
            array_delete(arr, i, 1)
            return
        }
}

// Удалить мертвых марионеток
function removeDeadPuppets() {
    for (var i = array_length(playOrder) - 1; i >= 0; i--) {
        var c = playOrder[i]
        if (c.isPuppet && c.isKO()) {
            removeFromArray(heroes,  c)
            removeFromArray(enemies, c)
            array_delete(playOrder, i, 1)

            if (i <= selectedCharacterNumber) selectedCharacterNumber--

            instance_destroy(c)
        }
    }
    initStarriorsPositions(posZoneHeight, posScreenWidth, posSpacing)  
}