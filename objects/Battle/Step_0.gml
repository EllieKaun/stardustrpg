
if (battleState == BattleStates.Victory)  { 
    stepVictoryScreen()
    exit
}
if (battleState == BattleStates.GameOver) { 
    stepGameOverScreen() 
    exit
}
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
        
        if (focusArea == FocusArea.Deck) {
            if (leftPressed) { 
                if (selectedCard == 0) {
                    focusArea = FocusArea.Menu
                    selectedMenuItem = 0
                } else {
                    selectedCard--
                }
            }
            if (rightPressed) {
                if (selectedCard < array_length(selectedCharacter.getCardsInHand()) - 1) {
                    selectedCard++
                }
            }
        } else if (focusArea == FocusArea.Menu) {
            var upPressed = keyboard_check_pressed(vk_up)
            var downPressed = keyboard_check_pressed(vk_down)
            
            if (upPressed) {
                selectedMenuItem = selectedMenuItem - 1 < 0 ? array_length(menuItems) - 1 : selectedMenuItem - 1
            }
            if (downPressed) {
                selectedMenuItem = selectedMenuItem + 1 >= array_length(menuItems) ? 0 : selectedMenuItem + 1
            }
            if (rightPressed) {
                focusArea = FocusArea.Deck
                selectedCard = 0
            }
        }
        if (enterPressed) {
            if (focusArea == FocusArea.Menu) {
                switch (menuItems[selectedMenuItem]) {
                    case "Shuffle":
                        shuffleDeckAndTake4(selectedCharacter)
                        skipTurn()
                    break
                    case "Run":
                        with (oTransition) {
                            target_room = global.returnRoom
                            state = "fade_out"
                        }
                    break
                    case "Info":
                        battleState = BattleStates.EnemyInfoSelection
                        initTargetSelection(enemies)
                    break
                }
            } else if (array_length(selectedCharacter.getCardsInHand()) > 0) { 
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
    case BattleStates.EnemyInfoSelection:
        var enterPressed = keyboard_check_pressed(vk_enter)
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        if (leftPressed) selectPreviousTarget()
        if (rightPressed) selectNextTarget()
        
        if (enterPressed) {
            battleState = BattleStates.EnemyInfoDisplay
            // Info display specific logic could go here if needed
        }
    break
    case BattleStates.EnemyInfoDisplay:
        var enterPressed = keyboard_check_pressed(vk_enter)
        if (enterPressed) {
            battleState = BattleStates.CharacterPlay
            unselectTargets()
            restoreSelection()
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