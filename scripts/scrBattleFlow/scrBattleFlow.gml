function afterPlayChecks() {
    // End Of Turn эффекты
    executeEndOfTurn(selectedCharacter)
    updateOvertime(selectedCharacter)
    selectedCard = 0
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
        battleState = BattleStates.CharacterPlay
    } else {
        selectNextCharacter()
        if (!selectedCharacter.isPuppet && checkIfHasEffectType(selectedCharacter, EffectTypes.Stun)) {
            skipTurn()
            return
        }
        if (selectedCharacter.isPuppet) {
            battleState = BattleStates.PuppetTurn
            alarm_set(PUPPET_TURN, game_get_speed(gamespeed_fps) * 1)
        } else if (isEnemysTurn()) {
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

function checkIfHasBuff(character, effectType, modifierToBuff) {
    var effects = character.effects 
    for(var i = 0; i < array_length(effects); i++) {
        var effect = effects[i]
        if effect.type == effectType && effect.buffType == modifierToBuff return effect
    }
    return undefined
}

function updateOvertime(character) {
    var effects = character.effects
    for (var i = array_length(effects) - 1; i >= 0; i--) {
        if (effects[i].timing == Timing.Overtime) {
            effects[i].duration -= 1
            if (effects[i].duration <= 0) array_delete(effects, i, 1)
        }
    }
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
    return true
}

function isEnemysTurn() {
    return array_contains(enemies, selectedCharacter)
}

function selectNextCharacter() {
    var count = array_length(playOrder);
    if (count == 0) return;
    
    var startIndex = (selectedCharacterNumber + 1) % count;
    
    for (var i = 0; i < count; i++) {
        var currentIndex = (startIndex + i) % count;
        var candidate = playOrder[currentIndex];
        
        if (!candidate.isKO()) {
            unselectionToAll();
            selectedCharacterNumber = currentIndex;
            selectedCharacter = candidate;
            selectedCharacter.isActive = true;
            cards = selectedCharacter.getCardsInHand();
            
            show_debug_message("new selectNextCharacter " + selectedCharacter.name);
            return;
        }
    }
    
    show_debug_message("No alive characters found");
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
    var aliveTargets = []
    for(var i = 0; i < array_length(targets); i++) {
        if !targets[i].isKO() array_push(aliveTargets, targets[i])
    }
    targetOptions = aliveTargets
    selectedTargetNumber = -1
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

function filterCriteria(element, index) {
    return !element.isKO()
}

function filterNotKO(targets) {
    return array_filter(targets, filterCriteria)
}

function returnToOverworld() {
    with (oTransition) { 
        target_room = global.returnRoom
        state = "fade_out"
    }
}

function retryBattle() {
    with (oTransition) { 
        target_room = BattleRoom
        state = "fade_out"
    }
}
