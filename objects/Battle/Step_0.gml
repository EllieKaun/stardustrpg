
switch (battleState) {
    case BattleStates.Preparing:
        
    break
    case BattleStates.DeckPreparing:
        
    break
    case BattleStates.CharacterPreparing:
        
    break
    case BattleStates.EnemyTargetSelection: 
        var enterPressed = keyboard_check_pressed(vk_enter)
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        var changeIndex = leftPressed - rightPressed
        if changeIndex != 0 { 
            if changeIndex < 0 {
                selectNextTarget()
            } else {
                selectPreviousTarget()
            }
        }
        if (enterPressed) {
            battleState = BattleStates.PlayProcess
            unselectTargets()
            var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
            playCard(currentCard, selectedCharacter, selectedTarget)
        }
    break    
    case BattleStates.AllyTargetSelection: 
        var enterPressed = keyboard_check_pressed(vk_enter)
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        var changeIndex = leftPressed - rightPressed
        if changeIndex != 0 { 
            if changeIndex < 0 {
                selectNextTarget()
            } else {
                selectPreviousTarget()
            }
        }
        if (enterPressed) {
            battleState = BattleStates.PlayProcess
            unselectTargets()
            var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
            playCard(currentCard, selectedCharacter, selectedTarget)
        }
    break 
    case BattleStates.CharacterPlay:
        var enterPressed = keyboard_check_pressed(vk_enter)
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        var changeIndex = leftPressed - rightPressed
        if changeIndex != 0 { 
            if changeIndex < 0 {
                selectedCard = selectedCard + 1 >= array_length(cards) ? 0 : selectedCard + 1
            } else {
                selectedCard = selectedCard - 1 < 0 ? array_length(cards) - 1 : selectedCard - 1
            }
        }
        if (enterPressed) {
            if (array_length(selectedCharacter.getCardsInHand()) > 0) { 
                var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
                var check = checkIfCanPlayCard(selectedCharacter, currentCard)
                if !check { return }
                if currentCard.target == TargetTypes.SingleEnemyTarget {
                    battleState = BattleStates.EnemyTargetSelection
                    initTargetSelection(enemies)
                } else if currentCard.target == TargetTypes.SingleAllyTarget {
                    battleState = BattleStates.AllyTargetSelection
                    initTargetSelection(heroes)
                } else if currentCard.target == TargetTypes.AllEnemies {
                    battleState = BattleStates.PlayProcess
                    playCard(currentCard, selectedCharacter, enemies)
                } else if currentCard.target == TargetTypes.AllAllies {
                    battleState = BattleStates.PlayProcess
                    playCard(currentCard, selectedCharacter, heroes)
                } 
            } else {
                skipTurn()
            }
        }
    break
    case BattleStates.PlayProcess:
    break
    case BattleStates.PlayResult:
        
    break
    case BattleStates.AfterPlayChecks:
        
    break
    case BattleStates.BattleOver:
        
    break
}