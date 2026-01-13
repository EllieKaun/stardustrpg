function afterPlayChecks() {
    // End Of Turn эффекты
    executeEndOfTurn(selectedCharacter)
    // Проверка на поражение
    if checkIfAllDead(heroes) {
        
    }
    // Проверка на победу
    if checkIfAllDead(enemies) {
        
    }
    if selectedCharacter.energy > 0 {
        // если сыграл карту, а энергия еще осталась, играем еще
        show_debug_message("selectedCharacter.energy > 0 " + selectedCharacter.name)
        battleState = BattleStates.CharacterPlay
    } else {
        selectNextCharacter()
        if checkIfHasEffectType(selectedCharacter, EffectTypes.Stun) {
            executeStun(selectedCharacter)
            skipTurn()
            return
        }
        if isEnemysTurn() {
            battleState = BattleStates.EnemysTurn
            alarm_set(ENEMYS_TURN, game_get_speed(gamespeed_fps) * 2)
        } else {
            battleState = BattleStates.CharacterPlay            
        }
    }
    selectedTarget = noone
}

function checkIfHasEffectType(character, effectType) {
    var effects = character.effects 
    for(var i = 0; i < array_length(effects); i++) {
        if effects[i].type == effectType return true
    }
    return false
}

function skipTurn() {
    selectedCharacter.energy = 0
    battleState = BattleStates.AfterPlayChecks
    afterPlayChecks()
}

function removeCardFromHand(caster, card) {
    var cardsInHand = caster.getCardsInHand()
    for(var i = 0; i < array_length(cardsInHand); i++) {
        if cardsInHand[i] == card {
            array_delete(cardsInHand, i, 1)
            return
        }   
    }
}

function checkIfAllDead(array) {
    for(var i = 0; i < array_length(array); i ++) {
        if array[i].hp > 0 return false
    }
}

function isEnemysTurn() {
    return array_contains(enemies, selectedCharacter)
}

function selectNextCharacter() {
    if array_length(playOrder) == 0 return
    if selectedCharacterNumber == -1 {
        selectedCharacterNumber = 0
    } else {
        selectedCharacterNumber = selectedCharacterNumber + 1 >= array_length(playOrder) 
            ? 0 : selectedCharacterNumber + 1
    }
    unselectionToAll()
    selectedCharacter = playOrder[selectedCharacterNumber]
    selectedCharacter.isActive = true
    cards = selectedCharacter.getCardsInHand()
    show_debug_message("new selectNextCharacter " + selectedCharacter.name)
}

function unselectionToAll() {
    for (var i = 0; i < array_length(playOrder); i++) {
        playOrder[i].isActive = false
    }
}

function restoreSelection() {
    for (var i = 0; i < array_length(playOrder); i++) {
        if selectedCharacterNumber == i {
            playOrder[i].isActive = true
            return
        }
    }
}

function initTargetSelection(targets) {
    unselectionToAll()
    targetOptions = targets
    selectNextTarget()
}

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

function unselectTargets() {
    for (var i = 0; i < array_length(targetOptions); i++) {
        targetOptions[i].isTarget = false
    }
}